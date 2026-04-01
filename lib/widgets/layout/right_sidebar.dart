// file: lib/widgets/layout/right_sidebar.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:table_calendar/table_calendar.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:permission_handler/permission_handler.dart';
import '../../services/database/database_service.dart';
import '../../services/database/word_service.dart';
import '../../services/notify/notification_service.dart';
import '../../core/constants/constants.dart';

class RightSideBar extends StatefulWidget {
  const RightSideBar({super.key});

  @override
  State<RightSideBar> createState() => _RightSideBarState();
}

class _RightSideBarState extends State<RightSideBar> with WidgetsBindingObserver {
  bool _hasNotificationPermission = false;
  final WordService _wordService = WordService();
  DateTime _focusedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermission();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPermission();
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
        if (NotificationService.instance.reminderTime.value == null) {
          NotificationService.instance.scheduleDailyReminder(const TimeOfDay(hour: 20, minute: 0));
        }
      } else if (status.isPermanentlyDenied) {
        _showPermissionDialog();
      }
    } else {
      openAppSettings();
      NotificationService.instance.cancelReminder();
    }
  }

  void _showPermissionDialog() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        backgroundColor: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.cardRadius / 2)),
        title: Text(
          'calendar.permission_title'.tr(), 
          style: TextStyle(color: isDark ? Colors.white : AppConstants.textPrimary, fontSize: 16),
        ),
        content: Text(
          'calendar.permission_denied'.tr(), 
          style: TextStyle(color: AppConstants.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text('calendar.cancel'.tr(), style: TextStyle(color: AppConstants.textSecondary)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppConstants.buttonRadius / 2)),
            ),
            onPressed: () {
              Navigator.pop(context);
              openAppSettings();
            },
            child: Text('calendar.open_settings'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
              child: Text(
                'calendar.title'.tr(),
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 18,
                  fontStyle: FontStyle.normal,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
              ),
            ),
            _buildCalendarSection(isDark),
            const SizedBox(height: 16),
            Divider(height: 1, thickness: 1, color: Colors.grey.withValues(alpha: 0.1)),
            const SizedBox(height: 16),
            _buildNotificationSettings(isDark),
            Expanded(
              child: _hasNotificationPermission
                  ? _buildNotificationList(isDark)
                  : _buildPermissionPrompt(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCalendarSection(bool isDark) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
      builder: (context, box, child) {
        final Set<DateTime> studyDates = _wordService.getStudyDates();

        return Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Container(
            padding: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
              boxShadow: isDark ? [] : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.03),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: TableCalendar(
              firstDay: DateTime.now().subtract(const Duration(days: 365)),
              lastDay: DateTime.now().add(const Duration(days: 365)),
              focusedDay: _focusedDay,
              rowHeight: 40,
              headerStyle: HeaderStyle(
                formatButtonVisible: false,
                titleCentered: true,
                leftChevronPadding: EdgeInsets.zero,
                rightChevronPadding: EdgeInsets.zero,
                titleTextStyle: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
                leftChevronIcon: Icon(CupertinoIcons.chevron_left, color: AppConstants.textSecondary, size: 20),
                rightChevronIcon: Icon(CupertinoIcons.chevron_right, color: AppConstants.textSecondary, size: 20),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
                weekendStyle: TextStyle(color: AppConstants.textSecondary, fontWeight: FontWeight.bold, fontSize: 12),
              ),
              calendarStyle: CalendarStyle(
                defaultTextStyle: TextStyle(color: isDark ? Colors.white : AppConstants.textPrimary, fontSize: 13),
                weekendTextStyle: TextStyle(color: isDark ? Colors.white70 : AppConstants.textPrimary, fontSize: 13),
                outsideTextStyle: TextStyle(color: AppConstants.textLight, fontSize: 13),
                cellMargin: const EdgeInsets.all(4),
                todayDecoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.3),
                  shape: BoxShape.circle,
                ),
                todayTextStyle: TextStyle(
                  color: isDark ? Colors.white : AppConstants.accentColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 13,
                ),
              ),
              onPageChanged: (focusedDay) => _focusedDay = focusedDay,
              calendarBuilders: CalendarBuilders(
                markerBuilder: (context, date, events) {
                  final normalizedDate = DateTime(date.year, date.month, date.day);
                  if (studyDates.contains(normalizedDate)) {
                    return Positioned(
                      bottom: 4,
                      child: Container(
                        width: 4,
                        height: 4,
                        decoration: const BoxDecoration(
                          color: AppConstants.successColor,
                          shape: BoxShape.circle,
                        ),
                      ),
                    );
                  }
                  return null;
                },
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildNotificationSettings(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  'calendar.notifications'.tr(),
                  style: AppConstants.subHeadingStyle.copyWith(
                    fontSize: 12,
                    color: isDark ? Colors.white70 : AppConstants.textSecondary,
                  ),
                ),
              ),
              Transform.scale(
                scale: 0.8,
                child: Switch.adaptive(
                  value: _hasNotificationPermission,
                  activeThumbColor: AppConstants.accentColor,
                  onChanged: _handlePermissionToggle,
                ),
              ),
            ],
          ),
          if (_hasNotificationPermission) ...[
            const SizedBox(height: 8),
            ValueListenableBuilder<TimeOfDay?>(
              valueListenable: NotificationService.instance.reminderTime,
              builder: (context, time, _) {
                return GestureDetector(
                  onTap: () async {
                    final current = time ?? const TimeOfDay(hour: 20, minute: 0);
                    final picked = await showTimePicker(context: context, initialTime: current);
                    if (picked != null) {
                      await NotificationService.instance.scheduleDailyReminder(picked);
                    }
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                    decoration: BoxDecoration(
                      color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
                      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                      border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                    ),
                    child: Row(
                      children: [
                        const Icon(CupertinoIcons.clock_fill, color: AppConstants.accentColor, size: 18),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'calendar.reminder_time'.tr(),
                            style: AppConstants.bodyStyle.copyWith(
                              fontSize: 13,
                              fontWeight: FontWeight.w500,
                              color: isDark ? Colors.white : AppConstants.textPrimary,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                          decoration: BoxDecoration(
                            color: AppConstants.accentColor.withValues(alpha: 0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            time != null ? time.format(context) : '20:00',
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppConstants.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildNotificationList(bool isDark) {
    return ListView(
      padding: const EdgeInsets.all(16),
      physics: const BouncingScrollPhysics(),
      children: [
        Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            border: Border.all(color: AppConstants.accentColor.withValues(alpha: 0.3)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
            leading: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(CupertinoIcons.bell_fill, color: AppConstants.accentColor, size: 18),
            ),
            title: Text(
              'calendar.system_active'.tr(),
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 2),
              child: Text(
                'calendar.system_active_desc'.tr(),
                style: AppConstants.bodyStyle.copyWith(
                  fontSize: 12,
                  color: AppConstants.textSecondary,
                ),
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildPermissionPrompt() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(CupertinoIcons.bell_slash, size: 40, color: AppConstants.textLight),
            const SizedBox(height: 12),
            Text(
              'calendar.turn_on_notify'.tr(),
              textAlign: TextAlign.center,
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 13,
                color: AppConstants.textSecondary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}