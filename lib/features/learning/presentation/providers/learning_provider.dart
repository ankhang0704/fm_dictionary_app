import 'dart:async';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/progress_keys.dart';
import 'package:fm_dictionary/core/di/service_locator.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/word_service.dart';
import '../../../../data/services/ai_speech/text_to_speech/speech_service.dart';
import '../../../../data/services/ai_speech/ai_assistant/ai_assistant_service.dart';
import '../../../../data/services/ai_speech/ai_assistant/pronunciation_scorer.dart';

class LearningProvider extends ChangeNotifier {
  final WordService _wordService = WordService();
  final TtsService _ttsService = TtsService();

  //Streak
  int _currentStreak = 0;
  Set<DateTime> _studyDates = {};
  int _masteredWords = 0;
  int _totalWords = 0;
  int get masteredWords => _masteredWords;
  int get totalWords => _totalWords;
  int get currentStreak => _currentStreak;
  Set<DateTime> get studyDates => _studyDates;

  void loadLearningData() {
    _currentStreak = _wordService.getCurrentStreak();
    _studyDates = _wordService.getStudyDates();

    _masteredWords = _wordService.getTotalMasteredWords();
    _totalWords = _wordService.getTotalWordsCount();
    notifyListeners();
  }
  // State
  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isFlipped = false;

  // AI & Recording State
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _spokenText = "";
  double? _pronunciationScore;
  int _timeRemaining = 5;
  Timer? _recordingTimer;

  // Getters
  List<Word> get words => _words;
  int get currentIndex => _currentIndex;
  bool get isLoading => _isLoading;
  bool get isFlipped => _isFlipped;
  bool get isRecording => _isRecording;
  bool get isAnalyzing => _isAnalyzing;
  String get spokenText => _spokenText;
  double? get pronunciationScore => _pronunciationScore;
  int get timeRemaining => _timeRemaining;

  Word? get currentWord => _words.isNotEmpty ? _words[_currentIndex] : null;
  bool get isCurrentWordSaved => currentWord != null ? _wordService.isWordSaved(currentWord!.id) : false;

  LearningProvider() {
    loadLearningData();
    sl<AiAssistantService>().initModel();
  }

  void loadWords(String topic) {
    _isLoading = true;
    notifyListeners();

    final allTopicWords = topic == 'Review'
        ? _wordService.getWordsToReview()
        : _wordService.getWordsByTopic(topic);

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    _words = allTopicWords.where((w) {
      final progress = _wordService.getWordProgress(w.id);
      final nextReview = progress[ProgressKeys.nextReview] as int;
      final step = progress[ProgressKeys.step] as int;
      return nextReview <= nowMs || step < 4;
    }).toList();

    if (_words.isEmpty) {
      _words = List.from(allTopicWords);
    }
    _words.shuffle();
    
    _isLoading = false;
    notifyListeners();
  }

  void toggleFlip() {
    _isFlipped = !_isFlipped;
    notifyListeners();
  }

  Future<void> toggleSave() async {
    if (currentWord == null) return;
    await _wordService.toggleSaveWord(currentWord!.id);
    notifyListeners(); // UI sẽ update icon tim/bookmark realtime
  }

  void playAudio(String accent) {
    if (currentWord != null) {
      _ttsService.speak(currentWord!.word, accent: accent);
    }
  }

  // --- Logic Navigation (Back/Next) ---
  void previousCard() {
    if (_currentIndex > 0) {
      _currentIndex--;
      _resetCardState();
      notifyListeners();
    }
  }

  void nextCard() {
    if (_currentIndex < _words.length - 1) {
      _currentIndex++;
      _resetCardState();
      notifyListeners();
    }
  }

  void _resetCardState() {
    _isFlipped = false;
    _spokenText = "";
    _pronunciationScore = null;
    _isRecording = false;
    _isAnalyzing = false;
    sl<AiAssistantService>().disposeSession();
  }

  // --- Logic Anki (Xử lý kết quả) ---
  Future<bool> processAnswer(bool isCorrect, bool isEasy) async {
    if (currentWord == null) return false;

    final int streakBefore = _currentStreak;

    if (!isCorrect) {
      await _wordService.updateProgress(currentWord!.id, false);
    } else if (isEasy) {
      await _wordService.markAsLearned(currentWord!.id);
    } else {
      await _wordService.updateProgress(currentWord!.id, true);
    }
  
    loadLearningData(); 

    bool showCelebration = (_currentStreak > streakBefore && _currentStreak > 0);

    // Chuyển thẻ tự động
    if (_currentIndex < _words.length - 1) {
      nextCard();
    }
    
    return showCelebration;
  }
  void loadWordsFromLesson(List<Word> lessonWords) {
    _isLoading = true;
    notifyListeners();

    // Copy list để không làm ảnh hưởng list gốc
    _words = List.from(lessonWords);
    
    // Tùy chọn: Xào bài để học đỡ chán
    _words.shuffle();
    
    _currentIndex = 0;
    _resetCardState();
    
    _isLoading = false;
    notifyListeners();
  }

  // --- AI Recording Logic (Giữ nguyên như cũ nhưng bỏ setState) ---
  void startRecording() async {
    try {
      _recordingTimer?.cancel();
      _timeRemaining = 5;
      _isRecording = true;
      notifyListeners();
      await sl<AiAssistantService>().startRecording();

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        if (_timeRemaining > 1) {
          _timeRemaining--;
          notifyListeners();
        } else {
          timer.cancel();
          stopRecording();
        }
      });
    } catch (e) {
      debugPrint("Lỗi ghi âm: $e");
    }
  }

  void stopRecording() async {
    _recordingTimer?.cancel();
    if (!_isRecording || _isAnalyzing || currentWord == null) return;

    _isRecording = false;
    _isAnalyzing = true;
    notifyListeners();

    try {
      final text = await sl<AiAssistantService>().stopAndTranscribe();
      if (text != null) {
        final result = PronunciationScorer.evaluate(text, currentWord!.word);
        _spokenText = text;
        _pronunciationScore = result.score;

        // Cập nhật điểm số vào database
        await _wordService.updatePronunciationScore(currentWord!.id, result.score);
      }
    } catch (e) {
      debugPrint("Lỗi AI: $e");
    } finally {
      _isAnalyzing = false;
      notifyListeners();
    }
  }

  @override
  void dispose() {
    _recordingTimer?.cancel();
    sl<AiAssistantService>().disposeSession();
    super.dispose();
  }
}