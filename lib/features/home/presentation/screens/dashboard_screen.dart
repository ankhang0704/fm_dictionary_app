import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/bento_tts_button.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';
import 'package:fm_dictionary/features/settings/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';

// --- CORE / UTILS / CONSTANTS ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/widgets/common/app_avatar.dart';

// --- MODELS / PROVIDERS / SERVICES ---
import '../../../../data/services/database/database_service.dart';
import '../../../../data/models/word_model.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../roadmap/presentation/providers/roadmap_provider.dart';
import '../../../settings/presentation/providers/notification_provider.dart';
import '../providers/home_provider.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Consumer2<HomeProvider, AuthProvider>(
          builder: (context, home, auth, child) {
            if (home.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppLayout.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- SECTION A: HERO HEADER ---
                  _buildHeroHeader(context, home, auth),
                  const SizedBox(height: 24),

                  // --- SECTION B: VIBRANT BENTO GRID ---
                  // Card 1: Daily Goal
                  _buildDailyGoalCard(context, home),
                  const SizedBox(height: 16),

                  // Row 1: Streak & Daily Quiz
                  Row(
                    children: [
                      Expanded(
                        child: _buildStreakCard(context, home.currentStreak),
                      ),
                      const SizedBox(width: 16),
                      Expanded(child: _buildDailyQuizCard(context)),
                    ],
                  ),
                  const SizedBox(height: 16),

                  // Card 4: Word of the Day
                  if (home.wordOfTheDay != null) ...[
                    _buildWordOfTheDayCard(context, home.wordOfTheDay!),
                    const SizedBox(height: 16),
                  ],

                  // Row 2: Kho tàng & Quick Search
                  Row(
                    children: [
                      Expanded(child: _buildTreasuresCard(context)),
                      const SizedBox(width: 16),
                      Expanded(child: _buildQuickSearchCard(context)),
                    ],
                  ),

                  const SizedBox(height: 100),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  // New Vibrant Bento UI block (Logic, Theme, and Localization perfectly preserved!)

Widget _buildHeroHeader(
    BuildContext context,
    HomeProvider home,
    AuthProvider auth,
  ) {
    final settings = DatabaseService.getSettings();
    final notifyEnabled = context.select<NotificationProvider, bool>(
      (p) => p.isEnabled,
    );
    final userName = context.select<SettingsProvider, String>(
      (s) => s.settings.userName,
    );
    final displayName = auth.currentUser?.displayName?.isNotEmpty == true
        ? auth.currentUser!.displayName!
        : userName;

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children:[
        // LEFT SIDE (1/2 of the "2x2" feel): Hello + Name (Top) & Quote (Bottom)
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "Hello, $displayName!",
                  style: Theme.of(context).textTheme.displayMedium,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                home.quote.isNotEmpty ? home.quote : '"Học, học nữa, học mãi"',
                style: Theme.of(context).textTheme.bodyMedium,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        
        const SizedBox(width: 8),
        
        // MIDDLE: Notification Bell in a solid Bento circle
        Container(
          margin: const EdgeInsets.symmetric(horizontal: 8),
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              notifyEnabled
                  ? CupertinoIcons.bell_fill
                  : CupertinoIcons.bell,
              color: notifyEnabled
                  ? AppColors.warning
                  : Theme.of(context).textTheme.bodyMedium?.color,
            ),
            onPressed: () => _showNotificationQuickSettings(
              context,
              context.read<NotificationProvider>(),
            ),
          ),
        ),
        
        // RIGHT SIDE (The biggest element): Enlarged Avatar
        GestureDetector(
          onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
          child:
              auth.currentUser?.photoURL?.isNotEmpty == true ||
                      settings.userAvatarPath?.isNotEmpty == true
              ? AppAvatar(
                  localPath: settings.userAvatarPath,
                  networkUrl: auth.currentUser?.photoURL,
                  radius: 34, // ENLARGED AVATAR for prominence
                )
              : CircleAvatar(
                  radius: 34, // ENLARGED AVATAR for prominence
                  backgroundColor: AppColors.bentoBlue.withValues(
                    alpha: 0.15,
                  ),
                  child: Text(
                    displayName.isNotEmpty
                        ? displayName[0].toUpperCase()
                        : '?',
                    style: Theme.of(context).textTheme.displayMedium // Increased text size to match larger avatar
                        ?.copyWith(color: AppColors.bentoBlue),
                  ),
                ),
        ),
      ],
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, HomeProvider home) {
    final studied = home.wordsLearnedToday;
    final target = home.dailyGoalTarget;
    final progress = home.dailyProgressPercent;
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).toInt();

// New Vibrant Bento UI block (Logic, Theme, and Localization perfectly preserved!)

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          Row(
            children:[
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.flag_fill,
                  color: AppColors.success,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  "Mục tiêu hôm nay: $studied/$target",
                  // CHANGED: Reduced from displaySmall to titleMedium for better fit
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Row(
            children:[
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(100),
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    minHeight: 12,
                    backgroundColor: AppColors.success.withValues(alpha: 0.1),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                      AppColors.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "$percentage%",
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          SmartActionButton(
            text: "Tiếp tục", // CHANGED: Shortened text
            icon: CupertinoIcons.play_circle_fill, // CHANGED: Added icon
            color: AppColors.success, // CHANGED: Added vibrant color
            onPressed: () async {
              final roadmap = context.read<RoadmapProvider>();
              RoadmapLesson? targetLesson;

              for (var chapter in roadmap.chapters) {
                for (var lesson in chapter.lessons) {
                  if (roadmap.getLessonProgress(lesson.globalIndex) < 0.8) {
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

              await Navigator.pushNamed(
                context,
                AppRoutes.study,
                arguments: {'words': targetLesson.words, 'isFromRoadmap': true},
              );
              home.updateDailyProgress();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int currentStreak) {
    return BentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.stats),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.warning.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.flame_fill,
              color: AppColors.warning,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "STREAK",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$currentStreak Ngày",
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuizCard(BuildContext context) {
    return BentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.quizConfig),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bentoPurple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.bolt_fill,
              color: AppColors.bentoPurple,
              size: 32,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "DAILY QUIZ",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Thử thách",
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: AppColors.bentoPurple),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordOfTheDayCard(BuildContext context, Word word) {
    return BentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.wordDetail,
        arguments: {'word': word},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "WORD OF THE DAY",
                style: Theme.of(
                  context,
                ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
              ),
              BentoTtsButton(text: word.word, size: 18),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            word.word,
            style: Theme.of(context).textTheme.displayMedium,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          if (word.phoneticUK.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              word.phoneticUK,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontStyle: FontStyle.italic,
                color: AppColors.bentoBlue,
              ),
            ),
          ],
          const SizedBox(height: 8),
          Text(
            word.meaning,
            style: Theme.of(context).textTheme.bodyLarge,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }

  Widget _buildTreasuresCard(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "KHO TÀNG",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildQuickLink(
            context,
            icon: CupertinoIcons.star_fill,
            color: AppColors.bentoMint,
            label: "${WordService().getSavedWords().length} Từ đã lưu",
            onTap: () => Navigator.pushNamed(context, AppRoutes.saved),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8.0),
            child: Divider(height: 1),
          ),
          _buildQuickLink(
            context,
            icon: CupertinoIcons.time_solid,
            color: AppColors.bentoBlue,
            label: "Lịch sử học",
            onTap: () => Navigator.pushNamed(context, AppRoutes.history),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickLink(
    BuildContext context, {
    required IconData icon,
    required Color color,
    required String label,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 4.0),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(icon, color: color, size: 16),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                label,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.w600),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildQuickSearchCard(BuildContext context) {
    return BentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "TÌM NHANH",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(
                context,
              ).colorScheme.primary.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.search,
              color: Theme.of(context).colorScheme.primary,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Tra từ...",
            style: Theme.of(
              context,
            ).textTheme.bodyMedium?.copyWith(fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // LEGACY LOGIC METHODS
  // ===========================================================================

  // New Vibrant Bento UI block (Logic, Theme, and Localization perfectly preserved!)

void _showNotificationQuickSettings(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ListenableBuilder(
        // ListenableBuilder automatically listens to the provider and rebuilds the BottomSheet 
        // instantly when toggleNotification() triggers notifyListeners().
        listenable: provider, 
        builder: (context, child) {
          return Container(
            decoration: BoxDecoration(
              color: Theme.of(context).scaffoldBackgroundColor,
              borderRadius: const BorderRadius.vertical(
                top: Radius.circular(AppLayout.bentoBorderRadius),
              ),
            ),
            padding: const EdgeInsets.all(AppLayout.defaultPadding),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children:[
                Text(
                  "Nhắc nhở học tập",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                const SizedBox(height: 24),
                BentoCard(
                  padding: EdgeInsets.zero,
                  child: Column(
                    children:[
                      SwitchListTile(
                        title: Text(
                          "Bật thông báo hàng ngày",
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        value: provider.isEnabled,
                        activeColor: AppColors.bentoBlue,
                        onChanged: (v) => provider.toggleNotification(v),
                      ),
                      if (provider.isEnabled) ...[
                        const Divider(height: 1),
                        ListTile(
                          leading: const Icon(
                            CupertinoIcons.clock,
                            color: AppColors.bentoBlue,
                          ),
                          title: Text(
                            "Giờ nhắc nhở",
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                          trailing: Text(
                            provider.reminderTime?.format(context) ?? "20:00",
                            style: Theme.of(context).textTheme.displaySmall
                                ?.copyWith(color: AppColors.bentoBlue),
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
                      ],
                    ],
                  ),
                ),
                const SafeArea(child: SizedBox(height: 20)),
              ],
            ),
          );
        },
      ),
    );
  }
}
