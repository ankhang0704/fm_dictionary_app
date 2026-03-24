import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import '../models/app_settings.dart';

class DatabaseService {
  static const String wordBoxName = 'words_box';
  static const String settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();
    await Hive.openBox<String>('searchHistoryBox');
    // Đăng ký Adapters
    Hive.registerAdapter(WordAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // Mở các Boxes
    await Hive.openBox<Word>(wordBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);

    // Kiểm tra và Import dữ liệu lần đầu
    await _checkAndImportData();
  }

  static Future<void> _checkAndImportData() async {
    final wordBox = Hive.box<Word>(wordBoxName);
    final settingsBox = Hive.box<AppSettings>(settingsBoxName);

    // Khởi tạo Settings mặc định nếu chưa có
    if (settingsBox.isEmpty) {
      await settingsBox.put('current_settings', AppSettings());
    }

    // Import 1500 từ từ JSON nếu Box trống
    if (wordBox.isEmpty) {
      final String response = await rootBundle.loadString('assets/data/words.json');
      final List<dynamic> data = json.decode(response);
      
      final List<Word> words = data.map((json) => Word.fromJson(json)).toList();
      await wordBox.addAll(words);
    }
  }

  // Helper để lấy Settings nhanh
  static AppSettings getSettings() {
    return Hive.box<AppSettings>(settingsBoxName).get('current_settings') ?? AppSettings();
  }

  // Helper để lưu Settings
  static Future<void> saveSettings(AppSettings settings) async {
    await settings.save();
  }
}