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
      word: fields[0] as String,
      meaning: fields[1] as String,
      phoneticUS: fields[2] as String,
      phoneticUK: fields[3] as String,
      example: fields[4] as String,
      topic: fields[5] as String,
      isLearned: fields[6] as bool,
      wrongCount: fields[7] as int,
      repetitions: fields[8] as int,
      interval: fields[9] as int,
      easeFactor: fields[10] as double,
      lastReview: fields[11] as DateTime?,
      nextReview: fields[12] as DateTime?,
    );
  }

  @override
  void write(BinaryWriter writer, Word obj) {
    writer
      ..writeByte(13)
      ..writeByte(0)
      ..write(obj.word)
      ..writeByte(1)
      ..write(obj.meaning)
      ..writeByte(2)
      ..write(obj.phoneticUS)
      ..writeByte(3)
      ..write(obj.phoneticUK)
      ..writeByte(4)
      ..write(obj.example)
      ..writeByte(5)
      ..write(obj.topic)
      ..writeByte(6)
      ..write(obj.isLearned)
      ..writeByte(7)
      ..write(obj.wrongCount)
      ..writeByte(8)
      ..write(obj.repetitions)
      ..writeByte(9)
      ..write(obj.interval)
      ..writeByte(10)
      ..write(obj.easeFactor)
      ..writeByte(11)
      ..write(obj.lastReview)
      ..writeByte(12)
      ..write(obj.nextReview);
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
