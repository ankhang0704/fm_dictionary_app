import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

// --- LUỒNG XỬ LÝ ĐỘC LẬP (ISOLATE) ---
// Hàm Top-level bắt buộc phải nằm ngoài Class để dùng được với compute()
Future<String?> _runWhisperInIsolate(Map<String, String> args) async {
  try {
    final whisper = Whisper(
      model: WhisperModel.tiny,
      modelDir: args['modelDir']!,
    );
    final response = await whisper.transcribe(
      transcribeRequest: TranscribeRequest(
        audio: args['audioPath']!,
        threads: Platform.numberOfProcessors > 4
            ? 4
            : 2, // Dynamic scaling theo chip
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
  // Singleton pattern
  AiAssistantService._();
  static final AiAssistantService instance = AiAssistantService._();

  final AudioRecorder _audioRecorder = AudioRecorder();

  bool _isModelLoaded = false;
  bool _micActive = false;
  String? _modelDirPath;

  // 1. Khởi tạo Model (Chỉ copy model vào ổ cứng, không nạp lên RAM vội)
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
    } catch (e) {
      debugPrint("❌ Lỗi initModel: $e");
    }
  }

  // 2. Bắt đầu ghi âm
  Future<void> startRecording() async {
    if (_micActive) return; // Chống double-start

    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Microphone permission denied");
    }

    final tempDir = await getTemporaryDirectory();
    final filePath =
        '${tempDir.path}/rec_${DateTime.now().millisecondsSinceEpoch}.wav';

    // CẤU HÌNH SỐNG CÒN CHO WHISPER
    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000,
      numChannels: 1, // Mono
      bitRate: 256000,
    );

    await _audioRecorder.start(config, path: filePath);
    _micActive = true;
  }

  // 3. Tiền xử lý âm thanh (FFmpeg) bỏ bước này vì phần cứng 
  // Future<String> _preprocessAudio(String inputPath) async {
  //   final tempDir = await getTemporaryDirectory();
  //   final outputPath =
  //       '${tempDir.path}/processed_${DateTime.now().millisecondsSinceEpoch}.wav';

  //   // Lọc nhiễu, chuẩn hóa âm lượng, ép về 16kHz Mono
  //   final session = await FFmpegKit.execute(
  //     '-i $inputPath '
  //     '-af "highpass=f=80,lowpass=f=8000,afftdn=nf=-25,dynaudnorm=p=0.9" '
  //     '-ar 16000 -ac 1 -sample_fmt s16 '
  //     '$outputPath',
  //   );

  //   final returnCode = await session.getReturnCode();
  //   if (ReturnCode.isSuccess(returnCode)) {
  //     return outputPath;
  //   }

  //   // Fallback: Nếu phần cứng không chạy được lệnh FFmpeg, trả về file gốc
  //   return inputPath;
  // }

  // 4. Dừng ghi âm & Phân tích
  Future<String?> stopAndTranscribe() async {
    if (!_micActive) return null;

    _micActive = false; // Đặt cờ ngay lập tức để giải phóng state UI
    final filePath = await _audioRecorder.stop();

    if (filePath == null || !_isModelLoaded || _modelDirPath == null) {
      return null;
    }

    try {
      // BƯỚC 1: Lọc âm qua FFmpeg
      // final processedPath = await _preprocessAudio(filePath);

      // BƯỚC 2: Gọi Isolate để suy luận không làm đơ màn hình
      final result = await compute(_runWhisperInIsolate, {
        'modelDir': _modelDirPath!,
        'audioPath': filePath,
      });

      // BƯỚC 3: Dọn dẹp cả 2 file tạm ngay lập tức
      for (final path in [filePath]) {
        final f = File(path);
        if (await f.exists()) await f.delete();
      }

      return result;
    } catch (e) {
      debugPrint("❌ Lỗi stopAndTranscribe: $e");
      return null;
    }
  }

  // 5. Quản lý vòng đời (Gọi khi rời khỏi StudyScreen)
  Future<void> disposeSession() async {
    if (_micActive) {
      _micActive = false;
      await _audioRecorder.stop();
    }

    try {
      // Dọn sạch rác trong thư mục Cache
      final tempDir = await getTemporaryDirectory();
      final dir = Directory(tempDir.path);
      await for (final f in dir.list()) {
        if (f.path.contains('rec_') || f.path.contains('processed_')) {
          try {
            await f.delete();
          } catch (_) {
            debugPrint("Không thể xóa file: ${f.path}");
          }
        }
      }
    } catch (e) {
      debugPrint("Lỗi dọn cache: $e");
    }
  }
}
