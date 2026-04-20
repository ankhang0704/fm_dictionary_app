import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';

// --- PROVIDERS & SCREENS ---
import '../providers/roadmap_provider.dart';
import 'learning_roadmap_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

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
          bottom:
              false, // Ensures list scrolls nicely behind the glassy bottom nav
          child: Consumer<RoadmapProvider>(
            builder: (context, provider, child) {
              if (provider.isLoading) {
                return const Center(
                  child: CircularProgressIndicator(color: Colors.white),
                );
              }

              return Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // --- GLASS HEADER ---
                  _buildHeader(),

                  // --- LIST OF BENTO CARDS ---
                  Expanded(
                    child: ListView.separated(
                      physics: const BouncingScrollPhysics(),
                      padding: EdgeInsets.only(
                        left: AppLayout.defaultPadding,
                        right: AppLayout.defaultPadding,
                        top: AppLayout.defaultPadding,
                        bottom: 120, // Extra padding to clear Bottom Navigation
                      ),
                      itemCount: provider.chapters.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 16),
                      itemBuilder: (context, index) {
                        final chapter = provider.chapters[index];

                        // 1. Calculate Total Words
                        int totalWords = chapter.lessons.fold(
                          0,
                          (sum, lesson) => sum + lesson.words.length,
                        );

                        // 2. Calculate Current Chapter Progress
                        double totalProgress = 0.0;
                        for (var lesson in chapter.lessons) {
                          totalProgress += provider.getLessonProgress(
                            lesson.globalIndex,
                          );
                        }
                        double chapterProgress = chapter.lessons.isEmpty
                            ? 0.0
                            : (totalProgress / chapter.lessons.length).clamp(
                                0.0,
                                1.0,
                              );

                        // 3. Locking Mechanism:
                        // Chapter 0 is always unlocked.
                        // Subsequent chapters unlock if the previous chapter is >= 80% complete.
                        bool isLocked = false;
                        if (index > 0) {
                          final prevChapter = provider.chapters[index - 1];
                          double prevTotalProgress = 0.0;
                          for (var lesson in prevChapter.lessons) {
                            prevTotalProgress += provider.getLessonProgress(
                              lesson.globalIndex,
                            );
                          }
                          double prevChapterProgress =
                              prevChapter.lessons.isEmpty
                              ? 0.0
                              : prevTotalProgress / prevChapter.lessons.length;

                          if (prevChapterProgress < 0.8) {
                            isLocked = true;
                          }
                        }

                        return _buildChapterCard(
                          context: context,
                          provider: provider,
                          chapterIndex: index,
                          chapter: chapter,
                          totalWords: totalWords,
                          progress: chapterProgress,
                          isLocked: isLocked,
                        );
                      },
                    ),
                  ),
                ],
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

  Widget _buildHeader() {
    return Container(
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha:0.1),
        border: Border(
          bottom: BorderSide(color: Colors.white.withValues(alpha:0.2), width: 1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Lộ trình học tập',
            style: AppTypography.heading1.copyWith(
              color: AppColors.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '1500+ từ vựng được chia thành các chặng nhỏ',
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard({
    required BuildContext context,
    required RoadmapProvider provider,
    required int chapterIndex,
    required RoadmapChapter
    chapter, // Assuming RoadmapChapter class from legacy
    required int totalWords,
    required double progress,
    required bool isLocked,
  }) {
    // Determine opacity based on lock status
    final double cardOpacity = isLocked ? 0.6 : 1.0;

    return Opacity(
      opacity: cardOpacity,
      child: GlassBentoCard(
        // Disable onTap entirely if the chapter is locked
        onTap: isLocked
            ? null
            : () {
                // Keep exact legacy routing logic and provider state update
                provider.selectChapter(chapterIndex);
                Navigator.push(
                  context,
                  CupertinoPageRoute(
                    builder: (context) => const LearningRoadmapScreen(),
                  ),
                );
              },
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            // LEFT: Chapter Number Badge
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.white.withValues(alpha:0.1)
                    : AppColors.meshBlue.withValues(alpha:0.2),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isLocked
                      ? Colors.transparent
                      : AppColors.meshBlue.withValues(alpha:0.5),
                ),
              ),
              child: Text(
                "${chapterIndex + 1}",
                style: AppTypography.heading2.copyWith(
                  color: isLocked
                      ? AppColors.textSecondary
                      : AppColors.meshBlue,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // MIDDLE: Title, Subtitle & Progress Bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // ZERO OVERFLOW: Title wrapping
                  Text(
                    chapter.title,
                    style: AppTypography.heading3.copyWith(
                      color: isLocked
                          ? AppColors.textSecondary
                          : AppColors.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),

                  // Subtitle: Word/Lesson Count
                  Text(
                    '$totalWords từ vựng (${chapter.lessons.length} Bài học)',
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                      fontSize: 12,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),

                  // Progress Bar & Percentage
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(8),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.white.withValues(alpha:0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLocked ? Colors.grey : AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      SizedBox(
                        width: 35, // Fixed width prevents layout shifting
                        child: Text(
                          "${(progress * 100).toInt()}%",
                          style: AppTypography.bodyMedium.copyWith(
                            color: isLocked
                                ? AppColors.textSecondary
                                : AppColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.bold,
                          ),
                          textAlign: TextAlign.right,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 16),

            // RIGHT: Status Icon
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: isLocked
                    ? Colors.transparent
                    : Colors.white.withValues(alpha:0.2),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked
                    ? CupertinoIcons.lock_fill
                    : CupertinoIcons.play_arrow_solid,
                color: isLocked
                    ? AppColors.textSecondary
                    : AppColors.textPrimary,
                size: 20,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
