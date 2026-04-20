import 'dart:async';

import 'package:flutter_tts/flutter_tts.dart';
import 'tts_engine.dart';

class FlutterTtsEngine implements TtsEngine {
  final FlutterTts _tts = FlutterTts();
  bool _isWarm = false;

  @override
  Future<void> warmUp() async {
  if (_isWarm) return;
  try {
    final completer = Completer<void>();
    _tts.setCompletionHandler(() {
      if (!completer.isCompleted) completer.complete();
    });
    await _tts.setVolume(0.0);
    await _tts.speak(' ');
    await completer.future.timeout(const Duration(seconds: 2), onTimeout: () {
      if (!completer.isCompleted) completer.complete();
    });
  } finally {
    _tts.setCompletionHandler(() {}); // luôn chạy dù timeout hay exception
    await _tts.setVolume(1.0);
    _isWarm = true;
  }
}

  @override
  Future<void> speak(String text, {String? accent, double? speed}) async {
    await _tts.setLanguage(accent ?? 'en-US');
    await _tts.setSpeechRate(speed ?? 0.5);
    await _tts.setVolume(1.0);
    await _tts.setPitch(1.0);
    await _tts.speak(text);
  }

  @override
  Future<void> stop() => _tts.stop();

  @override
  Future<void> dispose() async {
    // Giải phóng Audio Session của iOS/Android
    await _tts.stop();
    await _tts.setVolume(0.0);
  }
}
