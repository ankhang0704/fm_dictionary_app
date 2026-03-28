import 'package:hive/hive.dart';
import '../models/word_model.dart';
import 'database_service.dart';

class WordService {
  final _wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
  final _progressBox = Hive.box(DatabaseService.progressBoxName); // Box mới

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

    if (!isCorrect) {
      // TRẢ LỜI SAI: Reset step, học lại ngay, tăng wrongCount
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
    await _progressBox.put(wordId, {
      's': 4,
      'wc': 0, // Reset sai
      'lr': now,
      'nr': now + (30 * _msPerDay), // +30 ngày
    });
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
}
