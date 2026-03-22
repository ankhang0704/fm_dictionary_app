import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';

class DatabaseService {
  static const String wordBoxName = 'wordsBox';
  static const String settingsBoxName = 'settingsBox';

  static AppSettings getSettings() {
    var box = Hive.box<AppSettings>(settingsBoxName);
    return box.get('current_settings') ?? AppSettings();
  }

  static Future<void> saveSettings(AppSettings settings) async {
    var box = Hive.box<AppSettings>(settingsBoxName);
    await box.put('current_settings', settings);
  }

  // Hàm tính tổng số từ đã thuộc
  static int getLearnedCount() {
    var box = Hive.box<Word>(wordBoxName);
    return box.values.where((w) => w.isLearned).length;
  }

  static Future<void> init() async {
    await Hive.initFlutter();

    // 1. Đăng ký các Adapter (Phải trùng ID với trong Model)
    Hive.registerAdapter(WordAdapter());
    Hive.registerAdapter(AppSettingsAdapter());

    // 2. Mở các Box
    await Hive.openBox<Word>(wordBoxName);
    await Hive.openBox<AppSettings>(settingsBoxName);

    // 3. Kiểm tra và thực hiện Import dữ liệu lần đầu
    await _checkAndImportData();
  }

  static Future<void> _checkAndImportData() async {
    var settingsBox = Hive.box<AppSettings>(settingsBoxName);
    var wordBox = Hive.box<Word>(wordBoxName);

    // Lấy settings hiện tại, nếu chưa có thì tạo mới
    AppSettings settings = settingsBox.get('current_settings') ?? AppSettings();

    if (settings.isFirstRun || wordBox.isEmpty) {
      debugPrint("Đang khởi tạo dữ liệu 1500 từ lần đầu tiên...");

      try {
        // Đọc file JSON
        final String response = await rootBundle.loadString(
          'assets/data/words.json',
        );
        final List<dynamic> data = json.decode(response);

        // Clear box cũ để tránh trùng lặp nếu có lỗi trước đó
        await wordBox.clear();

        // Import hàng loạt
        for (var item in data) {
          final newWord = Word(
            id: item['id'].toString(),
            topic: item['topic'],
            word: item['word'],
            phonetic: item['phonetic'] ?? '',
            meaning: item['meaning'] ?? '',
            example: item['example'] ?? '',
            audioPath: item['audio'],
          );
          await wordBox.put(newWord.id, newWord);
        }

        // Đánh dấu đã hoàn thành lần đầu
        settings.isFirstRun = false;
        await settingsBox.put('current_settings', settings);

        debugPrint("Import thành công ${wordBox.length} từ vựng!");
      } catch (e) {
        debugPrint("Lỗi khi import dữ liệu: $e");
      }
    }
  }

}
