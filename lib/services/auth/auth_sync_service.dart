import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../database/database_service.dart';

class AuthSyncService {
  AuthSyncService._();
  static final AuthSyncService instance = AuthSyncService._();

  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(null);
  
  // KHAI BÁO CÁC INSTANCE DÙNG CHUNG Ở ĐÂY
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn.instance; // Khởi tạo 1 lần duy nhất

  final ValueNotifier<String> lastSyncTime = ValueNotifier<String>('Chưa đồng bộ');

  Future<void> init() async {
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });

    // 2. BẮT BUỘC Ở V7: Phải khởi tạo engine trước khi dùng
    try {
      await _googleSignIn.initialize();
    } catch (e) {
      debugPrint("Lỗi khởi tạo GoogleSignIn: $e");
    }
    final prefs = await SharedPreferences.getInstance();
    lastSyncTime.value = prefs.getString('last_sync_time') ?? 'Chưa đồng bộ';
  }


  // 1. LOGIN GOOGLE
  Future<void> signInWithGoogle() async {
    try {
      // 3. V7 đổi tên hàm signIn() thành authenticate()
      // ignore: unnecessary_nullable_for_final_variable_declarations
      final GoogleSignInAccount? googleUser = await _googleSignIn.authenticate();
      if (googleUser == null) return; 

      // 4. V7 bỏ await vì authentication giờ là lấy dữ liệu local
      final GoogleSignInAuthentication googleAuth = googleUser.authentication;
      
      // 5. Firebase Auth chỉ cần idToken là đủ. 
      // V7 không tự trả về accessToken nữa nên ta truyền thẳng null để tránh lỗi.
      final AuthCredential credential = GoogleAuthProvider.credential(
        idToken: googleAuth.idToken,
        accessToken: null, 
      );

      await _auth.signInWithCredential(credential);

      await syncDataWithMerge(); // Đồng bộ ngay sau khi đăng nhập thành công

    } catch (e) {
      debugPrint("Lỗi Google Auth: $e");
      throw Exception('Lỗi đăng nhập Google: $e');
    }
  }

  // 2. LOGIN APPLE
  Future<void> signInWithApple() async {
    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes:[
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );
      final oauthProvider = OAuthProvider('apple.com');
      final credential = oauthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );
      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Lỗi Apple Auth: $e");
      throw Exception('Lỗi đăng nhập Apple');
    }
  }

  // 3. LOGOUT
  Future<void> signOut() async {
    await _googleSignIn.signOut(); // Dùng biến toàn cục
    await _auth.signOut();
  }

  // 4. BACKUP TIẾN ĐỘ LÊN FIRESTORE
  Future<void> syncDataWithMerge() async {
    final user = _auth.currentUser;
    if (user == null) throw Exception('not_logged_in');

    try {
      final docRef = _firestore.collection('users').doc(user.uid);
      final docSnapshot = await docRef.get(const GetOptions(source: Source.server));
      
      Map<String, dynamic> cloudProgress = {};
      if (docSnapshot.exists && docSnapshot.data()!.containsKey('progress')) {
        cloudProgress = docSnapshot.data()!['progress'] as Map<String, dynamic>;
      }

      final progressBox = Hive.box(DatabaseService.progressBoxName);
      Map<String, dynamic> localUpdates = {}; 
      Map<String, List<int>> cloudUpdates = {}; 
      Set<String> processedKeys = {}; 

      // So sánh Cloud -> Local
      for (var entry in cloudProgress.entries) {
        final key = entry.key;
        processedKeys.add(key);
        
        final List<dynamic> cData = entry.value;
        final int cUpdatedAt = cData.length > 4 ? (cData[4] as int) : 0;
        final localRaw = progressBox.get(key);
        
        if (localRaw == null) {
          localUpdates[key] = {'s': cData[0], 'wc': cData[1], 'lr': cData[2], 'nr': cData[3], 'ua': cUpdatedAt};
        } else {
          final int lUpdatedAt = (localRaw as Map)['ua'] ?? 0;
          if (cUpdatedAt > lUpdatedAt) {
            localUpdates[key] = {'s': cData[0], 'wc': cData[1], 'lr': cData[2], 'nr': cData[3], 'ua': cUpdatedAt};
          } else if (lUpdatedAt > cUpdatedAt) {
            cloudUpdates[key] = [localRaw['s'], localRaw['wc'], localRaw['lr'], localRaw['nr'], lUpdatedAt];
          }
        }
      }

      // So sánh Local -> Cloud
      for (var key in progressBox.keys) {
        final String strKey = key.toString();
        if (!processedKeys.contains(strKey)) {
          final localMap = progressBox.get(key) as Map;
          cloudUpdates[strKey] = [localMap['s'], localMap['wc'], localMap['lr'], localMap['nr'], localMap['ua'] ?? 0];
        }
      }

      // THỰC THI BATCH & BẤT ĐỒNG BỘ
      if (localUpdates.isNotEmpty) await progressBox.putAll(localUpdates);

      // SỬ DỤNG WRITEBATCH ĐỂ TỐI ƯU GIAO DỊCH MẠNG
      final batch = _firestore.batch();
      if (cloudUpdates.isNotEmpty) {
        batch.set(docRef, {
          'progress': cloudUpdates,
          'lastSync': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));
      } else if (localUpdates.isNotEmpty) {
        batch.set(docRef, {'lastSync': FieldValue.serverTimestamp()}, SetOptions(merge: true));
      }
      await batch.commit();
      final timeString = DateFormat('HH:mm - dd/MM/yyyy').format(DateTime.now());
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('last_sync_time', timeString);
      lastSyncTime.value = timeString;
    } catch (e) {
      if (e.toString().contains('unavailable') || e.toString().contains('network_error')) {
        throw Exception('network_error');
      }
      throw Exception('sync_failed');
    }
  }
  
}
