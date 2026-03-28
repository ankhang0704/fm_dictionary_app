import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:path_provider/path_provider.dart';
import 'package:record/record.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:string_similarity/string_similarity.dart';
import 'package:whisper_flutter_new/whisper_flutter_new.dart';

class VoiceService {
  // Singleton pattern
  VoiceService._();
  static final VoiceService instance = VoiceService._();

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

      if (!await file.exists()) {
        final data = await rootBundle.load('assets/models/ggml-base.bin');
        await file.writeAsBytes(data.buffer.asUint8List(), flush: true);
      }

      final fileSize = await file.length();
      if (fileSize < 1000000) return;

      _whisper = Whisper(model: WhisperModel.tiny, modelDir: dirPath);
      _isModelLoaded = true;
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
    if (!_isModelLoaded) {
      await _audioRecorder.stop();
      return null;
    }

    final filePath = await _audioRecorder.stop();
    if (filePath == null) return null;

    try {
      // TỐI ƯU 1: Ép ngôn ngữ tiếng Anh & dùng đa luồng
      final WhisperTranscribeResponse response = await _whisper.transcribe(
        transcribeRequest: TranscribeRequest(
          audio: filePath,
          threads: 4,
          isTranslate: false,
          language: "en", // Tăng tốc độ dịch lên 30-50%
        ),
      );
      final file = File(filePath);
      if (await file.exists()) {
        await file.delete();
      }
      return response.text;
    } catch (e) {
      return null;
    }
  }

  double calculateScore(String spokenText, String targetWord) {
    String cleanSpoken = spokenText
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
    String cleanTarget = targetWord
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();

    if (cleanSpoken.isEmpty) return 0.0;
    if (cleanSpoken == cleanTarget) return 100.0;

    final words = cleanSpoken.split(' ');
    if (words.contains(cleanTarget)) return 95.0; // Whisper hay thêm từ rác

    return cleanSpoken.similarityTo(cleanTarget) * 100;
  }

}
