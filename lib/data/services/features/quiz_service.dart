// file: lib/data/services/features/quiz_service.dart
import 'dart:math';
import '../../models/word_model.dart';
import '../database/word_service.dart';

// Ta mang QuizMode từ UI xuống đây
enum QuizMode { enToVi, viToEn, listening }

class QuizQuestion {
  final Word wordObj;
  final String correctAnswer;
  final List<String> options;

  QuizQuestion({
    required this.wordObj,
    required this.correctAnswer,
    required this.options,
  });
}

class QuizService {
  final WordService _wordService = WordService();
  final Random _random = Random();

  /// Hàm cốt lõi: Tạo bộ câu hỏi (Chạy ngầm tách biệt khỏi UI)
  /// Hàm cốt lõi: Tạo bộ câu hỏi (Chạy ngầm tách biệt khỏi UI)
  List<QuizQuestion> generateQuiz({
    required List<Word> targetWords,
    required QuizMode mode,
  }) {
    List<QuizQuestion> questions = [];
    // Lấy toàn bộ từ vựng làm kho "Đáp án nhiễu" (Global Pool)
    final allGlobalWords = _wordService.getRandomWords(9999);

    for (var word in targetWords) {
      // 1. Xác định Đáp án đúng
      String correctAnswer = (mode == QuizMode.viToEn)
          ? word.word
          : word.meaning;

      // 2. Tìm 3 đáp án sai (nhiễu) từ Global Pool
      // Lọc bỏ từ hiện tại để tránh trùng đáp án
      var possibleDistractors = allGlobalWords
          .where((w) => w.id != word.id)
          .toList();
      possibleDistractors.shuffle();

      // Lấy chính xác 3 đáp án sai
      List<String> distractors = possibleDistractors
          .take(3)
          .map((w) => (mode == QuizMode.viToEn) ? w.word : w.meaning)
          .toList();

      // 3. Trộn đáp án đúng và sai
      List<String> finalOptions = [correctAnswer, ...distractors];
      finalOptions.shuffle();

      // 4. Tạo Object câu hỏi
      questions.add(
        QuizQuestion(
          wordObj: word,
          correctAnswer: correctAnswer,
          options: finalOptions,
        ),
      );
    }

    return questions;
  }
}
