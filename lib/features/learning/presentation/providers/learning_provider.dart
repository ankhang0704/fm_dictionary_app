// Đường dẫn: lib/features/learning/presentation/providers/learning_provider.dart

import 'package:flutter/material.dart';
import '../../../../data/services/database/word_service.dart';

class LearningProvider extends ChangeNotifier {
  final WordService _wordService = WordService(); // Có thể dùng GetIt ở đây sau này

  int _currentStreak = 0;
  Set<DateTime> _studyDates = {};

  int get currentStreak => _currentStreak;
  Set<DateTime> get studyDates => _studyDates;

  LearningProvider() {
    loadLearningData();
  }

  void loadLearningData() {
    _currentStreak = _wordService.getCurrentStreak();
    _studyDates = _wordService.getStudyDates();
    notifyListeners();
  }
}