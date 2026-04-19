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
  bool _isFromRoadmap = false;
  bool get isFromRoadmap => _isFromRoadmap;

  // Getters
  List<QuizQuestion> get questions => _questions;
  int get currentIndex => _currentIndex;
  int get score => _score;
  String? get selectedAnswer => _selectedAnswer;
  bool get isFinished => _isFinished;
  QuizMode get currentMode => _currentMode;
  int get passThreshold {
    int threshold = (_questions.length * 0.8).floor();
    return threshold > 0 ? threshold : 1; // Đảm bảo tối thiểu phải đúng 1 câu
  }

  QuizQuestion? get currentQuestion =>
      _questions.isNotEmpty ? _questions[_currentIndex] : null;

  /// Khởi tạo bài Quiz từ màn hình Config
  void initQuiz(
    List<Word> targetWords,
    QuizMode mode, {
    bool isFromRoadmap = false,
  }) {
    _currentMode = mode;
    _isFromRoadmap = isFromRoadmap; // Gán cờ
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
      // 1. Kiểm tra an toàn (Safety check)
      // Trong Provider không có 'mounted', nhưng có thể kiểm tra xem danh sách câu hỏi còn không
      if (_questions.isEmpty) return;

      if (_currentIndex < _questions.length - 1) {
        // LUỒNG CHƯA KẾT THÚC: Chuyển sang câu tiếp theo
        _currentIndex++;
        _selectedAnswer = null;
        _playAudioIfListeningMode();
        notifyListeners(); // Cập nhật để UI vẽ câu mới
      } else {
        // LUỒNG KẾT THÚC: Xử lý lưu trữ
        _isFinished = true;
        notifyListeners(); // Gọi ngay để UI hiện Loading hoặc màn hình Kết quả ngay lập tức

        if (_isFromRoadmap) {
          final bool isPassedResult = _score >= passThreshold; 
          final List<Word> wordsInQuiz = _questions
              .map((q) => q.wordObj)
              .toList();

          if (isPassedResult) {
            await _wordService.massMasterWords(wordsInQuiz);

            // LOGIC MỚI: Truyền toàn bộ danh sách ID của Quiz vào
            final List<String> quizWordIds = wordsInQuiz
                .map((w) => w.id)
                .toList();
            await _wordService.addWordsToDailyGoal(quizWordIds);
          }
          await _wordService.saveQuizProgress(wordsInQuiz, isPassedResult);

          notifyListeners();
        }
      }
    });
  }

  /// Reset dọn dẹp bộ nhớ
  void clearQuiz() {
    _questions = [];
    _currentIndex = 0;
    _score = 0;
    _isFinished = false; // Reset ngay lập tức
    _selectedAnswer = null;
    // Không notify ở đây nếu bạn chuẩn bị gọi initQuiz ngay sau đó để tránh nháy màn hình
    notifyListeners();
  }
}
