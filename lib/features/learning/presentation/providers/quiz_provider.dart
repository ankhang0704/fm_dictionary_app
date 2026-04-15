import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/features/quiz_service.dart';
import '../../../../data/services/ai_speech/text_to_speech/speech_service.dart';

class QuizProvider extends ChangeNotifier {
  final QuizService _quizService = QuizService();
  final TtsService _ttsService = TtsService();
  final WordService _wordService = WordService();

  List<QuizQuestion> _questions = [];
  int _currentIndex = 0;
  int _score = 0;
  String? _selectedAnswer;
  bool _isFinished = false;
  QuizMode _currentMode = QuizMode.enToVi;

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  bool get isFinished => _isFinished;
  QuizMode get currentMode => _currentMode;

  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  /// Khởi tạo bài Quiz từ màn hình Config
  void initQuiz(List<Word> targetWords, QuizMode mode) {
    _currentMode = mode;
    // Dùng Service để xào bài (Tránh xử lý nặng ở UI)
    _questions = _quizService.generateQuiz(
      targetWords: targetWords,
      mode: mode,
    );

    _currentIndex = 0;
    _score = 0;
    _selectedAnswer = null;
    _isFinished = false;
    notifyListeners();

    _playAudioIfListeningMode();
  }

  void _playAudioIfListeningMode() {
    if (_currentMode == QuizMode.listening && currentQuestion != null) {
      _ttsService.speak(currentQuestion!.wordObj.word, accent: 'en-US');
    }
  }

  void playCurrentAudioManually() {
    _playAudioIfListeningMode();
  }

  /// Xử lý chọn đáp án
  void checkAnswer(String answer) {
    if (_selectedAnswer != null) return;
    if (currentQuestion == null) return;

    _selectedAnswer = answer;
    bool isCorrect = (answer == currentQuestion!.correctAnswer);
    if (isCorrect) _score++;

    notifyListeners();

    // Chuyển câu hỏi sau 1.2s
    Future.delayed(const Duration(milliseconds: 1200), () async {
      if (_currentIndex < _questions.length - 1) {
        _currentIndex++;
        _selectedAnswer = null;
        _playAudioIfListeningMode();
      } else {
        _isFinished = true;

        // --- LOGIC MỚI: LƯU KẾT QUẢ QUIZ VÀO DATABASE ---
        final bool isPassed =
            _score >= (_questions.length * 0.8); // Pass nếu >= 80%
        final List<Word> wordsInQuiz = _questions
            .map((q) => q.wordObj)
            .toList();

        // Gọi WordService để cập nhật tiến độ cho toàn bộ từ trong bài test
        if (isPassed) {
          // Đánh dấu toàn bộ list từ của level này là ĐÃ THUỘC (Mastered)
          await _wordService.massMasterWords(
            _questions.map((q) => q.wordObj).toList(),
          );
        }
        await _wordService.saveQuizProgress(wordsInQuiz, isPassed);
      }
      notifyListeners();
    });
  }

  /// Reset dọn dẹp bộ nhớ
  void clearQuiz() {
    _questions.clear();
    _isFinished = false;
  }
}
