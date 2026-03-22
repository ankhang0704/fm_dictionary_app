import 'package:hive/hive.dart';
import '../models/word_model.dart';
import 'database_service.dart';

class WordService {
  final _wordBox = Hive.box<Word>(DatabaseService.wordBoxName);

  // Lấy danh sách từ theo Topic từ Hive
  List<Word> getWordsByTopic(String topic) {
    return _wordBox.values.where((w) => w.topic == topic).toList();
  }

  // Đánh dấu từ đã thuộc
  Future<void> markAsLearned(Word word) async {
    word.isLearned = true;
    await word.save(); // HiveObject cho phép gọi .save() cực tiện
  }

  // Tìm kiếm từ (Dictionary Mode)
  List<Word> searchWords(String query) {
    if (query.isEmpty) return [];
    return _wordBox.values
        .where((w) => w.word.toLowerCase().contains(query.toLowerCase()))
        .take(20) // Giới hạn 20 kết quả để mượt mà
        .toList();
  }

  // Lấy các từ cần Review (Sai nhiều hoặc đến hạn Anki)
  List<Word> getWordsToReview() {
    return _wordBox.values
        .where(
          (w) =>
              w.wrongCount > 0 ||
              (w.nextReview != null && w.nextReview!.isBefore(DateTime.now())),
        )
        .toList();
  }
}
