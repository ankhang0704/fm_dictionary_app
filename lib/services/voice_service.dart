import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class VoiceService {
  final AudioRecorder _audioRecorder = AudioRecorder();
  late Whisper _whisper;
  bool _isModelLoaded = false;

  // 1. Khởi tạo Model (Gọi 1 lần khi vào StudyScreen)
  Future<void> initModel() async {
    if (_isModelLoaded) return;

    try {
      final directory = await getApplicationDocumentsDirectory();
      final String dirPath = directory.path;

      final file = File("$dirPath/ggml-base.bin");

      // LOG 1: Kiểm tra file đã tồn tại chưa
      debugPrint("File exists: ${await file.exists()}");

      if (!await file.exists()) {
        debugPrint("Đang copy từ assets...");
        final data = await rootBundle.load(
          'assets/models/ggml-base.bin',
        );
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
        debugPrint("Copy xong. File size: ${await file.length()} bytes");
      }

      // LOG 2: Kiểm tra file size hợp lệ (phải > 1MB)
      final fileSize = await file.length();
      debugPrint("Model file size: $fileSize bytes");
      if (fileSize < 1000000) {
        debugPrint("LỖI: File quá nhỏ, có thể bị lỗi khi copy!");
        return;
      }

      _whisper = Whisper(model: WhisperModel.tiny, modelDir: dirPath);

      _isModelLoaded = true;
      debugPrint("✅ Model loaded thành công!");
    } catch (e) {
      debugPrint("❌ Lỗi initModel: $e");
    }
  }

  // 2. Bắt đầu ghi âm (Chuẩn 16kHz)
  Future<void> startRecording() async {
    final status = await Permission.microphone.request();
    if (status != PermissionStatus.granted) {
      throw Exception("Microphone permission denied");
    }

    final tempDir = await getTemporaryDirectory();
    final filePath = '${tempDir.path}/temp_record.wav'; // Bắt buộc đuôi .wav

    // CẤU HÌNH SỐNG CÒN CHO WHISPER
    const config = RecordConfig(
      encoder: AudioEncoder.wav,
      sampleRate: 16000, // Bắt buộc 16kHz
      numChannels: 1, // Mono
      bitRate: 16000,
    );

    await _audioRecorder.start(config, path: filePath);
  }

  // 3. Dừng ghi âm & Suy luận AI
  Future<String?> stopAndTranscribe() async {
    if (!_isModelLoaded) return "Model đang nạp, vui lòng thử lại...";

    final filePath = await _audioRecorder.stop();
    if (filePath == null) return null;

    try {
      final WhisperTranscribeResponse response = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: filePath,
          threads: 4,      // Tận dụng đa nhân CPU (Fix Lag)
          isTranslate: false,
          language: "en",  // Ép nhận diện Tiếng Anh (Tăng tốc 50%)
        ),
      );
      return response.text;
    } catch (e) {
      debugPrint("Lỗi khi AI đang dịch: $e");
      return null;
    }
  }
  // 4. Chấm điểm phát âm
  double calculateScore(String spokenText, String targetWord) {
    String cleanSpoken = spokenText.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();
    String cleanTarget = targetWord.toLowerCase().replaceAll(RegExp(r'[^\w\s]'), '').trim();

    if (cleanSpoken.isEmpty) return 0.0;

    // 1. Kiểm tra exact match trước (Nhanh và chính xác tuyệt đối)
    if (cleanSpoken == cleanTarget) return 100.0;

    // 2. Kiểm tra từ mục tiêu có nằm trong câu nói không (Whisper hay chế thêm từ thừa)
    final words = cleanSpoken.split(' ');
    if (words.contains(cleanTarget)) return 95.0; // 95 điểm vì có từ thừa nhưng đọc chuẩn từ chính

    // 3. Fallback: similarity score (Tính toán độ giống nhau)
    return cleanSpoken.similarityTo(cleanTarget) * 100;
  }

}
