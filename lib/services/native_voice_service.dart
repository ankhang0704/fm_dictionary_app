import 'package:speech_to_text/speech_to_text.dart';
import 'package:flutter/material.dart';

class NativeVoiceService {
  final SpeechToText _speechToText = SpeechToText();
  bool _isInitialized = false;

  Future<bool> init() async {
    if (_isInitialized) return true;
    _isInitialized = await _speechToText.initialize(
      onError: (val) => debugPrint('Native STT Error: $val'),
      onStatus: (val) => debugPrint('Native STT Status: $val'),
    );
    return _isInitialized;
  }

  // Bắt đầu nghe
  Future<void> startListening(Function(String) onResult) async {
    if (!_isInitialized) await init();
    
    await _speechToText.listen(
      onResult: (result) {
        onResult(result.recognizedWords); // Trả về text liên tục
      },
      localeId: 'en_US', // Ép nghe Tiếng Anh
      // ignore: deprecated_member_use
      cancelOnError: true,
      // ignore: deprecated_member_use
      listenMode: ListenMode.dictation,
    );
  }

  // Dừng nghe
  Future<void> stopListening() async {
    await _speechToText.stop();
  }
}