import 'package:fm_dictionary/data/models/app_settings.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:string_similarity/string_similarity.dart';

// Model chứa kết quả chi tiết
class PronunciationResult {
  final double score;
  final String feedback;
  final String level; // 'excellent' | 'good' | 'retry'
  final String? closestWord;

  const PronunciationResult({
    required this.score,
    required this.feedback,
    required this.level,
    this.closestWord,
  });
}

class PronunciationScorer {
  static PronunciationResult evaluate(String spokenText, String targetWord) {
    final AppSettings settings = DatabaseService.getSettings();
    final bool isHardMode = settings.isHardMode;
    final cleanSpoken = spokenText
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();
    final cleanTarget = targetWord
        .toLowerCase()
        .replaceAll(RegExp(r'[^\w\s]'), '')
        .trim();

    // 1. Xử lý ngoại lệ không có âm thanh
    if (cleanSpoken.isEmpty) {
      return const PronunciationResult(
        score: 0,
        feedback: "Không nhận được âm thanh",
        level: 'retry',
      );
    }

    // 2. Exact match (Khớp hoàn toàn)
    if (cleanSpoken == cleanTarget) {
      return const PronunciationResult(
        score: 100,
        feedback: "Hoàn hảo!",
        level: 'excellent',
      );
    }

    // 3. Tìm từ gần đúng nhất (Whisper hay thêm từ rác)
    final words = cleanSpoken.split(RegExp(r'\s+'));
    double bestScore = 0;
    String? bestMatch;

    for (final word in words) {
      final sim = word.similarityTo(cleanTarget) * 100;
      if (sim > bestScore) {
        bestScore = sim;
        bestMatch = word;
      }
    }

    // 4. Phân tầng phản hồi (Tiered Feedback)
    if (isHardMode) {
      // --- HARD MODE (Mặc định) ---
      if (bestScore >= 90) {
        return PronunciationResult(
          score: bestScore,
          feedback: "Rất tốt! Phát âm chuẩn xác.",
          level: 'excellent',
          closestWord: bestMatch,
        );
      } else if (bestScore >= 70) {
        return PronunciationResult(
          score: bestScore,
          feedback: "Khá tốt, hãy chú ý âm cuối.",
          level: 'good',
          closestWord: bestMatch,
        );
      } else {
        return PronunciationResult(
          score: bestScore,
          feedback: "Chưa khớp — hãy nghe lại.",
          level: 'retry',
          closestWord: bestMatch,
        );
      }
    } else {
      // --- EASY MODE (Người mới) ---
      // Chỉ cần > 60% là cho Đạt (Excellent)
      if (bestScore >= 60) {
        return PronunciationResult(
          score: bestScore,
          feedback: "Tuyệt vời! Bạn đã bắt được trọng âm.",
          level: 'excellent', // Cho excellent luôn để khích lệ
          closestWord: bestMatch,
        );
      } else {
        return PronunciationResult(
          score: bestScore,
          feedback: "Hãy thử đọc to và rõ hơn chút nhé.",
          level: 'retry',
          closestWord: bestMatch,
        );
      }
    }
  }
}
