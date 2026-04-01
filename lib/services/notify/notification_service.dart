import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();
  final ValueNotifier<TimeOfDay?> reminderTime = ValueNotifier<TimeOfDay?>(
    null,
  );

  // ID Channel mới để reset cấu hình hệ thống
  static const String _channelId = 'fm_daily_v5';

  Future<void> init() async {
    tz_data.initializeTimeZones();

    // 1. Đồng bộ múi giờ
    try {
      final TimezoneInfo tzData = await FlutterTimezone.getLocalTimezone();
      String timeZoneName = tzData.identifier;
      tz.setLocalLocation(tz.getLocation(timeZoneName));
    } catch (e) {
      tz.setLocalLocation(tz.getLocation('Asia/Ho_Chi_Minh'));
    }

    // 2. Khởi tạo Plugin
    const androidSettings = AndroidInitializationSettings(
      '@mipmap/ic_launcher',
    );
    const iosSettings = DarwinInitializationSettings(
      requestAlertPermission: true,
      requestBadgePermission: true,
      requestSoundPermission: true,
    );

    await _notificationsPlugin.initialize(
      const InitializationSettings(android: androidSettings, iOS: iosSettings),
    );

    // 3. Nạp dữ liệu cũ
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('reminder_hour');
    final int? minute = prefs.getInt('reminder_minute');
    if (hour != null && minute != null) {
      reminderTime.value = TimeOfDay(hour: hour, minute: minute);
    }
  }

  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // Xin quyền báo thức chính xác (Cần thiết cho Android 12+)
    final androidPlugin = _notificationsPlugin
        .resolvePlatformSpecificImplementation<
          AndroidFlutterLocalNotificationsPlugin
        >();
    await androidPlugin?.requestExactAlarmsPermission();

    await _notificationsPlugin.cancelAll();

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    reminderTime.value = time;

    final now = tz.TZDateTime.now(tz.local);
    var scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Đảm bảo luôn nằm ở tương lai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    await _notificationsPlugin.zonedSchedule(
      0,
      'Đến giờ học Tiếng Anh rồi! 🚀',
      'Dành ra 10 phút ôn tập để giữ vững chuỗi Streak nhé.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          _channelId,
          'Nhắc nhở học tập',
          importance: Importance.max,
          priority: Priority.high,
          fullScreenIntent: true,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      matchDateTimeComponents: DateTimeComponents.time,
    );
    debugPrint("🕒 Đã đặt lịch: ${scheduledDate.toString()}");
  }

  // Hàm Test 5 giây nổ ngay lập tức
  Future<void> testQuickNotification() async {
    final scheduledDate = tz.TZDateTime.now(
      tz.local,
    ).add(const Duration(seconds: 5));

    await _notificationsPlugin.zonedSchedule(
      12345,
      'Test Thành Công! ⚡',
      'Thông báo đã hoạt động đúng múi giờ local.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'test_quick_channel',
          'Kênh Test Nhanh',
          importance: Importance.max,
          priority: Priority.high,
        ),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
    );
  }

  Future<void> cancelReminder() async {
    await _notificationsPlugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_hour');
    await prefs.remove('reminder_minute');
    reminderTime.value = null;
  }
}
