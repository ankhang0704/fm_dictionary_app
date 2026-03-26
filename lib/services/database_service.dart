import 'dart:convert';
import 'package:flutter/foundation.dart'; // Bắt buộc import để dùng compute
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import '../models/app_settings.dart';

// HÀM CHẠY TRÊN LUỒNG NỀN (Isolate)
// Bắt buộc phải để ngoài class DatabaseService để compute có thể gọi được
List<Word> _parseJsonInBackground(String response) {
  final List<dynamic> data = json.decode(response);
  return data.map((json) => Word.fromJson(json)).toList();
}

class DatabaseService {
  static const String wordBoxName = 'words_box';
  static const String settingsBoxName = 'settings_box';

  static Future<void> init() async {
    await Hive.initFlutter();

    // Đăng ký Adapters TRƯỚC khi mở Box
    Hive.registerAdapter(WordAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // Mở các Boxes
    await Hive.openBox<String>('searchHistoryBox');
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
      try {
        debugPrint("⏳ Đang tải 1500 từ vựng...");

        // 1. Đọc file (rất nhanh)
        final String response = await rootBundle.loadString(
          'assets/data/fm_dictionary.json',
        );

        // 2. ÉP FLUTTER DỊCH JSON TRÊN LUỒNG NỀN (Tránh treo/crash app)
        final List<Word> words = await compute(
          _parseJsonInBackground,
          response,
        );

        // 3. Chuyển List thành Map để lưu vào Hive bằng putAll (Siêu tốc)
        final Map<String, Word> wordMap = {};
        for (var word in words) {
          wordMap[word.id] = word; // Dùng ID làm khóa (key)
        }

        // 4. Lưu một cục vào bộ nhớ
        await wordBox.putAll(wordMap);

        debugPrint("✅ Import thành công ${wordBox.length} từ vựng!");
      } catch (e) {
        debugPrint("❌ Lỗi nghiêm trọng khi đọc JSON: $e");
      }
    }
  }

  static AppSettings getSettings() {
    return Hive.box<AppSettings>(settingsBoxName).get('current_settings') ??
        AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    await settings.save();
  }
}
