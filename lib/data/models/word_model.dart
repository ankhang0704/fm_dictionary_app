import 'package:hive/hive.dart';

part 'word_model.g.dart';

@HiveType(typeId: 0)
class Word extends HiveObject {
  @HiveField(0)
  final String id; // Chuyển id lên đầu
  @HiveField(1)
  final String word;
  @HiveField(2)
  final String meaning;
  @HiveField(3)
  final String phoneticUS;
  @HiveField(4)
  final String phoneticUK;
  @HiveField(5)
  final String example;
  @HiveField(6)
  final String topic;

  Word({
    required this.id,
    required this.word,
    required this.meaning,
    required this.phoneticUS,
    required this.phoneticUK,
    required this.example,
    required this.topic,
  });

  factory Word.fromJson(Map<String, dynamic> json) {
    return Word(
      id: json['id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
      word: json['word'] ?? '',
      meaning: json['meaning'] ?? '',
      phoneticUS: json['phoneticUS'] ?? json['phonetic'] ?? '',
      phoneticUK: json['phoneticUK'] ?? json['phonetic'] ?? '',
      example: json['example'] ?? '',
      topic: json['topic'] ?? 'General',
    );
  }
}
