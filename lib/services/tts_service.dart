import 'package:flutter_tts/flutter_tts.dart';
import 'database_service.dart';

class TtsService {
  // Singleton instance
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  final FlutterTts _flutterTts = FlutterTts();

  Future<void> init() async {
    final settings = DatabaseService.getSettings();
    await _flutterTts.setLanguage(settings.defaultAccent);
    await _flutterTts.setSpeechRate(settings.ttsSpeed);
    await _flutterTts.setVolume(1.0);
    await _flutterTts.setPitch(1.0);
  }

  /// Đọc văn bản với tùy chọn Accent (en-US hoặc en-GB)
  Future<void> speak(String text, {String? accent}) async {
    final settings = DatabaseService.getSettings();
    
    // Nếu không truyền accent, dùng accent mặc định trong settings
    String targetAccent = accent ?? settings.defaultAccent;
    
    await _flutterTts.setLanguage(targetAccent);
    await _flutterTts.setSpeechRate(settings.ttsSpeed);
    await _flutterTts.speak(text);
  }

  Future<void> stop() async {
    await _flutterTts.stop();
  }
}