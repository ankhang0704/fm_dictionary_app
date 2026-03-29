import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'database_service.dart';

class AuthSyncService {
  AuthSyncService._();
  static final AuthSyncService instance = AuthSyncService._();

  // Quản lý trạng thái đăng nhập toàn cục
  final ValueNotifier<User?> currentUser = ValueNotifier<User?>(FirebaseAuth.instance.currentUser);

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Khởi tạo Listener
  void init() {
    _auth.authStateChanges().listen((user) {
      currentUser.value = user;
    });
  }

  // 1. ĐĂNG NHẬP GOOGLE
  Future<void> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      if (googleUser == null) return;

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Lỗi Google Sign-In: $e");
      throw Exception('auth.error_google');
    }
  }

  // 2. ĐĂNG NHẬP APPLE
  Future<void> signInWithApple() async {
    try {
      final AuthorizationCredentialAppleID appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes:[AppleIDAuthorizationScopes.email, AppleIDAuthorizationScopes.fullName],
      );

      final OAuthProvider oAuthProvider = OAuthProvider('apple.com');
      final AuthCredential credential = oAuthProvider.credential(
        idToken: appleCredential.identityToken,
        accessToken: appleCredential.authorizationCode,
      );

      await _auth.signInWithCredential(credential);
    } catch (e) {
      debugPrint("Lỗi Apple Sign-In: $e");
      throw Exception('auth.error_apple');
    }
  }

  // 3. ĐĂNG XUẤT
  Future<void> signOut() async {
    await GoogleSignIn().signOut();
    await _auth.signOut();
  }

  // 4. ĐỒNG BỘ TIẾN TRÌNH LÊN FIRESTORE (BACKUP)
  Future<void> backupProgress() async {
    final user = currentUser.value;
    if (user == null) throw Exception('auth.not_logged_in');

    try {
      final progressBox = Hive.box(DatabaseService.progressBoxName);
      Map<String, List<int>> compactData = {};

      // Nén dữ liệu: Thay vì lưu Map lớn, ta lưu Array 4 phần tử [s, wc, lr, nr]
      for (var key in progressBox.keys) {
        final data = progressBox.get(key) as Map;
        compactData[key.toString()] = [
          data['s'] as int,
          data['wc'] as int,
          data['lr'] as int,
          data['nr'] as int,
        ];
      }

      await _firestore.collection('users').doc(user.uid).set({
        'email': user.email,
        'displayName': user.displayName,
        'lastSync': FieldValue.serverTimestamp(),
        'progress': compactData,
      }, SetOptions(merge: true));

    } catch (e) {
      debugPrint("Lỗi Backup: $e");
      throw Exception('auth.error_sync'); // Bắt lỗi mạng ở UI
    }
  }
}