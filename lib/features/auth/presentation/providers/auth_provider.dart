// Đường dẫn: lib/features/auth/presentation/providers/auth_provider.dart

import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fm_dictionary/core/di/service_locator.dart';
import '../../../../data/services/auth_sync/auth_sync_service.dart';
import '../../../../data/services/database/database_service.dart';

class AuthProvider extends ChangeNotifier {
  bool _isLoading = false;
  bool get isLoading => _isLoading;

  // Lấy user realtime từ Service cũ của bạn
  ValueNotifier<User?> get currentUserNotifier => sl<AuthSyncService>().currentUser;
  User? get currentUser => currentUserNotifier.value;

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  // Vỏ hàm (Function Stubs) & Thực thi
  Future<void> login(String email, String password) async {
    _setLoading(true);
    try {
      await sl<AuthSyncService>().loginWithEmail(email, password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> register(String email, String password, String name) async {
    _setLoading(true);
    try {
      await sl<AuthSyncService>().registerWithEmail(email: email, password: password, name: name);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> changePassword(String oldPass, String newPass) async {
    _setLoading(true);
    try {
      await sl<AuthSyncService>().changePassword(currentPassword: oldPass, newPassword: newPass);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> deleteAccount(String password) async {
    _setLoading(true);
    try {
      await sl<AuthSyncService>().deleteAccount(password);
    } finally {
      _setLoading(false);
    }
  }

  Future<void> updateAvatar(String imagePath) async {
    var settings = DatabaseService.getSettings();
    settings.userAvatarPath = imagePath;
    await DatabaseService.saveSettings(settings);
    notifyListeners(); // Cập nhật UI ngay lập tức
  }

  Future<void> removeAvatar() async {
    var settings = DatabaseService.getSettings();
    settings.userAvatarPath = null;
    await DatabaseService.saveSettings(settings);
    notifyListeners();
  }
   Future<void> resetPassword(String email) async {
    _setLoading(true);
    try {
      await sl<AuthSyncService>().resetPassword(email);
    } finally {
      _setLoading(false);
    }
   }
    Future<void> logout() async {
    _setLoading(true);
    try {
      await sl<AuthSyncService>().signOut();
    } finally {
      _setLoading(false);
    }
  }

  // Thêm hàm Đồng bộ dữ liệu
  Future<void> syncData() async {
    // Không dùng _setLoading ở đây vì ta sẽ dùng Dialog ở UI cho thao tác Sync
    await sl<AuthSyncService>().syncDataWithMerge();
  }
}