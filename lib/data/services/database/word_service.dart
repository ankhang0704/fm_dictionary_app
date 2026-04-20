import 'dart:async';

import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/progress_keys.dart';
import 'package:hive/hive.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../models/word_model.dart';
import 'database_service.dart';

class WordService {
  final _wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
  final _progressBox = Hive.box(DatabaseService.progressBoxName); // Box mới
  List<Word>? _reviewCache;
  DateTime? _reviewCacheTime;
  static const int _msPerDay = 86400000; // Số mili-giây trong 1 ngày

  // 1. LẤY TIẾN ĐỘ CỦA 1 TỪ (Tự khởi tạo nếu chưa học)
  Map<String, dynamic> getWordProgress(String wordId) {
    final rawData = _progressBox.get(wordId);
    if (rawData is Map) {
      return Map<String, dynamic>.from(rawData);
    }
    // Log lỗi data corruption nếu rawData != null && rawData is! Map
    if (rawData != null) {
      debugPrint(
        '⚠️ Corrupt progress data for $wordId: ${rawData.runtimeType}',
      );
      _progressBox.delete(wordId); // Auto-heal: xóa data hỏng
    }
    // Giá trị mặc định cho từ mới hoàn toàn
    return {
      ProgressKeys.step: 0, // step
      ProgressKeys.wrongCount: 0, // wrongCount
      ProgressKeys.lastReview: 0, // lastReview (0 = chưa học)
      ProgressKeys.nextReview: 0, // nextReview (0 = học ngay lập tức)
    };
  }

  // 2. THUẬT TOÁN ANKI (Cập nhật tiến độ)
  Future<void> updateProgress(String wordId, bool isCorrect) async {
    Map<String, dynamic> progress = await getWordProgress(wordId);
    final int now = DateTime.now().millisecondsSinceEpoch;

    progress[ProgressKeys.lastReview] = now; // Cập nhật lần học cuối
    progress[ProgressKeys.updatedAt] = now;

    if (!isCorrect) {
      // TRẢ LỜI SAI:   Reset step, học lại ngay, tăng wrongCount
      progress[ProgressKeys.step] = 0;
      progress[ProgressKeys.wrongCount] =
          (progress[ProgressKeys.wrongCount] as int) + 1;
      progress[ProgressKeys.nextReview] = now;
    } else {
      // TRẢ LỜI ĐÚNG: Tăng step, tính ngày học tiếp theo
      int step = (progress[ProgressKeys.step] as int) + 1;
      progress[ProgressKeys.step] = step;

      int daysToAdd;
      if (step == 1) {
        daysToAdd = 1;
      } else if (step == 2) {
        daysToAdd = 3;
      } else if (step == 3) {
        daysToAdd = 7;
      } else {
        daysToAdd = 30; // Step 4 trở lên: 30 ngày (Đã thuộc)
      }

      progress[ProgressKeys.nextReview] = now + (daysToAdd * _msPerDay);
    }

    // Ghi đè vào DB
    try {
      await _progressBox.put(wordId, progress);
    } on HiveError catch (e) {
      debugPrint('❌ DB write failed for $wordId: $e');
      rethrow; // Ném lên cho ViewModel/Provider xử lý
    }
    invalidateCache();
  }
  void invalidateCache() { _reviewCache = null; }
  // 3. ĐÁNH DẤU ĐÃ THUỘC (Manual Learn)
  Future<void> markAsLearned(String wordId) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    // Lấy progress hiện tại để không làm mất ProgressKeys.wrongCount (wrongCount)
    Map<String, dynamic> progress = await getWordProgress(wordId);

    progress[ProgressKeys.step] = 4;
    progress[ProgressKeys.lastReview] = now;
    progress[ProgressKeys.nextReview] = now + (30 * _msPerDay); // +30 ngày
    progress[ProgressKeys.updatedAt] = now;

    await _progressBox.put(wordId, progress);
  }

  // 4. LẤY DANH SÁCH TỪ CẦN ÔN TẬP (Quét theo Epoch Time)
  List<Word> getWordsToReview() {
    final now = DateTime.now();
    if (_reviewCache != null &&
        _reviewCacheTime != null &&
        now.difference(_reviewCacheTime!).inSeconds < 60) {
      return _reviewCache!;
    }
    List<Word> reviewList = [];

    // Duyệt qua tất cả các key (wordId) đã có tiến độ
    for (var wordId in _progressBox.keys) {
      final progress = getWordProgress(wordId as String);
      final nextReview = progress[ProgressKeys.nextReview] as int;

      // Nếu nextReview <= thời điểm hiện tại -> Cần ôn tập
      if (nextReview <= now.millisecondsSinceEpoch) {
        final word = _wordBox.get(wordId);
        if (word != null) {
          reviewList.add(word);
        }
      }
    }
    _reviewCache = reviewList;
    _reviewCacheTime = now;
    return reviewList;
  }

  // --- CÁC HÀM CƠ BẢN GIỮ NGUYÊN ---
  List<Word> getWordsByTopic(String topic) {
    return _wordBox.values.where((w) => w.topic == topic).toList();
  }

  List<Word> searchWords(String query) {
    if (query.isEmpty) return [];
    final lowercaseQuery = query.toLowerCase();
    return _wordBox.values.where((word) {
      return word.word.toLowerCase().contains(lowercaseQuery) ||
          word.meaning.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }

  List<Word> getRandomWords(int count) {
    final allWords = _wordBox.values.toList();
    if (allWords.isEmpty) return [];
    allWords.shuffle();
    return allWords.take(count).toList();
  }

  List<String> getAllTopics() {
    return _wordBox.values.map((w) => w.topic).toSet().toList();
  }

  bool isWordLearned(String wordId) {
    final progress = getWordProgress(wordId);
    return (progress[ProgressKeys.step] as int) >=
        4; // Step 4 trở lên là đã thuộc lòng
  }

  Set<DateTime> getStudyDates() {
    final box = Hive.box(DatabaseService.progressBoxName);
    final Set<DateTime> studyDates = {};

    for (var value in box.values) {
      final map = value as Map;
      final int lr = map[ProgressKeys.lastReview] ?? 0;
      final int ua = map[ProgressKeys.updatedAt] ?? 0;

      // Lấy mốc thời gian lớn nhất giữa Lần học cuối (lr) và Lần cập nhật (ua)
      final int latestActivity = lr > ua ? lr : ua;

      if (latestActivity > 0) {
        final date = DateTime.fromMillisecondsSinceEpoch(latestActivity);
        // TỐI ƯU: Ép về đúng 00:00:00 của ngày đó để TableCalendar so sánh dễ dàng (Tránh lỗi do lệch giờ/phút)
        studyDates.add(DateTime(date.year, date.month, date.day));
      }
    }
    return studyDates;
  }

  int getCurrentStreak() {
    final Set<DateTime> datesSet = getStudyDates();
    if (datesSet.isEmpty) return 0;

    // Chuyển Set thành List và sắp xếp giảm dần (từ ngày gần nhất về quá khứ)
    final List<DateTime> sortedDates = datesSet.toList()
      ..sort((a, b) => b.compareTo(a));

    final DateTime now = DateTime.now();
    final DateTime today = DateTime(now.year, now.month, now.day);
    final DateTime yesterday = today.subtract(const Duration(days: 1));

    int streak = 0;
    DateTime checkDate = today;

    // Kịch bản 1: Nếu hôm nay chưa học, và hôm qua cũng không học -> Mất chuỗi
    if (!sortedDates.contains(today) && !sortedDates.contains(yesterday)) {
      return 0;
    }

    // Kịch bản 2: Bắt đầu đếm chuỗi
    // Nếu hôm nay chưa học nhưng hôm qua đã học -> Chuỗi vẫn giữ nguyên, checkDate dời về hôm qua
    if (!sortedDates.contains(today) && sortedDates.contains(yesterday)) {
      checkDate = yesterday;
    }

    // Đếm ngược về quá khứ xem liên tiếp được bao nhiêu ngày
    while (sortedDates.contains(checkDate)) {
      streak++;
      checkDate = checkDate.subtract(
        const Duration(days: 1),
      ); // Lùi về 1 ngày trước
    }

    return streak;
  }

  Future<void> saveQuizProgress(List<Word> wordsInQuiz, bool isPassed) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    for (var word in wordsInQuiz) {
      Map<String, dynamic> progress = await getWordProgress(word.id);

      progress[ProgressKeys.lastReview] = now; // Cập nhật lần tương tác cuối
      progress[ProgressKeys.updatedAt] = now;

      if (isPassed) {
        // Nếu PASS bài test: Thưởng tiến độ (Coi như nhấn nút Dễ/Nhớ)
        int currentStep = progress[ProgressKeys.step] as int;
        if (currentStep < 4) {
          progress[ProgressKeys.step] = currentStep + 1; // Tăng level
        }

        // Tính ngày ôn tập tiếp theo
        int daysToAdd = (progress[ProgressKeys.step] == 1)
            ? 1
            : (progress[ProgressKeys.step] == 2)
            ? 3
            : (progress[ProgressKeys.step] == 3)
            ? 7
            : 30;
        progress[ProgressKeys.nextReview] = now + (daysToAdd * _msPerDay);
      } else {
        // Nếu FAIL bài test: Ghi nhận số lần sai để ưu tiên học lại
        progress[ProgressKeys.wrongCount] =
            (progress[ProgressKeys.wrongCount] as int) + 1;
        // Không hạ step thẳng tay để đỡ nản, chỉ bắt ôn lại sớm hơn
        progress[ProgressKeys.nextReview] = now;
      }
      await _progressBox.put(word.id, progress);
    }
  }

  // === TÍNH NĂNG LƯU TỪ VỰNG (SAVED WORDS) ===
  bool isWordSaved(String wordId) {
    final progress = _progressBox.get(wordId);
    if (progress == null || progress is! Map) return false;
    return (progress[ProgressKeys.isSaved] ?? 0) == 1;
  }

  Future<void> toggleSaveWord(String wordId) async {
    var raw = _progressBox.get(wordId);
    Map<String, dynamic> progress;

    if (raw == null || raw is! Map) {
      // Tái sử dụng getWordProgress để có auto-heal logic
      progress = getWordProgress(wordId);
      progress[ProgressKeys.isSaved] = 1;
    } else {
      progress = Map<String, dynamic>.from(raw as Map);
      int currentSv = (progress[ProgressKeys.isSaved] ?? 0) as int;
      progress[ProgressKeys.isSaved] = currentSv == 1 ? 0 : 1;
    }
    progress[ProgressKeys.updatedAt] = DateTime.now().millisecondsSinceEpoch;
    await _progressBox.put(wordId, progress);
  }

  // Hàm lấy danh sách TẤT CẢ các từ đã lưu (Để hiển thị ở màn SavedScreen)
  List<Word> getSavedWords() {
    final progressBox = Hive.box(DatabaseService.progressBoxName);
    final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);

    List<Word> savedWords = [];

    for (var key in progressBox.keys) {
      final p = progressBox.get(key) as Map;
      if ((p[ProgressKeys.isSaved] ?? 0) == 1) {
        final word = wordBox.get(key);
        if (word != null) savedWords.add(word);
      }
    }
    return savedWords;
  }

  // === TÍNH NĂNG LỊCH SỬ (HISTORY) ===
  List<Word> getHistoryWords() {
    List<Word> historyList = [];
    final Map<String, int> lastActivityCache =
        {}; // Dùng Cache để sort siêu tốc

    for (var wordId in _progressBox.keys) {
      final progress = getWordProgress(wordId as String);
      final int lr = progress[ProgressKeys.lastReview] as int;
      final int ua = (progress[ProgressKeys.updatedAt] ?? 0) as int;

      if (lr > 0 || ua > 0) {
        final word = _wordBox.get(wordId);
        if (word != null) {
          historyList.add(word);
          // Cache lại thời gian hoạt động cuối cùng của từ này
          lastActivityCache[wordId] = lr > ua ? lr : ua;
        }
      }
    }

    // Sort O(1) read thay vì gọi Hive liên tục
    historyList.sort(
      (a, b) => (lastActivityCache[b.id] ?? 0).compareTo(
        lastActivityCache[a.id] ?? 0,
      ),
    );
    return historyList;
  }

  // Hàm lưu điểm phát âm
  Future<void> updatePronunciationScore(String wordId, double newScore) async {
    Map<String, dynamic> progress = await getWordProgress(wordId);

    double currentScore = (progress[ProgressKeys.pronunciationScore] ?? 0.0)
        .toDouble();
    int count = (progress[ProgressKeys.pronunciationCount] ?? 0) as int;

    // Thuật toán tính trung bình cộng tích lũy
    double updatedScore = ((currentScore * count) + newScore) / (count + 1);

    progress[ProgressKeys.pronunciationScore] = updatedScore;
    progress[ProgressKeys.pronunciationCount] = count + 1;
    progress[ProgressKeys.updatedAt] = DateTime.now().millisecondsSinceEpoch;

    await _progressBox.put(wordId, progress);
  }

  // Hàm ép buộc thuộc toàn bộ list từ (Dùng khi pass Quiz 80%)
  Future<void> massMasterWords(List<Word> words) async {
    for (var w in words) {
      await markAsLearned(w.id);
    }
  }

  int getWordsStudiedCount(DateTime date) {
    final startOfDay = DateTime(
      date.year,
      date.month,
      date.day,
    ).millisecondsSinceEpoch;
    final endOfDay = DateTime(
      date.year,
      date.month,
      date.day,
      23,
      59,
      59,
    ).millisecondsSinceEpoch;

    return _progressBox.values.where((value) {
      if (value is! Map) return false;
      final int updatedAt = (value[ProgressKeys.updatedAt] ?? 0) as int;
      return updatedAt >= startOfDay && updatedAt <= endOfDay;
    }).length;
  }

  // Thêm tham số amount vào hàm hiện tại của bạn trong WordService
  Future<void> addWordsToDailyGoal(List<String> wordIds) async {
    final box = Hive.box(DatabaseService.saveBoxName); // Dùng tạm box này ok

    final today = DateTime.now();
    final key = 'stats_ids_${today.year}_${today.month}_${today.day}';

    List<String> existingIds =
        box.get(key, defaultValue: <String>[])?.cast<String>() ?? [];

    Set<String> uniqueIds = existingIds.toSet();
    uniqueIds.addAll(wordIds);
    await box.put(key, uniqueIds.toList()); // Cộng lượng từ mới vào
    
  final prefs = await SharedPreferences.getInstance(); // hoặc dùng biến static
  final lastCleanup = prefs.getString('last_cleanup_date') ?? '';
  final today1 = DateTime.now().toIso8601String().substring(0, 10);
  if (lastCleanup != today1) {
    await prefs.setString('last_cleanup_date', today1);
    unawaited(cleanUpOldDailyStats().catchError((e) => debugPrint('Cleanup failed: $e')));
  }
  }

  // 2. Hàm lấy số lượng siêu nhanh (Không cần vòng lặp)
  int getQuickDailyCount() {
    final box = Hive.box<dynamic>(DatabaseService.saveBoxName);
    final today = DateTime.now();
    final key = 'stats_ids_${today.year}_${today.month}_${today.day}';

    // Đếm số lượng ID duy nhất
    List<String> existingIds =
        box.get(key, defaultValue: <String>[])?.cast<String>() ?? [];
    return existingIds.length;
  }

  Future<void> cleanUpOldDailyStats() async {
    final box = Hive.box(DatabaseService.saveBoxName);
    final keys = box.keys
        .where((k) => k.toString().startsWith('stats_ids_'))
        .toList();
    final now = DateTime.now();

    for (var key in keys) {
      try {
        final parts = key.toString().split(
          '_',
        ); // Dạng: [stats, ids, YYYY, MM, DD]
        if (parts.length == 5) {
          final recordDate = DateTime(
            int.parse(parts[2]),
            int.parse(parts[3]),
            int.parse(parts[4]),
          );

          // Nếu dữ liệu cũ hơn 7 ngày -> Xóa
          if (now.difference(recordDate).inDays > 7) {
            await box.delete(key);
          }
        }
      } catch (_) {
        // Bỏ qua nếu lỗi parse ngày
      }
    }
  }
}
