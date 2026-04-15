// lib/features/home/presentation/screens/stats_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../settings/presentation/providers/notification_provider.dart';

class StatsScreen extends StatelessWidget {
  const StatsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final notify = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(title: const Text("Tiến độ học tập")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // STREAK BENTO
          _buildStreakBento(learning.currentStreak),
          const SizedBox(height: 16),

          // CALENDAR BENTO
          _buildCalendarBento(context, learning.studyDates, isDark),
          const SizedBox(height: 16),

          // NOTIFICATION BENTO
          _buildNotifyBento(context, notify, isDark),
        ],
      ),
    );
  }

  Widget _buildStreakBento(int streak) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          colors: [Colors.orange, Colors.redAccent],
        ),
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 50)),
          const SizedBox(height: 8),
          Text(
            '$streak Ngày liên tiếp',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 24,
              fontWeight: FontWeight.bold,
            ),
          ),
          const Text(
            'Đừng để lửa tắt nhé!',
            style: TextStyle(color: Colors.white70),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBento(
    BuildContext context,
    Set<DateTime> dates,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2023),
        lastDay: DateTime.now().add(const Duration(days: 30)),
        headerStyle: const HeaderStyle(
          formatButtonVisible: false,
          titleCentered: true,
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, _) {
            if (dates.contains(DateTime(date.year, date.month, date.day))) {
              return Container(
                margin: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: Colors.green,
                  shape: BoxShape.circle,
                ),
              );
            }
            return null;
          },
        ),
      ),
    );
  }

  // lib/features/home/presentation/screens/stats_screen.dart

  Widget _buildNotifyBento(
    BuildContext context,
    NotificationProvider notify,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          SwitchListTile(
            secondary: Icon(
              notify.isEnabled
                  ? CupertinoIcons.bell_fill
                  : CupertinoIcons.bell_slash,
              color: notify.isEnabled ? Colors.orange : Colors.grey,
            ),
            title: const Text(
              "Thông báo",
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: const Text("Nhắc nhở ôn tập hằng ngày"),
            value: notify.isEnabled,
            onChanged: (v) => notify.toggleNotification(v),
          ),
          if (notify.isEnabled) ...[
            const Divider(indent: 16, endIndent: 16),
            ListTile(
              leading: const Icon(CupertinoIcons.clock, color: Colors.blue),
              title: const Text("Thời gian nhắc"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.blue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  notify.reminderTime?.format(context) ?? "20:00",
                  style: const TextStyle(
                    color: Colors.blue,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              onTap: () async {
                final time = await showTimePicker(
                  context: context,
                  initialTime:
                      notify.reminderTime ??
                      const TimeOfDay(hour: 20, minute: 0),
                );
                if (time != null) notify.updateReminderTime(time);
              },
            ),
          ],
        ],
      ),
    );
  }
}
