import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/data/services/features/quiz_service.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/widgets/bento_grid/bento_card.dart';

// --- PROVIDERS & MODELS ---
import '../providers/roadmap_provider.dart';
import '../../../learning/presentation/providers/quiz_provider.dart';

class LearningRoadmapScreen extends StatelessWidget {
  const LearningRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: Consumer<RoadmapProvider>(
        builder: (context, provider, _) {
          final currentChapter =
              provider.chapters[provider.selectedChapterIndex];

          return ListView.builder(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.only(top: 20, bottom: 120),
            itemCount: currentChapter.lessons.length,
            itemBuilder: (context, index) {
              final lesson = currentChapter.lessons[index];

              // --- STRICTLY PRESERVED BUSINESS LOGIC ---
              final isUnlocked = provider.isLessonUnlocked(lesson.globalIndex);
              final progress = provider.getLessonProgress(lesson.globalIndex);

              final bool isCompleted = progress >= 0.8;
              final bool isLocked = !isUnlocked;
              final bool isCurrent = isUnlocked && !isCompleted;
              final bool isLeft = index % 2 == 0;

              bool showTopicDivider = false;
              if (index == 0) {
                showTopicDivider = true;
              } else {
                final prevLesson = currentChapter.lessons[index - 1];
                if (lesson.dominantTopic != prevLesson.dominantTopic) {
                  showTopicDivider = true;
                }
              }

              final bool showPath = index > 0 && !showTopicDivider;
              final bool isPathCompleted =
                  index > 0 &&
                  provider.getLessonProgress(
                        currentChapter.lessons[index - 1].globalIndex,
                      ) >=
                      0.8;

              return Column(
                children: [
                  if (showTopicDivider)
                    _buildTopicDivider(context, lesson.dominantTopic),
                  SizedBox(
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // 1. VIBRANT PATH LINE
                        if (showPath)
                          Positioned.fill(
                            child: CustomPaint(
                              painter: _BentoPathPainter(
                                context: context,
                                isLeftToRight: !isLeft,
                                isCompleted: isPathCompleted,
                              ),
                            ),
                          ),

                        // 2. THE BENTO NODE
                        Align(
                          alignment: isLeft
                              ? const Alignment(-0.5, 0)
                              : const Alignment(0.5, 0),
                          child: _buildBentoNode(
                            context: context,
                            lesson: lesson,
                            isCompleted: isCompleted,
                            isCurrent: isCurrent,
                            isLocked: isLocked,
                            progress: progress,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildBentoHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Consumer<RoadmapProvider>(
        builder: (context, provider, _) => Text(
          provider.chapters[provider.selectedChapterIndex].title,
          style: Theme.of(context).textTheme.displaySmall,
        ),
      ),
    );
  }

// New Vibrant Bento UI block (Logic, Theme, and Localization perfectly preserved!)

  Widget _buildTopicDivider(BuildContext context, String topicName) {
    final dividerColor = Theme.of(context).dividerColor.withValues(alpha: 0.1);
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
      child: Row(
        children:[
          Expanded(child: Container(height: 2, color: dividerColor)),
          // Wrapped in Flexible to allow wrapping, preventing overflow pixels
          Flexible(
            flex: 4, // Gives the text generous room to wrap before shrinking the dividers too much
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Text(
                "Chủ đề: $topicName",
                textAlign: TextAlign.center, // Ensures nicely centered text when it wraps to a new line
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                ),
              ),
            ),
          ),
          Expanded(child: Container(height: 2, color: dividerColor)),
        ],
      ),
    );
  }

  Widget _buildBentoNode({
    required BuildContext context,
    required dynamic lesson,
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required double progress,
  }) {
    int wordsLearned = (progress * lesson.words.length).toInt();
    double nodeSize = isCurrent ? 84.0 : 72.0;

    Widget nodeIcon;
    Color nodeColor;

    if (isCompleted) {
      nodeColor = AppColors.success;
      nodeIcon = const Icon(
        CupertinoIcons.checkmark_alt,
        color: Colors.white,
        size: 36,
      );
    } else if (isCurrent) {
      nodeColor = AppColors.warning;
      nodeIcon = const Icon(
        CupertinoIcons.star_fill,
        color: Colors.white,
        size: 40,
      );
    } else {
      nodeColor = Theme.of(context).dividerColor.withValues(alpha: 0.1);
      nodeIcon = Icon(
        CupertinoIcons.lock_fill,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 32,
      );
    }

    return GestureDetector(
      onTap: isLocked ? null : () => _showBentoBottomSheet(context, lesson),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              border: isCurrent
                  ? Border.all(
                      width: 4,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    )
                  : null,
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: nodeColor.withValues(alpha: 0.3),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: nodeIcon,
          ),
          const SizedBox(height: 12),
          SizedBox(
            width: 120,
            child: Column(
              children: [
                Text(
                  "Bài ${lesson.globalIndex + 1}",
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLocked
                        ? Theme.of(context).textTheme.bodySmall?.color
                        : null,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$wordsLearned/${lesson.words.length} từ",
                  style: Theme.of(
                    context,
                  ).textTheme.bodySmall?.copyWith(fontSize: 12),
                  textAlign: TextAlign.center,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // ===========================================================================
  // INTERACTION / BOTTOM SHEET
  // ===========================================================================

  void _showBentoBottomSheet(BuildContext context, dynamic lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        width: double.infinity,
        padding: const EdgeInsets.all(AppLayout.defaultPadding * 2),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppLayout.bentoBorderRadius),
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 32),
              Text(
                "Bài ${lesson.globalIndex + 1}",
                style: Theme.of(context).textTheme.displayMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                "Chủ đề: ${lesson.dominantTopic}",
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),
              SmartActionButton(
                text: "Học Flashcard",
                onPressed: () {
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.study,
                    arguments: {'words': lesson.words, 'isFromRoadmap': true},
                  );
                },
              ),
              const SizedBox(height: 16),
              SmartActionButton(
                text: "Thi vượt cấp (80%)",
                onPressed: () {
                  Navigator.pop(context);
                  context.read<QuizProvider>().initQuiz(
                    lesson.words,
                    QuizMode.viToEn,
                    isFromRoadmap: true,
                  );
                  Navigator.pushNamed(context, AppRoutes.quizConfig);
                },
              ),
              const SizedBox(height: 16),
            ],
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// BENTO ZIG-ZAG PATH PAINTER
// ===========================================================================

class _BentoPathPainter extends CustomPainter {
  final BuildContext context;
  final bool isLeftToRight;
  final bool isCompleted;

  _BentoPathPainter({
    required this.context,
    required this.isLeftToRight,
    required this.isCompleted,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted
          ? AppColors.success
          : Theme.of(context).dividerColor.withValues(alpha: 0.15)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();
    final double leftX = size.width * 0.25;
    final double rightX = size.width * 0.75;

    if (isLeftToRight) {
      path.moveTo(leftX, -size.height / 2);
      path.lineTo(rightX, size.height / 2 - 20);
    } else {
      path.moveTo(rightX, -size.height / 2);
      path.lineTo(leftX, size.height / 2 - 20);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
