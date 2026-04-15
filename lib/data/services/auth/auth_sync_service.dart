import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/database_service.dart';

class AuthSyncService {
  AuthSyncService._();
  static final AuthSyncService instance = AuthSyncService._();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);
  final ValueNotifier<String> lastSyncTime = ValueNotifier<String>(
    'Chưa đồng bộ',
  );

  // Khởi tạo và lắng nghe trạng thái đăng nhập
  Future<void> init() async {
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });

    final prefs = await SharedPreferences.getInstance();
    lastSyncTime.value = prefs.getString('last_sync_time') ?? 'Chưa đồng bộ';
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
        email: email,
        password: password,
      );

      User? user = credential.user;
      if (user != null && !user.emailVerified) {
        await _auth.signOut();
        throw Exception('Vui lòng xác minh Email trước khi đăng nhập.');
      }
      return user;
    } on FirebaseAuthException catch (e) {
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
      List<dynamic> cloudSavedWords = [];

      if (docSnapshot.exists) {
        final data = docSnapshot.data()!;
        if (data.containsKey('progress')) {
          cloudProgress = data['progress'] as Map<String, dynamic>;
        }
        if (data.containsKey('saved_words')) {
          cloudSavedWords = data['saved_words'] as List<dynamic>;
        }
      }

      final progressBox = Hive.box(DatabaseService.progressBoxName);
      Map<String, dynamic> localUpdates = {};
      Map<String, List<dynamic>> cloudUpdates = {};
      Set<String> processedKeys = {};

      // 1. ĐỒNG BỘ PROGRESS (So sánh theo Timestamp integer)
      for (var entry in cloudProgress.entries) {
        final key = entry.key;
        processedKeys.add(key);
        final List<dynamic> cData = entry.value;

        final int cUpdatedAt = cData.length > 4 ? (cData[4] as int) : 0;
        final double cPs = cData.length > 5
            ? (cData[5] as num).toDouble()
            : 0.0;
        final int cPc = cData.length > 6 ? (cData[6] as int) : 0;

        final localRaw = progressBox.get(key);

        if (localRaw == null) {
          localUpdates[key] = {
            's': cData[0],
            'wc': cData[1],
            'lr': cData[2],
            'nr': cData[3],
            'ua': cUpdatedAt,
            'ps': cPs,
            'pc': cPc,
          };
        } else {
          final localMap = localRaw as Map;
          final int lUpdatedAt = localMap['ua'] ?? 0;

          if (cUpdatedAt > lUpdatedAt) {
            localUpdates[key] = {
              's': cData[0],
              'wc': cData[1],
              'lr': cData[2],
              'nr': cData[3],
              'ua': cUpdatedAt,
              'ps': cPs,
              'pc': cPc,
            };
          } else if (lUpdatedAt > cUpdatedAt) {
            cloudUpdates[key] = [
              localMap['s'],
              localMap['wc'],
              localMap['lr'],
              localMap['nr'],
              lUpdatedAt,
              localMap['ps'] ?? 0.0,
              localMap['pc'] ?? 0,
            ];
          }
        }
      }

      // Các từ có ở Local mà Cloud chưa có
      for (var key in progressBox.keys) {
        final String strKey = key.toString();
        if (!processedKeys.contains(strKey)) {
          final localMap = progressBox.get(key) as Map;
          cloudUpdates[strKey] = [
            localMap['s'],
            localMap['wc'],
            localMap['lr'],
            localMap['nr'],
            localMap['ua'] ?? 0,
            localMap['ps'] ?? 0.0,
            localMap['pc'] ?? 0,
          ];
        }
      }

      // 2. ĐỒNG BỘ SAVED WORDS (Dùng Set gộp để không mất từ)
      final savedBox = Hive.box(DatabaseService.saveBoxName);
      final Set<String> localSavedWords = savedBox.values
          .map((e) => e.toString())
          .toSet();
      final Set<String> cloudSavedSet = cloudSavedWords
          .map((e) => e.toString())
          .toSet();

      final Set<String> mergedSavedWords = localSavedWords.union(cloudSavedSet);

      if (mergedSavedWords.length > localSavedWords.length) {
        await savedBox.clear();
        await savedBox.addAll(mergedSavedWords.toList());
      }

      // 3. ĐẨY LÊN FIREBASE (Chỉ đẩy 1 Document duy nhất)
      if (localUpdates.isNotEmpty) await progressBox.putAll(localUpdates);

      final batch = _firestore.batch();
      bool needCommit = false;
      Map<String, dynamic> updatePayload = {};

      if (cloudUpdates.isNotEmpty ||
          !docSnapshot.exists ||
          mergedSavedWords.length > cloudSavedWords.length) {
        needCommit = true;

        // Payload siêu gọn: Tên, Goal, Từ lưu, và Cụm Progress (mảng số)
        updatePayload = {
          'name': localName,
          'dailyGoal': settings.dailyGoal,
          'saved_words': mergedSavedWords.toList(),
          'lastSync': DateTime.now()
              .millisecondsSinceEpoch, // Dùng Int epoch thay vì Firebase Timestamp để nhẹ
        };

        if (cloudUpdates.isNotEmpty) {
          updatePayload['progress'] = cloudUpdates;
        }

        batch.set(docRef, updatePayload, SetOptions(merge: true));
      }

      if (needCommit) {
        await batch.commit();
        debugPrint("Đồng bộ tối ưu thành công!");
      }

      final timeString = DateFormat(
        'HH:mm - dd/MM/yyyy',
      ).format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
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
