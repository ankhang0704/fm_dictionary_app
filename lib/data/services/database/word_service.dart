import 'package:hive/hive.dart';
import '../../models/word_model.dart';
import 'database_service.dart';

class WordService {
  final _wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
  final _progressBox = Hive.box(DatabaseService.progressBoxName); // Box mới
  final _savedBox = Hive.box(DatabaseService.saveBoxName);

  static const int _msPerDay = 86400000; // Số mili-giây trong 1 ngày

  // 1. LẤY TIẾN ĐỘ CỦA 1 TỪ (Tự khởi tạo nếu chưa học)
  Map<String, dynamic> getWordProgress(String wordId) {
    final rawData = _progressBox.get(wordId);
    if (rawData != null) {
      // Ép kiểu an toàn từ Hive Map sang Dart Map
      return Map<String, dynamic>.from(rawData as Map);
    }
    // Giá trị mặc định cho từ mới hoàn toàn
    return {
      's': 0, // step
      'wc': 0, // wrongCount
      'lr': 0, // lastReview (0 = chưa học)
      'nr': 0, // nextReview (0 = học ngay lập tức)
    };
  }

  // 2. THUẬT TOÁN ANKI (Cập nhật tiến độ)
  Future<void> updateProgress(String wordId, bool isCorrect) async {
    Map<String, dynamic> progress = getWordProgress(wordId);
    final int now = DateTime.now().millisecondsSinceEpoch;

    progress['lr'] = now; // Cập nhật lần học cuối
    progress['ua'] = now;

    if (!isCorrect) {
      // TRẢ LỜI SAI:   Reset step, học lại ngay, tăng wrongCount
      progress['s'] = 0;
      progress['wc'] = (progress['wc'] as int) + 1;
      progress['nr'] = now;
    } else {
      // TRẢ LỜI ĐÚNG: Tăng step, tính ngày học tiếp theo
      int step = (progress['s'] as int) + 1;
      progress['s'] = step;

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

      progress['nr'] = now + (daysToAdd * _msPerDay);
    }

    // Ghi đè vào DB
    await _progressBox.put(wordId, progress);
  }

  // 3. ĐÁNH DẤU ĐÃ THUỘC (Manual Learn)
  Future<void> markAsLearned(String wordId) async {
    final int now = DateTime.now().millisecondsSinceEpoch;

    // Lấy progress hiện tại để không làm mất 'wc' (wrongCount)
    Map<String, dynamic> progress = getWordProgress(wordId);

    progress['s'] = 4;
    progress['lr'] = now;
    progress['nr'] = now + (30 * _msPerDay); // +30 ngày
    progress['ua'] = now;

    await _progressBox.put(wordId, progress);
  }

  // 4. LẤY DANH SÁCH TỪ CẦN ÔN TẬP (Quét theo Epoch Time)
  List<Word> getWordsToReview() {
    final int now = DateTime.now().millisecondsSinceEpoch;
    List<Word> reviewList = [];

    // Duyệt qua tất cả các key (wordId) đã có tiến độ
    for (var wordId in _progressBox.keys) {
      final progress = getWordProgress(wordId as String);
      final nextReview = progress['nr'] as int;

      // Nếu nextReview <= thời điểm hiện tại -> Cần ôn tập
      if (nextReview <= now) {
        final word = _wordBox.get(wordId);
        if (word != null) {
          reviewList.add(word);
        }
      }
    }
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
    return (progress['s'] as int) >= 4; // Step 4 trở lên là đã thuộc lòng
  }

  Set<DateTime> getStudyDates() {
    final box = Hive.box(DatabaseService.progressBoxName);
    final Set<DateTime> studyDates = {};

    for (var value in box.values) {
      final map = value as Map;
      final int lr = map['lr'] ?? 0;
      final int ua = map['ua'] ?? 0;

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
      Map<String, dynamic> progress = getWordProgress(word.id);

      progress['lr'] = now; // Cập nhật lần tương tác cuối
      progress['ua'] = now;

      if (isPassed) {
        // Nếu PASS bài test: Thưởng tiến độ (Coi như nhấn nút Dễ/Nhớ)
        int currentStep = progress['s'] as int;
        if (currentStep < 4) {
          progress['s'] = currentStep + 1; // Tăng level
        }

        // Tính ngày ôn tập tiếp theo
        int daysToAdd = (progress['s'] == 1)
            ? 1
            : (progress['s'] == 2)
            ? 3
            : (progress['s'] == 3)
            ? 7
            : 30;
        progress['nr'] = now + (daysToAdd * _msPerDay);
      } else {
        // Nếu FAIL bài test: Ghi nhận số lần sai để ưu tiên học lại
        progress['wc'] = (progress['wc'] as int) + 1;
        // Không hạ step thẳng tay để đỡ nản, chỉ bắt ôn lại sớm hơn
        progress['nr'] = now;
      }

      await _progressBox.put(word.id, progress);
    }
  }

  // === TÍNH NĂNG LƯU TỪ VỰNG (SAVED WORDS) ===
  bool isWordSaved(String wordId) {
    return _savedBox.containsKey(wordId);
  }

  Future<void> toggleSaveWord(String wordId) async {
    if (isWordSaved(wordId)) {
      await _savedBox.delete(wordId);
    } else {
      // Lưu trữ timestamp để sau này sort theo thời gian lưu
      await _savedBox.put(wordId, DateTime.now().millisecondsSinceEpoch);
    }
  }

  List<Word> getSavedWords() {
    List<Word> savedList = [];
    for (var wordId in _savedBox.keys) {
      final word = _wordBox.get(wordId);
      if (word != null) savedList.add(word);
    }
    return savedList;
  }

  // === TÍNH NĂNG LỊCH SỬ (HISTORY) ===
  List<Word> getHistoryWords() {
    List<Word> historyList = [];

    for (var wordId in _progressBox.keys) {
      final progress = getWordProgress(wordId as String);
      final int lr = progress['lr'] as int;
      final int ua = progress['ua'] ?? 0;

      // Nếu từ này đã từng được tương tác (lr hoặc ua > 0)
      if (lr > 0 || ua > 0) {
        final word = _wordBox.get(wordId);
        if (word != null) {
          historyList.add(word);
        }
      }
    }
    // Sắp xếp giảm dần (Từ học gần nhất lên đầu)
    historyList.sort((a, b) {
      final pA = getWordProgress(a.id);
      final pB = getWordProgress(b.id);
      final timeA = pA['lr'] > pA['ua'] ? pA['lr'] : pA['ua'];
      final timeB = pB['lr'] > pB['ua'] ? pB['lr'] : pB['ua'];
      return (timeB as int).compareTo(timeA as int);
    });

    return historyList;
  }
}
