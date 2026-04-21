import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/glass_tts_button.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';
import 'package:provider/provider.dart';

// --- CORE / UTILS / CONSTANTS ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.meshBlue,
            AppColors.meshPurple,
            AppColors.meshMint,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        body: SafeArea(
          bottom: false, // Prevents bottom padding over the glassy nav bar
          child: Consumer2<HomeProvider, AuthProvider>(
            builder: (context, home, auth, child) {
              if (home.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: EdgeInsets.all(AppLayout.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // --- SECTION A: HERO HEADER ---
                    _buildHeroHeader(context, home, auth),
                    const SizedBox(height: 24),

                    // --- SECTION B: BENTO GRID ---
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

                    // Extra padding to scroll comfortably above the glass bottom bar
                    const SizedBox(height: 100),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildHeroHeader(
    BuildContext context,
    HomeProvider home,
    AuthProvider auth,
  ) {
    final settings = DatabaseService.getSettings();
    final notifyProvider = context.watch<NotificationProvider>();
    final userName = auth.currentUser?.displayName ?? 'Alex';

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ZERO OVERFLOW: FittedBox scales down text if name is too long
              FittedBox(
                fit: BoxFit.scaleDown,
                alignment: Alignment.centerLeft,
                child: Text(
                  "👋 Hello, $userName!",
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                ),
              ),
              const SizedBox(height: 4),
              // ZERO OVERFLOW: Ellipsis for long quotes
              Text(
                home.quote.isNotEmpty ? home.quote : '"Học, học nữa, học mãi"',
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        Row(
          children: [
            // Notification Bell
            IconButton(
              icon: Icon(
                notifyProvider.isEnabled
                    ? CupertinoIcons.bell_fill
                    : CupertinoIcons.bell,
                color: notifyProvider.isEnabled
                    ? AppColors.warning
                    : AppColors.textSecondary,
              ),
              onPressed: () =>
                  _showNotificationQuickSettings(context, notifyProvider),
            ),
            // Avatar
            GestureDetector(
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
              child: AppAvatar(
                localPath: settings.userAvatarPath,
                networkUrl: auth.currentUser?.photoURL,
                radius: 24, // Modern large avatar
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, HomeProvider home) {
    final studied = home.wordsLearnedToday;
    final target = home.dailyGoalTarget;
    final progress = home.dailyProgressPercent;

    // Safety check to ensure valid double
    final clampedProgress = progress.clamp(0.0, 1.0);
    final percentage = (clampedProgress * 100).toInt();

    return GlassBentoCard(
      onTap: null, // Tap handled by SmartActionButton
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  "🎯 Mục tiêu hôm nay: $studied/$target từ",
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Progress Bar with exact percentage
          Row(
            children: [
              Expanded(
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: clampedProgress,
                    minHeight: 12,
                    backgroundColor: Colors.white.withValues(alpha:0.2),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      AppColors.success,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "$percentage%",
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  color: AppColors.success,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SmartActionButton(
            text: "Tiếp tục chặng đường 🚀",
            isGlass: false,
            isLoading: false,
            onPressed: () async {
              // Legacy Logic Mapping: Scan roadmap for next lesson
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

              // Route properly
              await Navigator.pushNamed(
                context,
                AppRoutes.study,
                arguments: {'words': targetLesson.words, 'isFromRoadmap': true},
              );
              // Refresh home after coming back
              home.updateDailyProgress();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildStreakCard(BuildContext context, int currentStreak) {
    return GlassBentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.stats),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.flame_fill,
            color: AppColors.warning,
            size: 36,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "🔥 STREAK",
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "$currentStreak Ngày",
              style: AppTypography.heading2.copyWith(color: AppColors.warning),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyQuizCard(BuildContext context) {
    return GlassBentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.quizConfig),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            AppConstants.topicIcons['All'] ?? CupertinoIcons.bolt_fill,
            color: AppColors.meshPurple,
            size: 36,
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "⚡ DAILY QUIZ",
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              "Thử thách 5 phút",
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.meshPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWordOfTheDayCard(BuildContext context, Word word) {
    return GlassBentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.wordDetail,
        arguments: {'word': word},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📖 WORD OF THE DAY",
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      word.word,
                      style: AppTypography.heading2,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    if (word.phoneticUK.isNotEmpty) ...[
                      const SizedBox(height: 4),
                      Text(
                        word.phoneticUK,
                        style: AppTypography.ipaText.copyWith(
                          color: AppColors.textSecondary,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                    const SizedBox(height: 4),
                    Text(
                      word.meaning,
                      style: AppTypography.bodyMedium,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              // Glass TTS Icon Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.2),
                  shape: BoxShape.circle,
                ),
                child: GlassTtsButton(text: word.word),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildTreasuresCard(BuildContext context) {
    return GlassBentoCard(
      onTap: null, // Delegate tap to child elements
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "📚 KHO TÀNG",
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          // Top Half: Saved Words
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.saved),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.star_fill,
                  color: AppColors.meshMint,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "${WordService().getSavedWords().length} Từ đã lưu",
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
          const Divider(color: Colors.white24, height: 16),
          // Bottom Half: History
          InkWell(
            onTap: () => Navigator.pushNamed(context, AppRoutes.history),
            borderRadius: BorderRadius.circular(8),
            child: Row(
              children: [
                const Icon(
                  CupertinoIcons.time_solid,
                  color: AppColors.meshBlue,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    "Lịch sử học",
                    style: AppTypography.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickSearchCard(BuildContext context) {
    return GlassBentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            "🔍 TÌM NHANH",
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 32),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.3),
              borderRadius: BorderRadius.circular(100),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  CupertinoIcons.search,
                  size: 18,
                  color: AppColors.textPrimary,
                ),
                SizedBox(width: 8),
                Text(
                  "Tra từ...",
                  style: TextStyle(color: AppColors.textPrimary),
                ),
              ],
            ),
          ),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  // ===========================================================================
  // LEGACY LOGIC METHODS
  // ===========================================================================

  void _showNotificationQuickSettings(
    BuildContext context,
    NotificationProvider provider,
  ) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent, // Making the bottom sheet match UI
      builder: (context) => Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppLayout.bentoBorderRadius),
          ),
        ),
        padding: EdgeInsets.all(AppLayout.defaultPadding),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Nhắc nhở học tập", style: AppTypography.heading2),
            const SizedBox(height: 16),
            SwitchListTile(
              title: Text(
                "Bật thông báo hàng ngày",
                style: AppTypography.bodyLarge,
              ),
              value: provider.isEnabled,
              activeThumbColor: AppColors.meshBlue,
              onChanged: (v) => provider.toggleNotification(v),
            ),
            if (provider.isEnabled)
              ListTile(
                leading: const Icon(
                  CupertinoIcons.clock,
                  color: AppColors.meshBlue,
                ),
                title: Text(
                  "Giờ nhắc nhở hiện tại",
                  style: AppTypography.bodyMedium,
                ),
                trailing: Text(
                  provider.reminderTime?.format(context) ?? "20:00",
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.meshBlue,
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
            SafeArea(child: const SizedBox(height: 20)),
          ],
        ),
      ),
    );
  }
}
