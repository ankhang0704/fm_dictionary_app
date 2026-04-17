// lib/features/home/presentation/screens/dashboard_screen.dart

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/widgets/common/app_avatar.dart';
import 'package:fm_dictionary/core/widgets/common/home_search_bar.dart';
import 'package:fm_dictionary/data/models/word_model.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:fm_dictionary/features/saved/presentation/screens/saved_words_screen.dart';
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
                              home.wordOfTheDay!,
                              isDark,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      const HomeSearchBar(), // Nhúng SearchScreen vào đây luôn để tận dụng lại logic và UI
                      // 4. CURRENT JOURNEY (New Update)
                      _buildCurrentJourneyBento(
                        context,
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
    final studied = home.wordsLearnedToday;
    final target = home.dailyGoalTarget;
    final isDone = studied >= target;

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
                  "Mục tiêu ngày",
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  isDone
                      ? "Tuyệt vời, bạn đã đạt mục tiêu!"
                      : "Đã học $studied / $target từ",
                  style: TextStyle(
                    fontSize: 12,
                    color: isDone ? AppConstants.successColor : Colors.grey,
                    fontWeight: FontWeight.w600,
                  ),
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
                    // LOGIC CONTINUE LEARNING SIÊU CHUẨN
                    final roadmap = context.read<RoadmapProvider>();
                    RoadmapLesson? targetLesson;

                    // Quét toàn bộ lộ trình, tìm Bài học ĐẦU TIÊN chưa đạt 80%
                    for (var chapter in roadmap.chapters) {
                      for (var lesson in chapter.lessons) {
                        if (roadmap.getLessonProgress(lesson.globalIndex) <
                            0.8) {
                          targetLesson = lesson;
                          break;
                        }
                      }
                      if (targetLesson != null) break;
                    }

                    if (targetLesson == null) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text(
                            "Chúc mừng! Bạn đã hoàn thành toàn bộ lộ trình!",
                          ),
                        ),
                      );
                      return;
                    }

                    // Chuyển thẳng vào StudyScreen với cờ isFromRoadmap = true
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => StudyScreen(
                          words: targetLesson!.words,
                          isFromRoadmap:
                              true, // Rất quan trọng để tính Gamification
                        ),
                      ),
                    ).then((_) {
                      // Sau khi học xong quay về, refresh lại Home để cập nhật tiến độ
                      home.updateDailyProgress();
                    });
                  },
                  child: const Text(
                    "Tiếp tục học",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
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

  Widget _buildWordOfDayBento(BuildContext context, Word word, bool isDark) {
    return _bentoBox(
      color: Colors.blue.withOpacity(0.1),
      icon: CupertinoIcons.lightbulb_fill,
      iconColor: Colors.blue,
      title: "Word of Day",
      subtitle: word.word.toUpperCase(),
      onTap: () {
        Navigator.pushNamed(
          context,
          AppRoutes.wordDetail,
          arguments: {'word': word},
        );
      },
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
          () => Navigator.pushNamed(context, AppRoutes.history),
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
          "Smart Review",
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

  // XÓA HÀM _buildTopicsBento VÀ THAY BẰNG KHỐI NÀY: CURRENT JOURNEY BENTO
  Widget _buildCurrentJourneyBento(BuildContext context, bool isDark) {
    final roadmap = context.watch<RoadmapProvider>();

    // Tìm chặng đang học dở
    RoadmapChapter? currentChapter;
    int completedLessons = 0;

    for (var chapter in roadmap.chapters) {
      bool isChapterDone = true;
      int doneCount = 0;
      for (var lesson in chapter.lessons) {
        if (roadmap.getLessonProgress(lesson.globalIndex) >= 0.8) {
          doneCount++;
        } else {
          isChapterDone = false;
        }
      }
      if (!isChapterDone) {
        currentChapter = chapter;
        completedLessons = doneCount;
        break;
      }
    }

    // Nếu học xong hết thì hiển thị Chặng cuối
    currentChapter ??= roadmap.chapters.last;

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(
          color: AppConstants.accentColor.withValues(alpha: 0.2),
        ),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.map_pin_ellipse,
              color: AppConstants.accentColor,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Chặng hiện tại: ${currentChapter.title}",
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  "Đã hoàn thành $completedLessons/${currentChapter.lessons.length} bài",
                  style: const TextStyle(fontSize: 12, color: Colors.grey),
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(10),
                  child: LinearProgressIndicator(
                    value: completedLessons / currentChapter.lessons.length,
                    minHeight: 6,
                    backgroundColor: Colors.grey.withValues(alpha: 0.2),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppConstants.accentColor,
                    ),
                  ),
                ),
              ],
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
