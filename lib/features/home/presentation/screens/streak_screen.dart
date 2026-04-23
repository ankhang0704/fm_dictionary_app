import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

import '../../../../core/theme/app_colors.dart';
import '../../../learning/presentation/providers/learning_provider.dart';
import '../../../settings/presentation/providers/notification_provider.dart';
import '../../../gamification/presentation/providers/gamification_provider.dart';

class StreakScreen extends StatelessWidget {
  const StreakScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final notify = context.watch<NotificationProvider>();
    final gamification = context.watch<GamificationProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          "dashboard.title".tr(), // INJECTED
          style: Theme.of(context).textTheme.displaySmall,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        children: [
          // 1. TOP ROW: HERO (2/3) & STREAK (1/3)
          Row(
            children: [
              Expanded(
                flex: 2,
                child: _buildHeroBento(
                  context,
                  learning.masteredWords,
                  learning.totalWords,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                flex: 1,
                child: _buildStreakBento(context, learning.currentStreak),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // 2. ACTIVITY HEATMAP (GITHUB STYLE)
          _buildHeatmapBento(context, learning.studyDates),
          const SizedBox(height: 16),

          // 3. GAMIFICATION BENTO
          _buildGamificationBento(context, gamification),
          const SizedBox(height: 16),

          // 4. UTILITY BENTO (NOTIFICATION)
          _buildNotifyBento(context, notify),
          const SizedBox(height: 40),
        ],
      ),
    );
  }

  // --- 1A. HERO BENTO (VIBRANT BLUE) ---
  Widget _buildHeroBento(BuildContext context, int mastered, int total) {
    final double progress = total > 0 ? mastered / total : 0;

    return BentoCard(
      bentoColor: AppColors.bentoBlue,
      padding: const EdgeInsets.all(20),
      child: SizedBox(
        height: 130, // Fixed height to match streak bento
        child: Stack(
          children: [
            Align(
              alignment: Alignment.centerRight,
              child: SizedBox(
                width: 80,
                height: 80,
                child: CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 8,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Colors.white.withValues(alpha: 0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              ),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  // const REMOVED
                  "dashboard.mastered_words".tr(), // INJECTED
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    height: 1.2,
                  ),
                ),
                const SizedBox(height: 8),
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    "$mastered",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      height: 1.0,
                    ),
                  ),
                ),
                Text(
                  "dashboard.words_unit".tr(
                    args: [total.toString()],
                  ), // INJECTED WITH ARGS
                  style: const TextStyle(color: Colors.white54, fontSize: 12),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- 1B. STREAK BENTO (VIBRANT ORANGE) ---
  Widget _buildStreakBento(BuildContext context, int streak) {
    String message = "streak.messages.start".tr(); // INJECTED
    if (streak >= 7) {
      message = "streak.messages.fire".tr(); // INJECTED
    } else if (streak >= 3) {
      message = "streak.messages.keep".tr(); // INJECTED
    } else if (streak > 0) {
      message = "streak.messages.spark".tr(); // INJECTED
    }

    return BentoCard(
      bentoColor: AppColors.warning,
      padding: const EdgeInsets.all(16),
      child: SizedBox(
        height: 138, // Match Hero height
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('🔥', style: TextStyle(fontSize: 32)),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                '$streak',
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  height: 1.0,
                ),
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              fit: BoxFit.scaleDown,
              child: Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  height: 1.2,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- 2. ACTIVITY HEATMAP BENTO (GITHUB STYLE) ---
  Widget _buildHeatmapBento(BuildContext context, Set<DateTime> dates) {
    // STRICTLY PRESERVED LOGIC: Generate 70 days
    final today = DateTime.now();
    final List<DateTime> last70Days = List.generate(
      70,
      (index) => today.subtract(Duration(days: 69 - index)),
    );

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "heatmap.title".tr(), // INJECTED
            style: Theme.of(
              context,
            ).textTheme.displaySmall?.copyWith(fontSize: 16),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 100,
            child: GridView.builder(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 7,
                mainAxisSpacing: 4,
                crossAxisSpacing: 4,
              ),
              itemCount: last70Days.length,
              itemBuilder: (context, index) {
                final date = last70Days[index];
                final normalizedDate = DateTime(
                  date.year,
                  date.month,
                  date.day,
                );
                final isActive = dates.contains(normalizedDate);

                return Container(
                  decoration: BoxDecoration(
                    color: isActive
                        ? AppColors.bentoMint
                        : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(4),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  // --- 3. GAMIFICATION BENTO ---
  Widget _buildGamificationBento(
    BuildContext context,
    GamificationProvider gamification,
  ) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "profile.badges".tr(), // REUSED PROFILE KEY
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 16),
              ),
              Text(
                "${gamification.badges.where((b) => b.isUnlocked).length} / ${gamification.badges.length}",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: AppColors.bentoYellow,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            child: Row(
              children: gamification.badges.map((badge) {
                return Padding(
                  padding: const EdgeInsets.only(right: 16),
                  child: Column(
                    children: [
                      Container(
                        width: 60,
                        height: 60,
                        decoration: BoxDecoration(
                          color: badge.isUnlocked
                              ? AppColors.bentoYellow.withValues(alpha: 0.15)
                              : Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.05),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          badge.icon,
                          color: badge.isUnlocked
                              ? AppColors.bentoYellow
                              : Theme.of(
                                  context,
                                ).dividerColor.withValues(alpha: 0.3),
                          size: 32,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        badge.title,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: badge.isUnlocked
                              ? null
                              : Theme.of(context).textTheme.bodySmall?.color
                                    ?.withValues(alpha: 0.5),
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  // --- 4. UTILITIES BENTO (NOTIFICATION) ---
  Widget _buildNotifyBento(BuildContext context, NotificationProvider notify) {
    return BentoCard(
      onTap: notify.isEnabled
          ? () async {
              final time = await showTimePicker(
                context: context,
                initialTime:
                    notify.reminderTime ?? const TimeOfDay(hour: 20, minute: 0),
              );
              if (time != null) notify.updateReminderTime(time);
            }
          : null,
      bentoColor: AppColors.bentoMint.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.bentoMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.bell_fill,
              color: Colors.white,
              size: 28,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "notifications.reminder_title".tr(), // INJECTED
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: AppColors.bentoMint,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  notify.isEnabled
                      ? (notify.reminderTime?.format(context) ?? "20:00")
                      : "notifications.disabled".tr(), // INJECTED
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: notify.isEnabled
                        ? AppColors.bentoMint
                        : Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
          CupertinoSwitch(
            activeTrackColor: AppColors.bentoMint,
            value: notify.isEnabled,
            onChanged: (v) => notify.toggleNotification(v),
          ),
        ],
      ),
    );
  }
}
