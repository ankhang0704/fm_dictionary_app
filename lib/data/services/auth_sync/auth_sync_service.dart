import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/progress_keys.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/database_service.dart';

class AuthSyncService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);
  final ValueNotifier<String> lastSyncTime = ValueNotifier<String>(
    'Chưa đồng bộ',
  );
  StreamSubscription<User?>? _authSubscription;

  // Khởi tạo và lắng nghe trạng thái đăng nhập
  Future<void> init() async {
    _authSubscription = _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });

    final prefs = await SharedPreferences.getInstance();
    lastSyncTime.value = prefs.getString('last_sync_time') ?? 'Chưa đồng bộ';
  }

  Future<void> dispose() async {
    await _authSubscription?.cancel();
  }
  // --- AUTH LOGIC ---

  Future<User?> registerWithEmail({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      UserCredential credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user != null) {
        await user.updateDisplayName(name);
        await user.reload();
        await user.sendEmailVerification();
        await _auth.signOut(); // Ép xác thực email
      }
      return user;
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    } catch (e) {
      throw Exception("Lỗi đăng ký không xác định.");
    }
  }

  Future<User?> loginWithEmail(String email, String password) async {
    try {
      UserCredential credential = await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password.trim(),
      );

      User? user = credential.user;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw Exception('Vui lòng xác minh Email trước khi đăng nhập.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
      debugPrint("Firebase Auth Error Code: ${e.code}");
      debugPrint("Firebase Auth Error Message: ${e.message}");

      // Ném lỗi ra cho UI
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<void> updateAvatar(String photoUrl) async {
    try {
      User? user = _auth.currentUser;
      if (user != null) {
        await user.updatePhotoURL(photoUrl);
        await user.reload();
        // Thông báo cho ValueNotifier cập nhật UI
        currentUser.value = _auth.currentUser;
      }
    } catch (e) {
      throw Exception("Không thể cập nhật ảnh đại diện.");
    }
  }

  // 2. Hàm đổi mật khẩu (Có kèm re-authenticate nếu cần)
  Future<void> changePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) throw Exception('Chưa đăng nhập');

      // Bước 1: Xác thực lại bằng mật khẩu cũ (Bắt buộc)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Bước 2: Cập nhật mật khẩu mới
      await user.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu hiện tại không chính xác.');
      }
      throw Exception(_handleAuthError(e.code));
    }
  }

  Future<void> signOut() async {
    try {
      await _auth.signOut();
      dispose();
      // Nếu bạn muốn xóa dữ liệu Hive khi logout thì thêm ở đây
    } catch (e) {
      debugPrint("Lỗi đăng xuất: $e");
    }
  }
  // lib/services/auth/auth_sync_service.dart

  Future<void> deleteAccount(String password) async {
    try {
      User? user = _auth.currentUser;
      if (user == null || user.email == null) throw Exception('not_logged_in');

      // 1. Xác thực lại (Re-authenticate)
      AuthCredential credential = EmailAuthProvider.credential(
        email: user.email!,
        password: password,
      );
      await user.reauthenticateWithCredential(credential);

      // 2. Xóa dữ liệu trên Firestore (Cleanup)
      await _firestore.collection('users').doc(user.uid).delete();

      // 3. Xóa tài khoản trên Auth
      await user.delete();
      await Hive.box(DatabaseService.progressBoxName).clear();
      await Hive.box(DatabaseService.saveBoxName).clear();
    } on FirebaseAuthException catch (e) {
      if (e.code == 'wrong-password') {
        throw Exception('Mật khẩu xác nhận không đúng.');
      }
      throw Exception(_handleAuthError(e.code));
    }
  }
  // --- SYNC LOGIC (Đã tối ưu try-catch) ---

  Future<void> syncDataWithMerge() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_logged_in');

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final settings = DatabaseService.getSettings();
      final localName = settings.userName;

      final docSnapshot = await docRef.get(
        const GetOptions(source: Source.server),
      );
      Map<String, dynamic> cloudProgress = {};

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        if (data.containsKey('progress')) {
          cloudProgress = data['progress'] as Map<String, dynamic>;
        }
      }

      final progressBox = Hive.box(DatabaseService.progressBoxName);
      Map<String, dynamic> localUpdates = {};
      Map<String, List<dynamic>> cloudUpdates = {};
      Set<String> processedKeys = {};

      for (var entry in cloudProgress.entries) {
        final key = entry.key;
        processedKeys.add(key);
        final List<dynamic> cData = entry.value;

        final int cUpdatedAt = cData.length > 4 ? (cData[4] as int) : 0;
        final double cPs = cData.length > 5
            ? ((cData[5] ?? 0) as num).toDouble()
            : 0.0;
        final int cPc = cData.length > 6 ? (cData[6] as int) : 0;
        final int cSv = cData.length > 7 ? (cData[7] as int) : 0;

        final localRaw = progressBox.get(key);

        // VÁ LỖI ÉP KIỂU (TYPE SAFETY)
        // Nếu không có data HOẶC data bị hỏng (không phải Map) -> Cập nhật lại từ Cloud
        if (localRaw == null || localRaw is! Map) {
          localUpdates[key] = {
            ProgressKeys.step: cData[0],
            ProgressKeys.wrongCount: cData[1],
            ProgressKeys.lastReview: cData[2],
            ProgressKeys.nextReview: cData[3],
            ProgressKeys.updatedAt: cUpdatedAt,
            ProgressKeys.pronunciationScore: cPs,
            ProgressKeys.pronunciationCount: cPc,
            ProgressKeys.isSaved: cSv,
          };
        } else {
          final localMap = localRaw; // Đã chắc chắn là Map
          final int lUpdatedAt = localMap[ProgressKeys.updatedAt] ?? 0;

          if (cUpdatedAt > lUpdatedAt) {
            localUpdates[key] = {
              ProgressKeys.step: cData[0],
              ProgressKeys.wrongCount: cData[1],
              ProgressKeys.lastReview: cData[2],
              ProgressKeys.nextReview: cData[3],
              ProgressKeys.updatedAt: cUpdatedAt,
              ProgressKeys.pronunciationScore: cPs,
              ProgressKeys.pronunciationCount: cPc,
              ProgressKeys.isSaved: cSv,
            };
          } else if (lUpdatedAt > cUpdatedAt) {
            cloudUpdates[key] = [
              localMap[ProgressKeys.step],
              localMap[ProgressKeys.wrongCount],
              localMap[ProgressKeys.lastReview],
              localMap[ProgressKeys.nextReview],
              lUpdatedAt,
              localMap[ProgressKeys.pronunciationScore] ?? 0.0,
              localMap[ProgressKeys.pronunciationCount] ?? 0,
              localMap[ProgressKeys.isSaved] ?? 0,
            ];
          }
        }
      }

      for (var key in progressBox.keys) {
        final String strKey = key.toString();
        if (!processedKeys.contains(strKey)) {
          final localRaw = progressBox.get(key);
          if (localRaw is Map) {
            cloudUpdates[strKey] = [
              localRaw[ProgressKeys.step],
              localRaw[ProgressKeys.wrongCount],
              localRaw[ProgressKeys.lastReview],
              localRaw[ProgressKeys.nextReview],
              localRaw[ProgressKeys.updatedAt] ?? 0,
              localRaw[ProgressKeys.pronunciationScore] ?? 0.0,
              localRaw[ProgressKeys.pronunciationCount] ?? 0,
              localRaw[ProgressKeys.isSaved] ?? 0,
            ];
          }
        }
      }

      final batch = _firestore.batch();
      bool needCommit = false;
      Map<String, dynamic> updatePayload = {};

      if (cloudUpdates.isNotEmpty || !docSnapshot.exists) {
        needCommit = true;
        updatePayload = {
          'name': localName,
          'dailyGoal': settings.dailyGoal,
          'lastSync': DateTime.now().millisecondsSinceEpoch,
        };
        if (cloudUpdates.isNotEmpty) {
          updatePayload['progress'] = cloudUpdates;
        }
        batch.set(docRef, updatePayload, SetOptions(merge: true));
      }

      // VÁ LỖI BẢO TOÀN DỮ LIỆU KHI MẤT MẠNG (ATOMIC SYNC)
      // Chạy Firebase Batch Commit trước!
      // ✅ SỬA — Wrap cả hai trong một atomic operation với rollback flag
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('sync_in_progress', true);

      try {
        if (needCommit) await batch.commit();
        if (localUpdates.isNotEmpty) await progressBox.putAll(localUpdates);
        await prefs.setBool('sync_in_progress', false);
      } catch (e) {
        // sync_in_progress = true còn lại → app biết cần retry khi mở lại
        debugPrint('❌ Partial sync failure: $e');
        rethrow;
      }

      debugPrint("Đồng bộ tối ưu thành công!");

      final timeString = DateFormat(
        'HH:mm - dd/MM/yyyy',
      ).format(DateTime.now());
      await prefs.setString('last_sync_time', timeString);
      lastSyncTime.value = timeString;
    } on FirebaseException catch (e) {
      if (e.code == 'unavailable' || e.code == 'network-request-failed') {
        throw Exception('network_error');
      }
      throw Exception(e.code);
    } catch (e) {
      throw Exception('sync_failed');
    }
  }

  String _handleAuthError(String errorCode) {
    switch (errorCode) {
      case 'user-not-found':
        return 'Không tìm thấy tài khoản.';
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng.';
      case 'email-already-in-use':
        return 'Email này đã được sử dụng.';
      case 'invalid-email':
        return 'Định dạng email không hợp lệ.';
      case 'weak-password':
        return 'Mật khẩu quá yếu.';
      default:
        return 'Lỗi hệ thống: $errorCode';
    }
  }
}
