import 'package:hive/hive.dart';

part 'word_model.g.dart';

@HiveType(typeId: 0)
class Word extends HiveObject {
  @HiveField(0)
  final String word;
  @HiveField(1)
  final String meaning;
  @HiveField(2)
  final String phoneticUS;
  @HiveField(3)
  final String phoneticUK;
  @HiveField(4)
  final String example;
  @HiveField(5)
  final String topic;

  // --- Tiến độ học tập (Anki SM-2) ---
  @HiveField(6)
  bool isLearned;
  @HiveField(7)
  int wrongCount;
  @HiveField(8)
  int repetitions;
  @HiveField(9)
  int interval;
  @HiveField(10)
  double easeFactor;
  @HiveField(11)
  DateTime? lastReview;
  @HiveField(12)
  DateTime? nextReview;

  // BỔ SUNG ID ĐỂ QUẢN LÝ DỮ LIỆU TỐT HƠN
  @HiveField(13)
  final String id;

  Word({
    required this.id, // Bắt buộc có ID
    required this.word,
    required this.meaning,
    required this.phoneticUS,
    required this.phoneticUK,
    required this.example,
    required this.topic,
    this.isLearned = false,
    this.wrongCount = 0,
    this.repetitions = 0,
    this.interval = 0,
    this.easeFactor = 2.5,
    this.lastReview,
    this.nextReview,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id:
          json['id'] ??
          DateTime.now().millisecondsSinceEpoch
              .toString(), // Dự phòng nếu thiếu ID
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      phoneticUS: json['phoneticUS'] ?? json['phonetic'] ?? '',
      phoneticUK: json['phoneticUK'] ?? json['phonetic'] ?? '',
      example: json['example'] ?? '',
      topic: json['topic'] ?? 'General',
    );
  }
}
