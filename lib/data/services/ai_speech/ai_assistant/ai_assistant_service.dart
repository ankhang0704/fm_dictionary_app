import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

// --- LUỒNG XỬ LÝ ĐỘC LẬP (ISOLATE) ---
Future<String?> _runWhisperInIsolate(Map<String, String> args) async {
  try {
    final whisper = Whisper(
      model: WhisperModel.base, // ✅ ĐÃ SỬA THÀNH BASE CHO KHỚP VỚI FILE .BIN
      modelDir: args['modelDir']!,
    );
    final response = await whisper.transcribe(
      transcribeRequest: TranscribeRequest(
        audio: args['audioPath']!,
        threads: Platform.numberOfProcessors > 4 ? 4 : 2, 
        language: "en",
        isTranslate: false,
      ),
    );
    return response.text;
  } catch (e) {
    debugPrint("Lỗi Isolate Whisper: $e");
    return null;
  }
}

// --- DỊCH VỤ CHÍNH ---
class AiAssistantService {
  
  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isModelLoaded = false;
  bool _micActive = false;
  bool _isDisposed = false;
  String? _modelDirPath;
  String? _currentRecordingPath;

  Future<void> initModel() async {
    if (_isModelLoaded) return;
    try {
      final directory = await getApplicationDocumentsDirectory();
      _modelDirPath = directory.path;
      final file = File("$_modelDirPath/ggml-base.bin");

      if (!await file.exists()) {
        final data = await rootBundle.load('assets/models/ggml-base.bin');
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }

      final fileSize = await file.length();
      if (fileSize < 1000000) return;

      _isModelLoaded = true;
      debugPrint("✅ Model Whisper Base đã sẵn sàng");
    } catch (e) {
      debugPrint("❌ Lỗi initModel: $e");
    }
  }

  Future<void> startRecording() async {
    _isDisposed = false; 
    if (_micActive) return; 

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Microphone permission denied");
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';
    _currentRecordingPath = filePath;
    
    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1, 
      bitRate: 256000,
    );

    await _audioRecorder.start(config, path: filePath);
    _micActive = true;
    debugPrint("🎙️ Đang ghi âm...");
  }

  Future<String?> stopAndTranscribe() async {
    if (_isDisposed) return null;
    if (!_micActive) return null;

    _micActive = false; 
    final filePath = await _audioRecorder.stop();
    debugPrint("🛑 Đã dừng ghi âm. Bắt đầu phân tích...");
    
    if (filePath == null) return null;

    final file = File(filePath);
    final fileSize = await file.length();
    if (fileSize < 10000) {
      await file.delete();
      debugPrint("⚠️ File quá ngắn, đã hủy.");
      return null;
    }

    try {
      final result = await compute(_runWhisperInIsolate, {
        'modelDir': _modelDirPath!,
        'audioPath': filePath,
      });
      
      if (_isDisposed) return null; 

      for (final path in [filePath]) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }
      
      // ✅ ĐÃ SỬA LẠI LOGIC RETURN (Chống nhận diện rác)
      if (result != null && result.trim().replaceAll(RegExp(r'[^a-zA-Z]'), '').isNotEmpty) {
        debugPrint("🤖 AI nghe được: ${result.trim()}");
        return result.trim();
      }
      
      debugPrint("🤖 AI không nghe rõ hoặc chỉ nghe thấy tiếng ồn.");
      return null; // Ép về null nếu là chuỗi rác
      
    } catch (e) {
      debugPrint("❌ Lỗi stopAndTranscribe: $e");
      return null;
    }
  }

  Future<void> disposeSession() async {
    _isDisposed = true;
    if (_currentRecordingPath != null) {
      final f = File(_currentRecordingPath!);
      if (await f.exists()) await f.delete();
      _currentRecordingPath = null;
    }
    if (_micActive) {
      _micActive = false;
      await _audioRecorder.stop();
    }

    try {
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      await for (final f in dir.list()) {
        if (f.path.contains('rec_') || f.path.contains('processed_')) {
          try {
            await f.delete();
          } catch (_) {}
        }
      }
    } catch (e) {
      debugPrint("Lỗi dọn cache: $e");
    }
  }
}