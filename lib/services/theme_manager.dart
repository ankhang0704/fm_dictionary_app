import 'package:flutter/material.dart';
import 'database_service.dart';

class ThemeManager {
  // Biến notifier để thông báo cho toàn bộ app khi theme thay đổi
  static final ValueNotifier<ThemeMode> themeNotifier = 
      ValueNotifier(DatabaseService.getSettings().themeMode == 'dark' 
          ? ThemeMode.dark 
          : ThemeMode.light);

  static void updateTheme(String themeStr) {
    if (themeStr == 'dark') {
      themeNotifier.value = ThemeMode.dark;
    } else {
      themeNotifier.value = ThemeMode.light;
    }
  }
}