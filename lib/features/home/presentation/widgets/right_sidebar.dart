// Đường dẫn: lib/features/home/presentation/widgets/right_sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:provider/provider.dart';
import 'package:table_calendar/table_calendar.dart';
import '../../../settings/presentation/providers/notification_provider.dart';

class RightSidebar extends StatelessWidget {
  const RightSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final learningProvider = context.watch<LearningProvider>();
    final notifyProvider = context.watch<NotificationProvider>();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      width: MediaQuery.of(context).size.width * 0.85,
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      child: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(16),
          physics: const BouncingScrollPhysics(),
          children: [
            const Text("Học tập & Lịch trình", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // BENTO BOX 1: Streak Lửa
            _buildStreakBento(learningProvider.currentStreak),
            const SizedBox(height: 16),

            // BENTO BOX 2: Lịch học (Calendar)
            _buildCalendarBento(context, learningProvider.studyDates),
            const SizedBox(height: 24),

            const Text("Thông báo", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 16),

            // BENTO BOX 3: Cài đặt nhắc nhở
            _buildNotificationBento(context, notifyProvider),
          ],
        ),
      ),
    );
  }

  Widget _buildStreakBento(int streak) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [Colors.orange.shade300, Colors.deepOrange]),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Row(
        children: [
          const Text('🔥', style: TextStyle(fontSize: 32)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              streak > 0 ? 'Đang giữ chuỗi:\n$streak ngày liên tiếp!' : 'Hãy bắt đầu học từ vựng hôm nay nhé!',
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCalendarBento(BuildContext context, Set<DateTime> studyDates) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: TableCalendar(
        focusedDay: DateTime.now(),
        firstDay: DateTime.utc(2020, 1, 1),
        lastDay: DateTime.utc(2030, 12, 31),
        headerStyle: const HeaderStyle(formatButtonVisible: false, titleCentered: true),
        calendarStyle: const CalendarStyle(
          todayDecoration: BoxDecoration(color: Colors.blueAccent, shape: BoxShape.circle),
        ),
        calendarBuilders: CalendarBuilders(
          markerBuilder: (context, date, events) {
            final normalizedDate = DateTime(date.year, date.month, date.day);
            if (studyDates.contains(normalizedDate)) {
              return Positioned(bottom: 4, child: Container(width: 6, height: 6, decoration: const BoxDecoration(color: Colors.green, shape: BoxShape.circle)));
            }
            return null;
          },
        ),
      ),
    );
  }

  Widget _buildNotificationBento(BuildContext context, NotificationProvider provider) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          SwitchListTile(
            title: const Text("Nhắc nhở học tập"),
            subtitle: const Text("Bật thông báo để không quên chuỗi học"),
            value: provider.isEnabled,
            onChanged: (val) => provider.toggleNotification(val),
          ),
          if (provider.isEnabled) ...[
            const Divider(height: 1),
            ListTile(
              leading: const Icon(CupertinoIcons.clock, color: Colors.blue),
              title: const Text("Thời gian nhắc"),
              trailing: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.1), borderRadius: BorderRadius.circular(8)),
                child: Text(provider.reminderTime?.format(context) ?? "20:00", style: const TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
              ),
              onTap: () async {
                final time = await showTimePicker(context: context, initialTime: provider.reminderTime ?? const TimeOfDay(hour: 20, minute: 0));
                if (time != null) provider.updateReminderTime(time);
              },
            ),
          ]
        ],
      ),
    );
  }
}