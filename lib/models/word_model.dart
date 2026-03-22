import 'package:hive/hive.dart';
part 'word_model.g.dart';

@HiveType(typeId: 0)
class Word extends HiveObject {
  @HiveField(0)
  final String id;
  @HiveField(1)
  final String topic;
  @HiveField(2)
  final String word;
  @HiveField(3)
  final String phonetic;
  @HiveField(4)
  final String meaning;
  @HiveField(5)
  final String example;
  @HiveField(6)
  final String? audioPath;
  @HiveField(7)
  bool isLearned;
  @HiveField(8)
  bool isFavorite;
  @HiveField(9)
  int interval;
  @HiveField(10)
  double easeFactor;
  @HiveField(11)
  int repetitions;
  @HiveField(12)
  DateTime? nextReview;
  @HiveField(13)
  DateTime? lastReview;
  @HiveField(14)
  int wrongCount;

  Word({
    required this.id,
    required this.topic,
    required this.word,
    this.phonetic = '',
    this.meaning = '',
    this.example = '',
    this.audioPath,
    this.isLearned = false,
    this.isFavorite = false,
    this.interval = 0,
    this.easeFactor = 2.5,
    this.repetitions = 0,
    this.nextReview,
    this.lastReview,
    this.wrongCount = 0,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'],
      topic: json['topic'],
      word: json['word'],
      phonetic: json['phonetic'] ?? '',
      meaning: json['meaning'] ?? '',
      example: json['example'] ?? '',
      audioPath: json['audio'],
    );
  }
}

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  double ttsSpeed;
  @HiveField(1)
  String themeMode;
  @HiveField(2)
  String userName;
  @HiveField(3)
  int dailyGoal;
  @HiveField(4)
  bool isFirstRun;
  @HiveField(5)
  DateTime? lastStudyDate;
  @HiveField(6)
  String ttsAccent; // 'en-US' hoặc 'en-GB'

  AppSettings({
    this.ttsSpeed = 1.0,
    this.themeMode = 'light',
    this.userName = 'An Khang',
    this.dailyGoal = 20,
    this.isFirstRun = true,
    this.lastStudyDate,
    this.ttsAccent = 'en-US',
  });
}
