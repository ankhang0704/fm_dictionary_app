import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/data/services/features/quiz_service.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- PROVIDERS & MODELS ---
import '../providers/roadmap_provider.dart';
import '../../../learning/presentation/providers/quiz_provider.dart';

class LearningRoadmapScreen extends StatelessWidget {
  const LearningRoadmapScreen({super.key});

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
        appBar: _buildGlassHeader(context),
        body: Consumer<RoadmapProvider>(
          builder: (context, provider, _) {
            final currentChapter =
                provider.chapters[provider.selectedChapterIndex];

            return ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.only(top: 20, bottom: 100),
              itemCount: currentChapter.lessons.length,
              itemBuilder: (context, index) {
                final lesson = currentChapter.lessons[index];

                // Legacy Logic Mapping
                final isUnlocked = provider.isLessonUnlocked(
                  lesson.globalIndex,
                );
                final progress = provider.getLessonProgress(lesson.globalIndex);

                // Node Status Logic
                final bool isCompleted = progress >= 0.8;
                final bool isLocked = !isUnlocked;
                final bool isCurrent = isUnlocked && !isCompleted;

                // Position Logic
                final bool isLeft = index % 2 == 0;

                // Topic Divider Logic
                bool showTopicDivider = false;
                if (index == 0) {
                  showTopicDivider = true;
                } else {
                  final prevLesson = currentChapter.lessons[index - 1];
                  if (lesson.dominantTopic != prevLesson.dominantTopic) {
                    showTopicDivider = true;
                  }
                }

                // Path Line connecting to the previous node (if not the first in list/after divider)
                final bool showPath = index > 0 && !showTopicDivider;
                // If previous was completed, the path to this node is marked completed
                final bool isPathCompleted =
                    index > 0 &&
                    provider.getLessonProgress(
                          currentChapter.lessons[index - 1].globalIndex,
                        ) >=
                        0.8;

                return Column(
                  children: [
                    if (showTopicDivider)
                      _buildTopicDivider(lesson.dominantTopic),

                    // Fixed height container to allow perfect CustomPaint Zig-zag line connections
                    SizedBox(
                      height: 140,
                      child: Stack(
                        alignment: Alignment.center,
                        children: [
                          // 1. ZIG-ZAG PATH LINE
                          if (showPath)
                            Positioned.fill(
                              child: CustomPaint(
                                painter: _ZigZagPathPainter(
                                  isLeftToRight:
                                      !isLeft, // if current is Right, path goes Left -> Right
                                  isCompleted: isPathCompleted,
                                ),
                              ),
                            ),

                          // 2. THE NODE ITSELF
                          Align(
                            alignment: isLeft
                                ? const Alignment(-0.5, 0)
                                : const Alignment(0.5, 0),
                            child: _buildDuolingoNode(
                              context: context,
                              lesson: lesson, // Note: RoadmapLesson model
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
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:0.1),
            elevation: 0,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Consumer<RoadmapProvider>(
              builder: (context, provider, _) => Text(
                provider.chapters[provider.selectedChapterIndex].title,
                style: AppTypography.heading2.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ),
            centerTitle: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.white.withValues(alpha:0.2), height: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicDivider(String topicName) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 24, horizontal: 30),
      child: Row(
        children: [
          Expanded(
            child: Container(height: 2, color: Colors.white.withValues(alpha:0.3)),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Chủ đề: $topicName",
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: Colors.white.withValues(alpha:0.8),
                letterSpacing: 1.2,
              ),
            ),
          ),
          Expanded(
            child: Container(height: 2, color: Colors.white.withValues(alpha:0.3)),
          ),
        ],
      ),
    );
  }

  Widget _buildDuolingoNode({
    required BuildContext context,
    required dynamic
    lesson, // Typed dynamically assuming RoadmapLesson properties
    required bool isCompleted,
    required bool isCurrent,
    required bool isLocked,
    required double progress,
  }) {
    int wordsLearned = (progress * lesson.words.length).toInt();

    // Node Visuals
    Widget nodeIcon;
    BoxDecoration nodeDecoration;
    double nodeSize = isCurrent ? 80.0 : 70.0;

    if (isCompleted) {
      nodeDecoration = const BoxDecoration(
        color: AppColors.success,
        shape: BoxShape.circle,
        boxShadow: [
          BoxShadow(color: AppColors.success, blurRadius: 15, spreadRadius: 2),
        ],
      );
      nodeIcon = const Icon(
        CupertinoIcons.checkmark_alt,
        color: Colors.white,
        size: 36,
      );
    } else if (isCurrent) {
      nodeDecoration = BoxDecoration(
        color: AppColors.warning, // Can be meshPurple based on preference
        shape: BoxShape.circle,
        border: Border.all(width: 4, color: Colors.white),
        boxShadow: [
          BoxShadow(
            color: AppColors.warning.withValues(alpha:0.6),
            blurRadius: 20,
            spreadRadius: 4,
          ),
        ],
      );
      nodeIcon = const Icon(
        CupertinoIcons.star_fill,
        color: Colors.white,
        size: 40,
      );
    } else {
      // Locked Node - Circular Glassmorphism Effect
      nodeDecoration = BoxDecoration(
        color: Colors.white.withValues(alpha:0.15),
        shape: BoxShape.circle,
        border: Border.all(width: 2, color: Colors.white.withValues(alpha:0.3)),
      );
      nodeIcon = const Icon(
        CupertinoIcons.lock_fill,
        color: AppColors.textSecondary,
        size: 32,
      );
    }

    return GestureDetector(
      onTap: isLocked ? null : () => _showGlassBottomSheet(context, lesson),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Circular Node
          SizedBox(
            width: nodeSize,
            height: nodeSize,
            child: isLocked
                ? ClipOval(
                    child: BackdropFilter(
                      filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                      child: Container(
                        decoration: nodeDecoration,
                        child: nodeIcon,
                      ),
                    ),
                  )
                : Container(decoration: nodeDecoration, child: nodeIcon),
          ),
          const SizedBox(height: 8),

          // ZERO PIXEL OVERFLOW: Constrained Text
          SizedBox(
            width: 120, // Strict constraint to prevent row/column overflow
            child: Column(
              children: [
                Text(
                  "Bài ${lesson.globalIndex + 1}",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                    color: isLocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  "$wordsLearned/${lesson.words.length} từ",
                  style: AppTypography.bodyMedium.copyWith(
                    color: isLocked
                        ? AppColors.textSecondary
                        : AppColors.textPrimary.withValues(alpha:0.8),
                    fontSize: 12,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 1,
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

  void _showGlassBottomSheet(BuildContext context, dynamic lesson) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppLayout.bentoBorderRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppLayout.defaultPadding * 2),
            decoration: BoxDecoration(
              color: AppColors.meshBlue.withValues(alpha:0.15),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha:0.3),
                  width: 1.5,
                ),
              ),
            ),
            child: SafeArea(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 50,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha:0.5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  Text(
                    "Bài ${lesson.globalIndex + 1}",
                    style: AppTypography.heading1.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 8),

                  Text(
                    "Chủ đề: ${lesson.dominantTopic}",
                    style: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  // Smart Action Button 1: Học Flashcard
                  SmartActionButton(
                    text: "Học Flashcard",
                    isGlass: false,
                    isLoading: false,
                    onPressed: () {
                      Navigator.pop(context);
                      // Route with legacy args requirement
                      Navigator.pushNamed(
                        context,
                        AppRoutes.study,
                        arguments: {
                          'words': lesson.words,
                          'isFromRoadmap': true,
                        },
                      );
                    },
                  ),
                  const SizedBox(height: 16),

                  // Smart Action Button 2: Làm Quiz
                  SmartActionButton(
                    text: "Thi vượt cấp (80%)",
                    isGlass: true, // Use glass aesthetic for secondary action
                    isLoading: false,
                    onPressed: () {
                      Navigator.pop(context);

                      // Legacy logic: Init provider state before routing
                      // Using context.read safely since we are before pushing
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
        ),
      ),
    );
  }
}

// ===========================================================================
// CUSTOM ZIG-ZAG PATH PAINTER
// ===========================================================================

class _ZigZagPathPainter extends CustomPainter {
  final bool isLeftToRight;
  final bool isCompleted;

  _ZigZagPathPainter({required this.isLeftToRight, required this.isCompleted});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isCompleted ? AppColors.success : Colors.white.withValues(alpha:0.3)
      ..strokeWidth = 12.0
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final path = Path();

    // Nodes are at Y-center of the 140 height container.
    // X centers correspond to the Align offsets: (-0.5, 0) and (0.5, 0).
    // Width ratio equivalent: Left node center ≈ 25% of width. Right node center ≈ 75% of width.

    final double leftX = size.width * 0.25;
    final double rightX = size.width * 0.75;

    if (isLeftToRight) {
      // Path from Previous (Left/Top) to Current (Right/Bottom)
      path.moveTo(leftX, -size.height / 2);
      path.lineTo(
        rightX,
        size.height / 2 - 20,
      ); // -20 offset to sit just behind the node
    } else {
      // Path from Previous (Right/Top) to Current (Left/Bottom)
      path.moveTo(rightX, -size.height / 2);
      path.lineTo(leftX, size.height / 2 - 20);
    }

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
