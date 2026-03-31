import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fm_dictionary/services/database/database_service.dart';
import 'package:fm_dictionary/services/database/word_service.dart';
import 'package:fm_dictionary/services/notify/notification_service.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';

class RightSideBar extends StatefulWidget {
  const RightSideBar({super.key});

  @override
  State<RightSideBar> createState() => _RightSideBarState();
}

// Thêm WidgetsBindingObserver để lắng nghe trạng thái App (Foreground/Background)
class _RightSideBarState extends State<RightSideBar>
    with WidgetsBindingObserver {
  bool _hasNotificationPermission = false;
  final WordService _wordService = WordService();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this); // Đăng ký Observer
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(
      this,
    ); // Gỡ Observer tránh tràn bộ nhớ
    super.dispose();
  }

  // LẮNG NGHE KHI APP ĐƯỢC MỞ LẠI TỪ BACKGROUND (VD: Quay lại từ App Settings)
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission(); // Kiểm tra lại quyền ngay lập tức
    }
  }

  Future<void> _checkPermission() async {
    final status = await Permission.notification.status;
    if (mounted) {
      setState(() => _hasNotificationPermission = status.isGranted);
    }
  }

  Future<void> _handlePermissionToggle(bool value) async {
    if (value) {
      final status = await Permission.notification.request();

      if (status.isGranted) {
        setState(() => _hasNotificationPermission = true);
        // Đặt mặc định 20:00 nếu mới bật
        if (NotificationService.instance.reminderTime.value == null) {
          NotificationService.instance.scheduleDailyReminder(
            const TimeOfDay(hour: 20, minute: 0),
          );
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } else {
      // Tắt thông báo
      openAppSettings(); // Hệ điều hành đời mới không cho tắt qua code, mở cài đặt
      NotificationService.instance.cancelReminder();
    }
  }

  void _showPermissionDialog() {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('calendar.permission_title'.tr()),
        content: Text('calendar.permission_denied'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('calendar.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              openAppSettings(); // Mở cài đặt đện thoại
            },
            child: Text(
              'calendar.open_settings'.tr(),
              style: const TextStyle(color: Colors.blue),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectTime(BuildContext context) async {
    final current =
        NotificationService.instance.reminderTime.value ??
        const TimeOfDay(hour: 20, minute: 0);
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: current,
    );
    if (picked != null) {
      await NotificationService.instance.scheduleDailyReminder(picked);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Text(
                'calendar.title'.tr(),
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            // LỊCH SỬ HỌC TẬP REACTIVE (Cập nhật realtime)
            ValueListenableBuilder(
              valueListenable: Hive.box(
                DatabaseService.progressBoxName,
              ).listenable(),
              builder: (context, box, child) {
                // Lấy mảng ngày siêu tốc O(1) Lookup
                final Set<DateTime> studyDates = _wordService.getStudyDates();

                return TableCalendar(
                  firstDay: DateTime.now().subtract(const Duration(days: 365)),
                  lastDay: DateTime.now().add(const Duration(days: 365)),
                  focusedDay: _focusedDay,
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                    titleCentered: true,
                  ),
                  calendarStyle: CalendarStyle(
                    todayDecoration: BoxDecoration(
                      color: theme.colorScheme.primary.withValues(alpha: 0.3),
                      shape: BoxShape.circle,
                    ),
                  ),
                  onPageChanged: (focusedDay) => _focusedDay = focusedDay,

                  // CUSTOM UI: Vẽ "Tích đỏ" dưới những ngày đã học
                  calendarBuilders: CalendarBuilders(
                    markerBuilder: (context, date, events) {
                      // Normalize ngày hiện tại trên lịch để so sánh
                      final normalizedDate = DateTime(
                        date.year,
                        date.month,
                        date.day,
                      );

                      if (studyDates.contains(normalizedDate)) {
                        return Positioned(
                          bottom: 4,
                          child: Icon(
                            Icons.check_circle,
                            size: 14,
                            color: Colors.red.shade400,
                          ),
                        );
                      }
                      return null;
                    },
                  ),
                );
              },
            ),

            const Divider(height: 32),

            // KHU VỰC CÀI ĐẶT THÔNG BÁO
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'calendar.notifications'.tr(),
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                      Switch(
                        value: _hasNotificationPermission,
                        onChanged: _handlePermissionToggle,
                      ),
                    ],
                  ),

                  // Hiển thị TimePicker nếu đã cấp quyền
                  if (_hasNotificationPermission)
                    ValueListenableBuilder<TimeOfDay?>(
                      valueListenable:
                          NotificationService.instance.reminderTime,
                      builder: (context, time, _) {
                        return ListTile(
                          contentPadding: EdgeInsets.zero,
                          leading: const Icon(
                            Icons.access_time_filled,
                            color: Colors.blue,
                          ),
                          title: Text('calendar.reminder_time'.tr()),
                          trailing: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: Colors.blue.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Text(
                              time != null ? time.format(context) : '20:00',
                              style: const TextStyle(
                                color: Colors.blue,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          onTap: () => _selectTime(context),
                        );
                      },
                    ),
                ],
              ),
            ),

            // MỤC THÔNG BÁO MINH HỌA
            Expanded(
              child: _hasNotificationPermission
                  ? ListView(
                      padding: const EdgeInsets.all(16),
                      children: [
                        ListTile(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          tileColor: theme.cardColor,
                          leading: const Icon(
                            Icons.notifications_active,
                            color: Colors.orange,
                          ),
                          title: Text('calendar.system_active'.tr()),
                          subtitle: Text('calendar.system_active_desc'.tr()),
                        ),
                      ],
                    )
                  : Center(
                      child: Padding(
                        padding: const EdgeInsets.all(24.0),
                        child: Text(
                          'calendar.turn_on_notify'.tr(),
                          textAlign: TextAlign.center,
                          style: const TextStyle(color: Colors.grey),
                        ),
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
