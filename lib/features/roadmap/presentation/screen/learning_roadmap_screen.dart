import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/data/services/features/quiz_service.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

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
    // 🛡️ Giảm nhẹ size node để tạo không gian an toàn tránh overflow
    double nodeSize = isCurrent ? 80.0 : 68.0;

    Widget nodeIcon;
    Color nodeColor;

    if (isCompleted) {
      nodeColor = AppColors.success;
      nodeIcon = const Icon(
        CupertinoIcons.checkmark_alt,
        color: Colors.white,
        size: 32,
      );
    } else if (isCurrent) {
      nodeColor = AppColors.warning;
      nodeIcon = const Icon(
        CupertinoIcons.star_fill,
        color: Colors.white,
        size: 36,
      );
    } else {
      nodeColor = Theme.of(context).dividerColor.withValues(alpha: 0.1);
      nodeIcon = Icon(
        CupertinoIcons.lock_fill,
        color: Theme.of(context).textTheme.bodySmall?.color,
        size: 28,
      );
    }

    return GestureDetector(
      onTap: isLocked ? null : () => _showBentoBottomSheet(context, lesson),
      child: Column(
        mainAxisSize:
            MainAxisSize.min, // 🛡️ Bắt buộc phải có để tránh giãn max height
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: nodeSize,
            height: nodeSize,
            decoration: BoxDecoration(
              color: nodeColor,
              shape: BoxShape.circle,
              border: isCurrent || isCompleted
                  ? Border.all(
                      width: isCurrent ? 5 : 3,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    )
                  : null,
              boxShadow: isLocked
                  ? null
                  : [
                      BoxShadow(
                        color: nodeColor.withValues(alpha: 0.4),
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(
                          0,
                          6,
                        ), // Giảm bóng để không chạm viền
                      ),
                    ],
            ),
            child: nodeIcon,
          ),
          const SizedBox(height: 8), // 🛡️ Giảm khoảng cách để tối ưu height
          SizedBox(
            width: 115,
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // 🛡️ CRITICAL FIX: Lỗi bottom overflow thường nằm ở đây
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
                  maxLines: 1, // 🛡️ Bắt buộc 1 dòng
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$wordsLearned/${lesson.words.length} từ",
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1, // 🛡️ Bắt buộc 1 dòng
                  overflow: TextOverflow.ellipsis,
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
            top: Radius.circular(
              AppLayout.bentoBorderRadius,
            ), // Giữ nguyên bo góc của bạn
          ),
        ),
        child: SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Drag Indicator
              Container(
                width: 48, // Chỉnh lại một chút cho cân đối
                height: 6,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(
                    alpha: 0.2,
                  ), // Giữ nguyên code Flutter mới của bạn
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),

              // NEW: Bento Header Icon (Vibrant Emerald)
              Container(
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.auto_stories_rounded, // Icon Sách vở/Học tập
                  color: Color(0xFF10B981),
                  size: 36,
                ),
              ),
              const SizedBox(height: 20),

              // Tiêu đề Bài học (Có truyền tham số index qua Localization)
              Text(
                'roadmap.lesson_number'.tr(
                  args: [(lesson.globalIndex + 1).toString()],
                ), // Thay cho "Bài X"
                style: Theme.of(context).textTheme.displayMedium?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),

              // Subtitle: Chủ đề (Truyền tham số topic)
              Text(
                'roadmap.lesson_topic'.tr(
                  args: [lesson.dominantTopic.toString()],
                ), // Thay cho "Chủ đề: X"
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  color: Theme.of(
                    context,
                  ).textTheme.bodySmall?.color, // Màu nhạt hơn (Secondary Text)
                  fontSize: 16,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 40),

              // Action 1: Học Flashcard (Vibrant Blue)
              SmartActionButton(
                text: 'roadmap.study_flashcards'
                    .tr(), // Thay cho "Học Flashcard"
                icon: Icons.style_rounded, // Icon dạng thẻ Flashcard
                color: const Color(0xFF3B82F6), // Vibrant Blue
                textColor: Colors.white,
                onPressed: () {
                  // LƯU Ý: LOGIC ĐƯỢC GIỮ NGUYÊN 100%
                  Navigator.pop(context);
                  Navigator.pushNamed(
                    context,
                    AppRoutes.study,
                    arguments: {'words': lesson.words, 'isFromRoadmap': true},
                  );
                },
              ),
              const SizedBox(height: 16),

              // Action 2: Thi vượt cấp (Vibrant Amber)
              SmartActionButton(
                text: 'roadmap.skip_test'.tr(), // Thay cho "Thi vượt cấp (80%)"
                icon: Icons.bolt_rounded, // Icon tia sét (nhanh/vượt cấp)
                color: const Color(
                  0xFFF59E0B,
                ), // Vibrant Amber (Màu vàng cam nổi bật)
                textColor: Colors.white,
                onPressed: () {
                  // LƯU Ý: LOGIC ĐƯỢC GIỮ NGUYÊN 100%
                  Navigator.pop(context);
                  context.read<QuizProvider>().initQuiz(
                    lesson.words,
                    QuizMode.viToEn,
                    isFromRoadmap: true,
                  );
                  Navigator.pushNamed(context, AppRoutes.quiz);
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
    // Bento Upgrade: Dual-stroke technique (shadow track + main track) for depth
    final Paint trackBackgroundPaint = Paint()
      ..color = isCompleted
          ? AppColors.success.withValues(alpha: 0.2)
          : Theme.of(context).dividerColor.withValues(alpha: 0.05)
      ..strokeWidth =
          16.0 // Wider background track
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final Paint mainPaint = Paint()
      ..color = isCompleted
          ? AppColors.success
          : Theme.of(context).dividerColor.withValues(alpha: 0.15)
      ..strokeWidth = 10.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Spread points out slightly more for elegant curves
    final double leftX = size.width * 0.20;
    final double rightX = size.width * 0.80;

    final double startX = isLeftToRight ? leftX : rightX;
    // Offset Y slightly to ensure it tucks perfectly underneath the node circle
    final double startY = -size.height / 2 + 10;

    final double endX = isLeftToRight ? rightX : leftX;
    final double endY = size.height / 2 - 25;

    path.moveTo(startX, startY);

    // PERFECT S-CURVE: Instead of an ugly straight zigzag (lineTo),
    // we use a Cubic Bezier curve to create a beautiful sweeping path.
    final double controlPointY = startY + (endY - startY) * 0.5;

    path.cubicTo(
      startX,
      controlPointY, // Pulls the curve down straight from the top node
      endX,
      controlPointY, // Pushes the curve up straight from the bottom node
      endX,
      endY, // Final destination
    );

    // Draw background track first, then vibrant main line inside it
    canvas.drawPath(path, trackBackgroundPaint);
    canvas.drawPath(path, mainPaint);
  }

  @override
  bool shouldRepaint(covariant _BentoPathPainter oldDelegate) {
    // Ensuring it dynamically repaints if state changes
    return oldDelegate.isLeftToRight != isLeftToRight ||
        oldDelegate.isCompleted != isCompleted;
  }
}
