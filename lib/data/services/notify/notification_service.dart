import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:permission_handler/permission_handler.dart'; // Thêm dòng này lên đầu file

class NotificationService {
  static final NotificationService instance = NotificationService._internal();
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();

  final ValueNotifier<bool> isEnabled = ValueNotifier<bool>(false);
  final ValueNotifier<TimeOfDay?> reminderTime = ValueNotifier<TimeOfDay?>(
    null,
  );

  Future<void> init() async {
    try {
      // 1. Khởi tạo dữ liệu Timezone
      tz.initializeTimeZones();

      // 2. Lấy múi giờ chuẩn xác từ thiết bị (Ví dụ: Asia/Ho_Chi_Minh)
      // Sử dụng .id để lấy chuỗi IANA chính xác
      // Thử gán trực tiếp nếu nó là String

      final TimezoneInfo timezoneInfo =
          await FlutterTimezone.getLocalTimezone();
      final String timeZoneName = timezoneInfo.identifier;

      tz.setLocalLocation(tz.getLocation(timeZoneName));

      debugPrint('🌍 Timezone hệ thống: $timeZoneName');

      // 3. Cấu hình Android
      const AndroidInitializationSettings initSettingsAndroid =
          AndroidInitializationSettings('@mipmap/ic_launcher');

      // 4. Cấu hình iOS
      const DarwinInitializationSettings initSettingsIOS =
          DarwinInitializationSettings(
            requestAlertPermission: false, // Sẽ xin quyền sau
            requestBadgePermission: false,
            requestSoundPermission: false,
          );

      const InitializationSettings initSettings = InitializationSettings(
        android: initSettingsAndroid,
        iOS: initSettingsIOS,
      );

      // Khởi tạo Plugin
      await _flutterLocalNotificationsPlugin.initialize(
        settings: initSettings,

        onDidReceiveNotificationResponse: (NotificationResponse response) {
          debugPrint('🔔 User mở thông báo: ${response.payload}');
        },
      );
      final settings = DatabaseService.getSettings();
      isEnabled.value = settings.isNotificationEnabled;
      reminderTime.value = TimeOfDay(hour: settings.notificationHour, minute: settings.notificationMinute);
  
      // Load giờ hẹn từ SharedPreferences
      debugPrint('✅ Init NotificationService v21 thành công');
    } catch (e) {
      debugPrint('❌ Lỗi init Notification: $e');
    }
  }
   Future<void> toggleNotification(bool value) async {
    final settings = DatabaseService.getSettings();

    if (value) {
      // 1. Xin quyền và kiểm tra kết quả ngay lập tức
      await requestPermissions();
      final isGranted = await Permission.notification.isGranted;

      // NẾU NGƯỜI DÙNG TỪ CHỐI -> HỦY BỎ VIỆC BẬT
      if (!isGranted) {
        debugPrint('⚠️ Người dùng từ chối quyền, không thể bật thông báo!');
        isEnabled.value = false; // Trả công tắc về OFF
        return; // Dừng hàm lại ngay
      }

      // 2. Nếu đã cho phép thì mới Đặt lịch
      await scheduleDailyReminder(
        reminderTime.value ?? const TimeOfDay(hour: 20, minute: 0),
      );
    } else {
      await _flutterLocalNotificationsPlugin.cancelAll();
    }

    // Chỉ lưu khi mọi thứ thành công
    isEnabled.value = value;
    settings.isNotificationEnabled = value;
    await DatabaseService.saveSettings(settings);

    debugPrint('🔔 Thông báo đã được ${value ? "BẬT" : "TẮT"}');
  }
  /// Xin quyền bằng API tích hợp sẵn của v21 (Không cần permission_handler)
  Future<void> requestPermissions() async {
    try {
      // 1. Xin quyền Android
      final AndroidFlutterLocalNotificationsPlugin? androidImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                AndroidFlutterLocalNotificationsPlugin
              >();
      
      if (androidImplementation != null) {
        // Xin quyền hiển thị thông báo (Android 13+)
        await androidImplementation.requestNotificationsPermission();
        // Xin quyền hẹn giờ chính xác (Android 14+) - Bắt buộc cho Exact Alarms
        await androidImplementation.requestExactAlarmsPermission();
      }

      // 2. Xin quyền iOS
      final IOSFlutterLocalNotificationsPlugin? iosImplementation =
          _flutterLocalNotificationsPlugin
              .resolvePlatformSpecificImplementation<
                IOSFlutterLocalNotificationsPlugin
              >();

      if (iosImplementation != null) {
        await iosImplementation.requestPermissions(
          alert: true,
          badge: true,
          sound: true,
        );
      }
      if (await Permission.ignoreBatteryOptimizations.isDenied) {
        await Permission.ignoreBatteryOptimizations.request();
      }
    } catch (e) {
      debugPrint('❌ Lỗi xin quyền thông báo: $e');
    }
  }
    Future<void> updateReminderTime(TimeOfDay time) async {
    final settings = DatabaseService.getSettings();
    
    reminderTime.value = time;
    settings.notificationHour = time.hour;
    settings.notificationMinute = time.minute;
    await DatabaseService.saveSettings(settings);

    // Nếu đang ở trạng thái Bật thì mới đặt lịch lại
    if (isEnabled.value) {
      await scheduleDailyReminder(time);
    }
  }

  /// Hẹn giờ lặp lại mỗi ngày
  Future<void> scheduleDailyReminder(TimeOfDay time) async {
    try {
      // Ép xin quyền lại trước khi set lịch để đảm bảo
      reminderTime.value = time;
      final androidImpl = _flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>();
      bool exactAlarmGranted = true;
      if (androidImpl != null) {
        exactAlarmGranted = await androidImpl.canScheduleExactNotifications() ?? false;
      }
      final prefs = await SharedPreferences.getInstance();
      await prefs.setInt('reminder_hour', time.hour);
      await prefs.setInt('reminder_minute', time.minute);

      await _flutterLocalNotificationsPlugin.zonedSchedule(
        id: 100,
        title: 'Đến giờ học Tiếng Anh rồi! 📚',
        body: 'Vào ôn tập để giữ vững chuỗi Streak ngay nào!',
        scheduledDate: _nextInstanceOfTime(time.hour, time.minute),
        notificationDetails: const NotificationDetails(
          android: AndroidNotificationDetails(
            'daily_study_reminder',
            'Nhắc nhở học tập',
            channelDescription: 'Nhắc nhở học từ vựng mỗi ngày',
            importance: Importance.max,
            priority: Priority.high,
            showWhen: true,
          ),
          iOS: DarwinNotificationDetails(
            presentAlert: true,
            presentBadge: true,
            presentSound: true,
          ),
        ),
        // Chuẩn v21: Bắt buộc truyền androidScheduleMode
         androidScheduleMode: exactAlarmGranted 
            ? AndroidScheduleMode.exactAllowWhileIdle 
            : AndroidScheduleMode.inexactAllowWhileIdle, // Fallback an toàn
        matchDateTimeComponents: DateTimeComponents.time,
      );
      debugPrint('⏰ Đã hẹn giờ vào ${time.hour}:${time.minute} mỗi ngày.');
    } catch (e) {
      debugPrint('❌ Lỗi scheduleDailyReminder: $e');
    }
  }

  /// Test nhanh xem thông báo có đẩy được không

  /// Hủy thông báo
  Future<void> cancelReminder() async {
    try {
      await _flutterLocalNotificationsPlugin.cancel(id: 100);
      reminderTime.value = null;

      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('reminder_hour');
      await prefs.remove('reminder_minute');
      debugPrint('🗑 Đã hủy nhắc nhở');
    } catch (e) {
      debugPrint('❌ Lỗi cancelReminder: $e');
    }
  }

  /// Tính toán thời điểm tiếp theo cho Timezone
  tz.TZDateTime _nextInstanceOfTime(int hour, int minute) {
    final tz.TZDateTime now = tz.TZDateTime.now(tz.local);
    tz.TZDateTime scheduledDate = tz.TZDateTime(
      tz.local,
      now.year,
      now.month,
      now.day,
      hour,
      minute,
    );
    if (scheduledDate.isBefore(now)) {
      scheduledDate = scheduledDate.add(const Duration(days: 1));
    }
    return scheduledDate;
  }
}
