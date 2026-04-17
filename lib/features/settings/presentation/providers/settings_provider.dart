import 'package:flutter/material.dart';
import '../../../../data/models/app_settings.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/ui_management/theme_manager.dart';

class SettingsProvider extends ChangeNotifier {
  late AppSettings _settings;
  bool _isLoading = true;

  AppSettings get settings => _settings;
  bool get isLoading => _isLoading;

  SettingsProvider() {
    _initSettings();
  }

  void _initSettings() {
    _settings = DatabaseService.getSettings();
    _isLoading = false;
    notifyListeners();
  }

  // Cập nhật Tên
  Future<void> updateName(String newName) async {
    _settings.userName = newName;
    await _saveAndNotify();
  }

  // Cập nhật Theme
  Future<void> toggleTheme(bool isDark) async {
    _settings.themeMode = isDark ? 'dark' : 'light';
    ThemeManager.updateTheme(_settings.themeMode);
    await _saveAndNotify();
  }

  // Cập nhật Chấm điểm AI
  Future<void> toggleHardMode(bool value) async {
    _settings.isHardMode = value;
    await _saveAndNotify();
  }

  // Cập nhật Tốc độ đọc
  Future<void> updateTtsSpeed(double speed) async {
    _settings.ttsSpeed = speed;
    await _saveAndNotify();
  }

  // TÍNH NĂNG MỚI: Cập nhật Mục tiêu từ vựng (Daily Goal)
  Future<void> updateDailyGoal(int goal) async {
    _settings.dailyGoal = goal;
    await _saveAndNotify();
  }

  // Hàm private để lưu Database
  Future<void> _saveAndNotify() async {
    await DatabaseService.saveSettings(_settings);
    notifyListeners();
  }
}