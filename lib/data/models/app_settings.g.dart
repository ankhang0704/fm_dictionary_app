// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_settings.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

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
      defaultAccent: fields[6] as String,
      userAvatarPath: fields[7] as String?,
      isHardMode: fields[8] as bool,
      isNotificationEnabled: fields[9] as bool,
      notificationHour: fields[10] as int,
      notificationMinute: fields[11] as int,
    );
  }

  @override
  void write(BinaryWriter writer, AppSettings obj) {
    writer
      ..writeByte(12)
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
      ..write(obj.defaultAccent)
      ..writeByte(7)
      ..write(obj.userAvatarPath)
      ..writeByte(8)
      ..write(obj.isHardMode)
      ..writeByte(9)
      ..write(obj.isNotificationEnabled)
      ..writeByte(10)
      ..write(obj.notificationHour)
      ..writeByte(11)
      ..write(obj.notificationMinute);
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
