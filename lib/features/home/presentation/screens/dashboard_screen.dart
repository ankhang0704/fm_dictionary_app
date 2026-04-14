// lib/features/home/presentation/screens/dashboard_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/widgets/common/app_avatar.dart';
import 'package:fm_dictionary/core/widgets/common/home_search_bar.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/features/history/presentation/screens/history_screen.dart';
import 'package:fm_dictionary/features/saved/presentation/screens/saved_words_screen.dart';
import 'package:fm_dictionary/features/search/search_screen.dart';
import 'package:fm_dictionary/features/settings/presentation/providers/notification_provider.dart';
import 'package:provider/provider.dart';
import '../providers/home_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../learning/study_screen.dart';
import '../../../learning/quiz_configuration_screen.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer2<HomeProvider, AuthProvider>(
          builder: (context, home, auth, child) {
            if (home.isLoading)
              return const Center(child: CircularProgressIndicator());

            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                SliverPadding(
                  padding: const EdgeInsets.all(16.0),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      // 1. HEADER (Notify | Hello | Avatar)
                      _buildHeaderBento(context, auth, home.quote, isDark),
                      const SizedBox(height: 24),

                      // 2. DAILY GOAL (Logic Continue Learning)
                      _buildDailyGoalBento(context, home, isDark),
                      const SizedBox(height: 16),

                      // 3. SPLIT (Quiz & Word of Day)
                      Row(
                        children: [
                          Expanded(child: _buildQuizBento(context, isDark)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildWordOfDayBento(
                              context,
                              home.wordOfTheDay?.word ?? "...",
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const HomeSearchBar(), // Nhúng SearchScreen vào đây luôn để tận dụng lại logic và UI
                      // 4. TOPICS (New Update)
                      _buildTopicsBento(
                        context,
                        home.recommendedTopics,
                        isDark,
                      ),
                      const SizedBox(height: 24),

                      // 5. BOTTOM ACTIONS (History, Save, Mistake, Streak)
                      _buildBottomActions(context, home, isDark),
                      const SizedBox(height: 32),
                    ]),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  // --- CHI TIẾT CÁC KHỐI BENTO ---

  Widget _buildHeaderBento(
    BuildContext context,
    AuthProvider auth,
    String quote,
    bool isDark,
  ) {
    final settings = DatabaseService.getSettings();
    final notifyProvider = context.watch<NotificationProvider>();
    return Row(
      children: [
        // Bell Icon -> Di chuyển từ Right Sidebar vào
        _circleIconButton(
          notifyProvider.isEnabled
              ? CupertinoIcons.bell_fill
              : CupertinoIcons.bell_slash,
          notifyProvider.isEnabled ? Colors.orange : Colors.grey,
          () => _showNotificationQuickSettings(context, notifyProvider, isDark),
        ),
        const SizedBox(width: 12),
        // Greeting & Quote
        Expanded(
          child: Column(
            children: [
              Text(
                "Hello, ${auth.currentUser?.displayName ?? 'Learner'}",
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                quote,
                style: const TextStyle(fontSize: 11, color: Colors.grey),
                textAlign: TextAlign.center,
                maxLines: 1,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Avatar -> Di chuyển từ Left Sidebar vào
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child: AppAvatar(
            localPath: settings.userAvatarPath,
            networkUrl: auth.currentUser?.photoURL,
            radius: 20,
          ),
        ),
      ],
    );
  }

  Widget _buildDailyGoalBento(
    BuildContext context,
    HomeProvider home,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(28),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10),
        ],
      ),
      child: Row(
        children: [
          _buildProgressCircle(home.dailyProgressPercent, isDark),
          const SizedBox(width: 20),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Daily Goal",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                const Text(
                  "You're almost there...",
                  style: TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 12),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    final topic = home.getNextStudyTopic();
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => StudyScreen(topic: topic),
                      ),
                    );
                  },
                  child: const Text(
                    "Continue Learning",
                    style: TextStyle(color: Colors.white),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuizBento(BuildContext context, bool isDark) {
    return _bentoBox(
      color: Colors.purple.withOpacity(0.1),
      icon: CupertinoIcons.rocket_fill,
      iconColor: Colors.purple,
      title: "Daily Quiz",
      subtitle: "Boost streak",
      onTap: () => Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (_) => const QuizConfigurationScreen(initialTopic: 'All'),
        ),
      ),
    );
  }

  Widget _buildWordOfDayBento(BuildContext context, String word, bool isDark) {
    return _bentoBox(
      color: Colors.blue.withOpacity(0.1),
      icon: CupertinoIcons.lightbulb_fill,
      iconColor: Colors.blue,
      title: "Word of Day",
      subtitle: word.toUpperCase(),
      onTap: () {}, // TODO: Xem chi tiết từ
    );
  }

  Widget _buildBottomActions(
    BuildContext context,
    HomeProvider home,
    bool isDark,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: [
        _actionIcon(
          CupertinoIcons.clock_fill,
          "History",
          Colors.blue,
          () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const HistoryScreen()),
          ),
        ),

        _actionIcon(
          CupertinoIcons.bookmark_fill,
          "Saved",
          Colors.green,
          () => Navigator.push(
            context,
            CupertinoPageRoute(builder: (_) => const SavedWordsScreen()),
          ),
        ),

        _actionIcon(
          CupertinoIcons.exclamationmark_triangle_fill,
          "Mistakes",
          Colors.red,
          () {
            Navigator.pushNamed(context, AppRoutes.review);
          },
        ),

        _actionIcon(
          CupertinoIcons.flame_fill,
          "${home.currentStreak}d",
          Colors.orange,
          () {
            Navigator.pushNamed(
              context,
              AppRoutes.stats,
            ); // Màn hình chứa Calendar
          },
        ),
      ],
    );
  }

  // --- HELPER METHODS ---

  Widget _bentoBox({
    required Color color,
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(24),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: iconColor, size: 28),
            const SizedBox(height: 12),
            Text(
              title,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
            ),
            Text(
              subtitle,
              style: TextStyle(
                color: iconColor.withOpacity(0.7),
                fontSize: 11,
                fontWeight: FontWeight.bold,
              ),
              maxLines: 1,
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return Column(
      children: [
        _circleIconButton(icon, color, onTap),
        const SizedBox(height: 6),
        Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
        ),
      ],
    );
  }

  Widget _circleIconButton(IconData icon, Color color, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: color, size: 22),
      ),
    );
  }

  Widget _buildProgressCircle(double percent, bool isDark) {
    return SizedBox(
      width: 75,
      height: 75,
      child: Stack(
        fit: StackFit.expand,
        children: [
          CircularProgressIndicator(
            value: percent,
            strokeWidth: 8,
            backgroundColor: isDark ? Colors.white10 : Colors.grey[200],
            color: AppConstants.accentColor,
          ),
          Center(
            child: Text(
              "${(percent * 100).toInt()}%",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicsBento(
    BuildContext context,
    List<String> topics,
    bool isDark,
  ) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "New Update",
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 12),
          ...topics.map(
            (t) => ListTile(
              contentPadding: EdgeInsets.zero,
              leading: const Icon(CupertinoIcons.book, size: 18),
              title: Text(t, style: const TextStyle(fontSize: 14)),
              trailing: const Icon(Icons.chevron_right, size: 16),
              onTap: () => Navigator.push(
                context,
                CupertinoPageRoute(builder: (_) => StudyScreen(topic: t)),
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showSimpleDialog(BuildContext context, String title, String msg) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(title),
        content: Text(msg),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _showNotificationQuickSettings(
    BuildContext context,
    NotificationProvider provider,
    bool isDark,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: isDark ? AppConstants.darkCardColor : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Nhắc nhở học tập",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            SwitchListTile(
              title: const Text("Bật thông báo hàng ngày"),
              value: provider.isEnabled,
              onChanged: (v) => provider.toggleNotification(v),
            ),
            if (provider.isEnabled)
              ListTile(
                leading: const Icon(CupertinoIcons.clock, color: Colors.blue),
                title: const Text("Giờ nhắc nhở hiện tại"),
                trailing: Text(
                  provider.reminderTime?.format(context) ?? "20:00",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 18,
                    color: Colors.blue,
                  ),
                ),
                onTap: () async {
                  final time = await showTimePicker(
                    context: context,
                    initialTime:
                        provider.reminderTime ??
                        const TimeOfDay(hour: 20, minute: 0),
                  );
                  if (time != null) provider.updateReminderTime(time);
                },
              ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}
