import 'dart:async';
import 'package:flutter/foundation.dart';
import '../../database/database_service.dart';
import 'tts_engine.dart';
import 'flutter_tts_engine.dart';

class TtsService {
  // ─── Singleton ────────────────────────────────────────────────────────────
  static final TtsService _instance = TtsService._internal();
  factory TtsService() => _instance;
  TtsService._internal();

  // ─── Engine (có thể inject engine khác sau này) ───────────────────────────
  late TtsEngine _engine;

  // ─── Debounce: hủy lệnh cũ trước khi phát mới ────────────────────────────
  Timer? _debounceTimer;
  Completer<void>? _currentSpeakCompleter;
  static const _debounceMs = 80; // ms chờ trước khi thực sự phát

  // ─── Vòng đời ─────────────────────────────────────────────────────────────
  bool _isInitialized = false;

  /// Gọi 1 lần duy nhất trong main() — warm-up hardware audio
  Future<void> init({TtsEngine? engine}) async {
    if (_isInitialized) return;
    _engine = engine ?? FlutterTtsEngine();

    // warmUp() chạy trong background, không block UI
    // Dùng compute() hoặc Future.microtask() để đảm bảo không jank
    unawaited(_engine.warmUp());
    _isInitialized = true;
  }

  // ─── Core API ─────────────────────────────────────────────────────────────

  /// Phát âm với Debounce + Cancel-old-play-new
  /// Người dùng nhấn nút loa nhiều lần nhanh → chỉ phát lần cuối
  Future<void> speak(String text, {String? accent}) async {
    assert(_isInitialized, 'TtsService.init() chưa được gọi');

    // 1. Hủy debounce timer cũ
    _debounceTimer?.cancel();

    // 2. Hủy lệnh speak đang chạy (nếu có)
    if (_currentSpeakCompleter != null && !_currentSpeakCompleter!.isCompleted) {
      await _engine.stop();
    }

    // 3. Tạo Completer mới để track lần phát này
    _currentSpeakCompleter = Completer<void>();
    final thisCompleter = _currentSpeakCompleter!;

    // 4. Debounce: chờ một chút rồi mới thực sự phát
    //    → tránh phát 3-4 âm thanh nếu user nhấn liên tục
    _debounceTimer = Timer(
      const Duration(milliseconds: _debounceMs),
      () async {
        // Nếu có Completer mới hơn đã thay thế → bỏ qua
        if (thisCompleter != _currentSpeakCompleter) return;

        try {
          final settings = DatabaseService.getSettings();
          // speak() trên flutter_tts là synchronous về UI thread,
          // nhưng audio rendering nằm trên native thread → không jank
          await _engine.speak(
            text,
            accent: accent ?? settings.defaultAccent,
            speed: settings.ttsSpeed,
          );
        } catch (e) {
          debugPrint('TtsService speak error: $e');
        } finally {
          if (!thisCompleter.isCompleted) thisCompleter.complete();
        }
      },
    );

    return thisCompleter.future;
  }

  Future<void> stop() async {
    _debounceTimer?.cancel();
    _debounceTimer = null;

    // GIẢI PHÓNG HÀNG ĐỢI - CHỐNG HUNG FUTURE (MEMORY LEAK)
    if (_currentSpeakCompleter != null &&
        !_currentSpeakCompleter!.isCompleted) {
      _currentSpeakCompleter!.completeError(
        StateError('TTS stopped before completion'),
      );
    }
    _currentSpeakCompleter = null;

    await _engine.stop();
  }

  /// Gọi khi Widget bị dispose (rời khỏi màn hình)
  /// → giải phóng Audio Session, tránh RAM leak
  Future<void> release() async {
    await stop();
    await _engine.dispose();
    // Warm lại khi quay về (lazy)
    _isInitialized = false;
  }
}

// Helper: fire-and-forget mà không gây warning "unawaited_futures"
void unawaited(Future<void> future) {
  future.ignore();
}