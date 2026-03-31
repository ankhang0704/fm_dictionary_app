import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;
import 'package:shared_preferences/shared_preferences.dart';

class NotificationService {
  NotificationService._();
  static final NotificationService instance = NotificationService._();

  final FlutterLocalNotificationsPlugin _notificationsPlugin =
      FlutterLocalNotificationsPlugin();

  // Lưu trữ thời gian nhắc nhở để UI có thể hiển thị
  final ValueNotifier<TimeOfDay?> reminderTime = ValueNotifier<TimeOfDay?>(
    null,
  );

  Future<void> init() async {
    // 1. Khởi tạo TimeZone (Bắt buộc để đặt lịch lặp lại hàng ngày chính xác theo múi giờ local)
    tz_data.initializeTimeZones();

    // 2. Cấu hình Android (Sử dụng icon mặc định của app: @mipmap/ic_launcher)
    const AndroidInitializationSettings androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');

    // 3. Cấu hình iOS
    const DarwinInitializationSettings iosSettings =
        DarwinInitializationSettings(
          requestAlertPermission: false,
          requestBadgePermission: false,
          requestSoundPermission: false,
        );

    const InitializationSettings initSettings = InitializationSettings(
      android: androidSettings,
      iOS: iosSettings,
    );

    await _notificationsPlugin.initialize(initSettings);

    // 4. Lấy thời gian nhắc nhở đã lưu (nếu có)
    final prefs = await SharedPreferences.getInstance();
    final int? hour = prefs.getInt('reminder_hour');
    final int? minute = prefs.getInt('reminder_minute');
    if (hour != null && minute != null) {
      reminderTime.value = TimeOfDay(hour: hour, minute: minute);
    }
  }

  /// Đặt lịch nhắc nhở hàng ngày
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    // 1. Hủy lịch cũ trước khi đặt lịch mới
    await _notificationsPlugin.cancelAll();

    // 2. Lưu local
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt('reminder_hour', time.hour);
    await prefs.setInt('reminder_minute', time.minute);
    reminderTime.value = time;

    // 3. Tính toán thời gian theo múi giờ
    final now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      time.hour,
      time.minute,
    );

    // Nếu giờ đã qua trong ngày hôm nay, dời sang ngày mai
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }

    // 4. Đăng ký với OS
    await _notificationsPlugin.zonedSchedule(
      0, // ID Notification
      'Đến giờ học Tiếng Anh rồi! 🚀',
      'Dành ra 10 phút ôn tập để giữ vững chuỗi Streak nhé.',
      scheduledDate,
      const NotificationDetails(
        android: AndroidNotificationDetails(
          'daily_reminder_channel',
          'Nhắc nhở học tập',
          channelDescription: 'Thông báo nhắc nhở học từ vựng hàng ngày',
          importance: Importance.max,
          priority: Priority.high,
        ),
        iOS: DarwinNotificationDetails(),
      ),
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime, // Tên Enum chuẩn
      matchDateTimeComponents: DateTimeComponents.time,
    );
  }

  /// Hủy thông báo
  Future<void> cancelReminder() async {
    await _notificationsPlugin.cancelAll();
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('reminder_hour');
    await prefs.remove('reminder_minute');
    reminderTime.value = null;
  }
}
