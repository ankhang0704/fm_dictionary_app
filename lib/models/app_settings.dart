import 'package:hive/hive.dart';

part 'app_settings.g.dart';

@HiveType(typeId: 1)
class AppSettings extends HiveObject {
  @HiveField(0)
  double ttsSpeed;
  @HiveField(1)
  String themeMode; // 'light' hoặc 'dark'
  @HiveField(2)
  String userName;
  @HiveField(3)
  int dailyGoal;
  @HiveField(4)
  bool isFirstRun;
  @HiveField(5)
  DateTime? lastStudyDate;
  @HiveField(6)
  String defaultAccent; // 'en-US' hoặc 'en-GB'

  AppSettings({
    this.ttsSpeed = 0.5,
    this.themeMode = 'light',
    this.userName = 'User',
    this.dailyGoal = 20,
    this.isFirstRun = true,
    this.lastStudyDate,
    this.defaultAccent = 'en-US',
  });
}