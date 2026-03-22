// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'word_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class WordAdapter extends TypeAdapter<Word> {
  @override
  final int typeId = 0;

  @override
  Word read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return Word(
      id: fields[0] as String,
      topic: fields[1] as String,
      word: fields[2] as String,
      phonetic: fields[3] as String,
      meaning: fields[4] as String,
      example: fields[5] as String,
      audioPath: fields[6] as String?,
      isLearned: fields[7] as bool,
      isFavorite: fields[8] as bool,
      interval: fields[9] as int,
      easeFactor: fields[10] as double,
      repetitions: fields[11] as int,
      nextReview: fields[12] as DateTime?,
      lastReview: fields[13] as DateTime?,
      wrongCount: fields[14] as int,
    );
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer
      ..writeByte(15)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.topic)
      ..writeByte(2)
      ..write(obj.word)
      ..writeByte(3)
      ..write(obj.phonetic)
      ..writeByte(4)
      ..write(obj.meaning)
      ..writeByte(5)
      ..write(obj.example)
      ..writeByte(6)
      ..write(obj.audioPath)
      ..writeByte(7)
      ..write(obj.isLearned)
      ..writeByte(8)
      ..write(obj.isFavorite)
      ..writeByte(9)
      ..write(obj.interval)
      ..writeByte(10)
      ..write(obj.easeFactor)
      ..writeByte(11)
      ..write(obj.repetitions)
      ..writeByte(12)
      ..write(obj.nextReview)
      ..writeByte(13)
      ..write(obj.lastReview)
      ..writeByte(14)
      ..write(obj.wrongCount);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is WordAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}

class AppSettingsAdapter extends TypeAdapter<AppSettings> {
  @override
  final int typeId = 1;

  @override
  AppSettings read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return AppSettings(
      ttsSpeed: fields[0] as double,
      themeMode: fields[1] as String,
      userName: fields[2] as String,
      dailyGoal: fields[3] as int,
      isFirstRun: fields[4] as bool,
      lastStudyDate: fields[5] as DateTime?,
      ttsAccent: fields[6] as String,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.ttsSpeed)
      ..writeByte(1)
      ..write(obj.themeMode)
      ..writeByte(2)
      ..write(obj.userName)
      ..writeByte(3)
      ..write(obj.dailyGoal)
      ..writeByte(4)
      ..write(obj.isFirstRun)
      ..writeByte(5)
      ..write(obj.lastStudyDate)
      ..writeByte(6)
      ..write(obj.ttsAccent);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is AppSettingsAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
