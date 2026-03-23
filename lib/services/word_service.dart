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
    word.wrongCount = 0; // Reset mistakes when learned
    await word.save();
  }

  // Tìm kiếm từ (Dictionary Mode)
  List<Word> searchWords(String query) {
  if (query.isEmpty) return [];

  final lowercaseQuery = query.toLowerCase();
  
  // Lấy toàn bộ từ từ Hive box
  return _wordBox.values.where((word) {
    return word.word.toLowerCase().contains(lowercaseQuery) || 
           word.meaning.toLowerCase().contains(lowercaseQuery);
  }).toList();
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

  // Lấy ngẫu nhiên n từ
  List<Word> getRandomWords(int count) {
    final allWords = _wordBox.values.toList();
    if (allWords.isEmpty) return [];
    allWords.shuffle();
    return allWords.take(count).toList();
  }

  // Lấy danh sách tất cả các topic
  List<String> getAllTopics() {
    return _wordBox.values.map((w) => w.topic).toSet().toList();
  }
}
