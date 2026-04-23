import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';

// --- PROVIDERS & SCREENS ---
import '../providers/roadmap_provider.dart';
import 'learning_roadmap_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: Consumer<RoadmapProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return Center(
                child: CircularProgressIndicator(
                  color: Theme.of(context).primaryColor,
                ),
              );
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // --- BENTO HEADER ---
                _buildHeader(context),

                // --- LIST OF BENTO CARDS ---
                Expanded(
                  child: ListView.separated(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.only(
                      left: AppLayout.defaultPadding,
                      right: AppLayout.defaultPadding,
                      top: AppLayout.defaultPadding,
                      bottom: 140, // Extra padding for navigation clearance
                    ),
                    itemCount: provider.chapters.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final chapter = provider.chapters[index];

                      // 1. Calculate Total Words (LOGIC PRESERVED)
                      int totalWords = chapter.lessons.fold(
                        0,
                        (sum, lesson) => sum + lesson.words.length,
                      );

                      // 2. Calculate Current Chapter Progress (LOGIC PRESERVED)
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

                      // 3. Locking Mechanism (LOGIC PRESERVED)
                      bool isLocked = false;
                      if (index > 0) {
                        final prevChapter = provider.chapters[index - 1];
                        double prevTotalProgress = 0.0;
                        for (var lesson in prevChapter.lessons) {
                          prevTotalProgress += provider.getLessonProgress(
                            lesson.globalIndex,
                          );
                        }
                        double prevChapterProgress = prevChapter.lessons.isEmpty
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
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(AppLayout.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'roadmap.roadmap_header'.tr(),

            style: Theme.of(context).textTheme.displayLarge,
          ),
          const SizedBox(height: 4),
          Text(
               'roadmap.roadmap_title'.tr(),
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildChapterCard({
    required BuildContext context,
    required RoadmapProvider provider,
    required int chapterIndex,
    required dynamic chapter,
    required int totalWords,
    required double progress,
    required bool isLocked,
  }) {
    final double cardOpacity = isLocked ? 0.6 : 1.0;
    final Color accentColor = chapterIndex % 2 == 0
        ? AppColors.bentoBlue
        : AppColors.bentoPurple;

    return Opacity(
      opacity: cardOpacity,
      child: BentoCard(
        onTap: isLocked
            ? null
            : () {
                // STRICTLY PRESERVED LOGIC
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
            // LEFT: Chapter Number Badge (Vibrant Circle)
            Container(
              width: 50,
              height: 50,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                color: isLocked
                    ? Theme.of(context).dividerColor.withValues(alpha: 0.1)
                    : accentColor.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: Text(
                "${chapterIndex + 1}",
                style: Theme.of(context).textTheme.displaySmall?.copyWith(
                  color: isLocked
                      ? Theme.of(context).textTheme.bodySmall?.color
                      : accentColor,
                ),
              ),
            ),
            const SizedBox(width: 16),

            // MIDDLE: Title, Subtitle & Progress Bar
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: Theme.of(context).textTheme.displaySmall?.copyWith(
                      fontSize: 16,
                      color: isLocked
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : null,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '$totalWords từ vựng (${chapter.lessons.length} Bài học)',
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 12),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 12),

                  // Progress Bar
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 8,
                            backgroundColor: Theme.of(
                              context,
                            ).dividerColor.withValues(alpha: 0.1),
                            valueColor: AlwaysStoppedAnimation<Color>(
                              isLocked ? Colors.grey : AppColors.success,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        "${(progress * 100).toInt()}%",
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: isLocked ? null : AppColors.success,
                          fontWeight: FontWeight.bold,
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
                    : Theme.of(context).dividerColor.withValues(alpha: 0.05),
                shape: BoxShape.circle,
              ),
              child: Icon(
                isLocked
                    ? CupertinoIcons.lock_fill
                    : CupertinoIcons.chevron_right,
                color: isLocked
                    ? Theme.of(context).textTheme.bodySmall?.color
                    : Theme.of(context).textTheme.displayLarge?.color,
                size: 18,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
