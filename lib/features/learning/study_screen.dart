import 'dart:math';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/features/gamification/presentation/widgets/steak_celebration.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:provider/provider.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- PROVIDERS & MODELS ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/word_service.dart';
import '../../../../data/services/features/quiz_service.dart';

// --- SCREENS ---
import 'quiz_screen.dart';

class StudyScreen extends StatefulWidget {
  final List<Word> words;
  final bool isFromRoadmap;

  const StudyScreen({
    super.key,
    required this.words,
    this.isFromRoadmap = false,
  });

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
    // STRICTLY PRESERVED: Load words into provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadWordsFromLesson(widget.words);
    });
  }

  // --- ABSOLUTE ZERO-TOUCH BUSINESS LOGIC ---
  void _handleAnkiAction(bool isCorrect, bool isEasy) async {
    final provider = context.read<LearningProvider>();
    final homeProvider = context.read<HomeProvider>();
    final wordService = WordService();

    final isDone = provider.currentIndex == provider.words.length - 1;
    final String currentWordId = provider.currentWord?.id ?? '';

    // Process Repetition Logic
    bool showCelebration = await provider.processAnswer(isCorrect, isEasy);

    if (currentWordId.isNotEmpty) {
      await wordService.addWordsToDailyGoal([currentWordId]);
    }

    if (mounted) homeProvider.updateDailyProgress();

    // Streak Celebration Logic
    if (showCelebration && mounted) {
      StreakCelebrationDialog.show(context, streakDays: provider.currentStreak);
    }

    // Completion / Roadmap Logic
    if (isDone && mounted) {
      if (widget.isFromRoadmap) {
        context.read<QuizProvider>().initQuiz(
          widget.words,
          QuizMode.viToEn,
          isFromRoadmap: true,
        );
        Navigator.pushReplacement(
          context,
          CupertinoPageRoute(builder: (_) => const QuizScreen()),
        );
      } else {
        Navigator.pop(context);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            );
          }
          if (provider.words.isEmpty) return _buildEmptyState();
          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    // BENTO HEADER
                    _buildBentoHeader(context, provider),

                    // MAIN FLASHCARD AREA
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(AppLayout.defaultPadding),
                        child: _buildFlipCard(provider),
                      ),
                    ),

                    // FOOTER NAVIGATION
                    _buildFooterNav(context, provider),
                    const SizedBox(height: 20),
                  ],
                ),
              ),

              // RECORDING OVERLAY (BENTO STYLE)
              if (provider.isRecording)
                _buildRecordingOverlay(context, provider),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  Widget _buildBentoHeader(BuildContext context, LearningProvider provider) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(
              CupertinoIcons.xmark,
              color: Theme.of(context).textTheme.displayLarge?.color,
            ),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              ),
            ),
            child: Text(
              '${provider.currentIndex + 1} / ${provider.words.length}',
              style: Theme.of(
                context,
              ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(
              provider.isCurrentWordSaved
                  ? CupertinoIcons.bookmark_solid
                  : CupertinoIcons.bookmark,
              color: provider.isCurrentWordSaved
                  ? AppColors.error
                  : Theme.of(context).textTheme.displayLarge?.color,
            ),
            onPressed: provider.toggleSave,
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(LearningProvider provider) {
    return GestureDetector(
      onTap: provider.toggleFlip,
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 600),
        transitionBuilder: (Widget child, Animation<double> animation) {
          final rotate = Tween(begin: pi, end: 0.0).animate(animation);
          return AnimatedBuilder(
            animation: rotate,
            builder: (context, child) {
              final isBack = (child!.key == const ValueKey(true));
              var value = isBack ? min(rotate.value, pi / 2) : rotate.value;
              return Transform(
                transform: Matrix4.identity()
                  ..setEntry(3, 2, 0.001)
                  ..rotateY(value),
                alignment: Alignment.center,
                child: child,
              );
            },
            child: child,
          );
        },
        child: provider.isFlipped
            ? _buildBackFace(provider)
            : _buildFrontFace(provider),
      ),
    );
  }

  Widget _buildFrontFace(LearningProvider provider) {
    final word = provider.currentWord!;
    return BentoCard(
      key: const ValueKey(false),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _buildTopicTag(context, word.topic),
          ),
          Column(
            children: [
              const SizedBox(height: 32),
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word.word,
                  style: Theme.of(
                    context,
                  ).textTheme.displayLarge?.copyWith(fontSize: 48),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: _buildPronunciationItem(
                      context,
                      'US',
                      word.phoneticUS,
                      AppColors.bentoBlue,
                      () => provider.playAudio('en-US'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPronunciationItem(
                      context,
                      'UK',
                      word.phoneticUK,
                      AppColors.bentoPurple,
                      () => provider.playAudio('en-GB'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),
              _buildMicButton(context, provider),
              if (provider.pronunciationScore != null) ...[
                const SizedBox(height: 12),
                Text(
                  '${provider.pronunciationScore!.toStringAsFixed(0)}%',
                  style: Theme.of(context).textTheme.displayMedium?.copyWith(
                    color: provider.pronunciationScore! >= 70
                        ? AppColors.success
                        : AppColors.error,
                  ),
                ),
                if (provider.spokenText.isNotEmpty)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: Text(
                      '"${provider.spokenText}"',
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      textAlign: TextAlign.center,
                    ),
                  ),
              ],
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackFace(LearningProvider provider) {
    final word = provider.currentWord!;
    return BentoCard(
      key: const ValueKey(true),
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _buildTopicTag(context, word.topic),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                word.meaning,
                style: Theme.of(
                  context,
                ).textTheme.displayMedium?.copyWith(color: AppColors.success),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                word.example,
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              Row(
                children: [
                  Expanded(
                    child: SmartActionButton(
                      text: "Quên",
                      // Passing bento pink/error color
                      onPressed: () => _handleAnkiAction(false, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SmartActionButton(
                      text: "Nhớ",
                      onPressed: () => _handleAnkiAction(true, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SmartActionButton(
                      text: "Dễ",
                      onPressed: () => _handleAnkiAction(true, true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildRecordingOverlay(
    BuildContext context,
    LearningProvider provider,
  ) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.6),
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 40),
            child: BentoCard(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      SizedBox(
                        width: 120,
                        height: 120,
                        child: CircularProgressIndicator(
                          value: provider.timeRemaining / 5,
                          strokeWidth: 8,
                          valueColor: const AlwaysStoppedAnimation(
                            AppColors.bentoMint,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.mic_fill,
                        size: 60,
                        color: AppColors.bentoMint,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Đang nghe... 00:0${provider.timeRemaining}",
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: provider.stopRecording,
                    child: const Text(
                      "DỪNG",
                      style: TextStyle(
                        color: AppColors.error,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildTopicTag(BuildContext context, String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: AppColors.bentoBlue.withValues(alpha: 0.15),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        topic.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPronunciationItem(
    BuildContext context,
    String label,
    String ipa,
    Color color,
    VoidCallback onTap,
  ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: color,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(
              child: Text(
                ipa,
                style: Theme.of(
                  context,
                ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
              ),
            ),
            const SizedBox(height: 8),
            Icon(CupertinoIcons.speaker_2_fill, size: 18, color: color),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(BuildContext context, LearningProvider provider) {
    return GestureDetector(
      onTap: provider.isAnalyzing ? null : provider.startRecording,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.bentoBlue.withValues(alpha: 0.15),
          shape: BoxShape.circle,
        ),
        child: provider.isAnalyzing
            ? const SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(strokeWidth: 3),
              )
            : const Icon(
                CupertinoIcons.mic_fill,
                size: 32,
                color: AppColors.bentoBlue,
              ),
      ),
    );
  }

  Widget _buildFooterNav(BuildContext context, LearningProvider provider) {
    final activeColor = Theme.of(context).textTheme.displayLarge?.color;
    final disabledColor = Theme.of(context).dividerColor.withValues(alpha: 0.2);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            onPressed: provider.currentIndex > 0 ? provider.previousCard : null,
            icon: Icon(
              CupertinoIcons.arrow_left_circle_fill,
              size: 48,
              color: provider.currentIndex > 0 ? activeColor : disabledColor,
            ),
          ),
          IconButton(
            onPressed: provider.currentIndex < provider.words.length - 1
                ? provider.nextCard
                : null,
            icon: Icon(
              CupertinoIcons.arrow_right_circle_fill,
              size: 48,
              color: provider.currentIndex < provider.words.length - 1
                  ? activeColor
                  : disabledColor,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Text(
        "Tuyệt vời! Bạn đã hoàn thành bài học.",
        style: Theme.of(context).textTheme.displayMedium,
      ),
    );
  }
}
