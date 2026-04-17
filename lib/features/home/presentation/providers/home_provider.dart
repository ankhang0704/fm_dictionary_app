// Đường dẫn: lib/features/home/presentation/providers/home_provider.dart

import 'dart:math';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:hive/hive.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/word_service.dart';
import '../../../../core/constants/constants.dart';

class HomeProvider extends ChangeNotifier {
  final WordService _wordService = WordService();

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  String _quote = "";
  String get quote => _quote;

  final int _dailyGoalTarget   = 20;
  int get dailyGoalTarget => _dailyGoalTarget;

  int _wordsLearnedToday = 0;
  int get wordsLearnedToday => _wordsLearnedToday;

  double get dailyProgressPercent =>
      dailyGoalTarget == 0 ? 0 : (wordsLearnedToday / dailyGoalTarget).clamp(0.0, 1.0);

  Word? _wordOfTheDay;
  Word? get wordOfTheDay => _wordOfTheDay;

  List<String> _recommendedTopics = [];
  List<String> get recommendedTopics => _recommendedTopics;

  int _currentStreak = 0;
  int get currentStreak => _currentStreak;

  HomeProvider() {
    _initDashboard();
  }

  Future<void> _initDashboard() async {
    _isLoading = true;
    notifyListeners();

    // 1. Lấy Quote ngẫu nhiên
    final random = Random();
    _quote =
        AppConstants.motivationalSlogans[random.nextInt(
          AppConstants.motivationalSlogans.length,
        )];

    // 2. Lấy Word of the Day (Lấy random 1 từ chưa học)
    final allWords = _wordService.getRandomWords(50); // Lấy tạm 50 từ
    try {
      _wordOfTheDay = allWords.firstWhere(
        (w) => !_wordService.isWordLearned(w.id),
      );
    } catch (_) {
      _wordOfTheDay = allWords.isNotEmpty ? allWords.first : null;
    }

    // 3. Tính số từ đã học hôm nay (Mock logic - bạn có thể tinh chỉnh trong WordService sau)
    // Tạm thời set random hoặc lấy số liệu thật từ WordService
    _wordsLearnedToday = _wordService.getQuickDailyCount();

    // 4. Lấy 2 chủ đề chưa học
    final allTopics = _wordService.getAllTopics();
    _recommendedTopics = allTopics.take(2).toList();

    // 5. Lấy Streak
    _currentStreak = _wordService.getCurrentStreak();

    _isLoading = false;
    notifyListeners();
  }

  List<Word> getWordsByTopicName(String topicName) {
    return _wordService.getWordsByTopic(topicName);
  }

  List<Word> getWordsForNextLesson() {
    final topics = _wordService.getAllTopics();

    for (var topic in topics) {
      final wordsInTopic = _wordService.getWordsByTopic(topic);
      // Lọc ra những từ chưa học trong chủ đề này
      final unlearnedWords = wordsInTopic
          .where((w) => !_wordService.isWordLearned(w.id))
          .toList();

      if (unlearnedWords.isNotEmpty) {
        return unlearnedWords; // Trả về danh sách từ chưa học của chủ đề này
      }
    }

    // Nếu tất cả đã học hết, trả về toàn bộ từ của chủ đề đầu tiên để ôn tập chẳng hạn
    return topics.isNotEmpty ? _wordService.getWordsByTopic(topics.first) : [];
  }

  int getMistakesCount() => _wordService.getWordsToReview().length;

  // --- LOGIC TỪ SIDEBARS ---
  Set<DateTime> getStudyDates() => _wordService.getStudyDates();
  int getCurrentStreak() => _wordService.getCurrentStreak();

  // Logic kiểm tra số lượng từ cần ôn tập
  int getReviewCount() {
    return _wordService.getWordsToReview().length;
  }
  //  TÍNH SỐ TỪ ĐÃ HỌC TRONG NGÀY HÔM NAY
  // Gọi hàm này trong initDashboard hoặc refresh
  void updateDailyProgress() {
    _wordsLearnedToday = _wordService.getQuickDailyCount();
    notifyListeners();
  }
  // Reload lại data khi user đi học về
  void refresh() {
    _initDashboard();
  }
}
