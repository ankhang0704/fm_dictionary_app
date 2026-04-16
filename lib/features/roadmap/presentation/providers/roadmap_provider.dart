// lib/features/learning/presentation/providers/roadmap_provider.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';

class RoadmapLesson {
  final int globalIndex;
  final List<Word> words;
  final String dominantTopic; // Lấy topic của từ đầu tiên làm đại diện

  RoadmapLesson({required this.globalIndex, required this.words, required this.dominantTopic});
}

class RoadmapChapter {
  final int chapterIndex;
  final String title;
  final List<RoadmapLesson> lessons;

  RoadmapChapter({required this.chapterIndex, required this.title, required this.lessons});
}

class RoadmapProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  
  List<RoadmapChapter> _chapters = [];
  List<RoadmapChapter> get chapters => _chapters;

  int _selectedChapterIndex = 0;
  int get selectedChapterIndex => _selectedChapterIndex;

  bool _isLoading = true;
  bool get isLoading => _isLoading;

  RoadmapProvider() {
    _initGlobalRoadmap();
  }

  void _initGlobalRoadmap() {
    try {
      final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
      List<Word> allWords = wordBox.values.toList();
      
      // 1. Sắp xếp toàn bộ từ vựng theo Topic để các từ liên quan nằm gần nhau
      allWords.sort((a, b) => a.topic.compareTo(b.topic));

      List<RoadmapLesson> allLessons = [];
      int globalIndexCounter = 0;

      // 2. Chia nhỏ thành các Lesson (Mỗi bài CHÍNH XÁC 10 từ)
      for (var i = 0; i < allWords.length; i += 10) {
        int end = (i + 10 > allWords.length) ? allWords.length : i + 10;
        List<Word> chunk = allWords.sublist(i, end);
        
        allLessons.add(RoadmapLesson(
          globalIndex: globalIndexCounter++,
          words: chunk,
          dominantTopic: chunk.isNotEmpty ? chunk.first.topic : "General",
        ));
      }

      // 3. Chia nhỏ Lesson thành các Chapter (Mỗi chặng 10 Lesson = 100 từ)
      _chapters = [];
      int chapterCounter = 0;
      for (var i = 0; i < allLessons.length; i += 10) {
        int end = (i + 10 > allLessons.length) ? allLessons.length : i + 10;
        List<RoadmapLesson> lessonChunk = allLessons.sublist(i, end);
        
        _chapters.add(RoadmapChapter(
          chapterIndex: chapterCounter++,
          title: "Chặng ${chapterCounter}",
          lessons: lessonChunk,
        ));
      }

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      debugPrint('Lỗi khởi tạo Roadmap: $e');
      _isLoading = false;
      notifyListeners();
    }
  }

  void selectChapter(int index) {
    _selectedChapterIndex = index;
    notifyListeners();
  }

  // Khóa/Mở khóa dựa trên Index Toàn cục (Global Index)
  bool isLessonUnlocked(int globalIndex) {
    if (globalIndex == 0) return true; // Bài đầu tiên luôn mở
    
    // Tìm bài học trước đó
    final prevLesson = _getLessonByGlobalIndex(globalIndex - 1);
    if (prevLesson == null) return false;

    // Đếm số từ đã học của bài trước
    int learnedCount = prevLesson.words.where((w) => _wordService.isWordLearned(w.id)).length;
    
    // Yêu cầu học 8/10 từ (80%) để qua bài
    return learnedCount >= (prevLesson.words.length * 0.8);
  }

  // Tính tiến độ của 1 bài học nhỏ (0.0 -> 1.0)
  double getLessonProgress(int globalIndex) {
    final lesson = _getLessonByGlobalIndex(globalIndex);
    if (lesson == null || lesson.words.isEmpty) return 0.0;
    
    int learnedCount = lesson.words.where((w) => _wordService.isWordLearned(w.id)).length;
    return learnedCount / lesson.words.length;
  }

  // Hàm helper tìm Lesson
  RoadmapLesson? _getLessonByGlobalIndex(int globalIndex) {
    for (var chapter in _chapters) {
      for (var lesson in chapter.lessons) {
        if (lesson.globalIndex == globalIndex) return lesson;
      }
    }
    return null;
  }
  void refresh() {
    notifyListeners();
  }
}