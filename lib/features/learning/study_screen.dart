import 'dart:math';
import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/gamification/presentation/widgets/steak_celebration.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:provider/provider.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
    // Legacy Logic: Load words into provider
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadWordsFromLesson(widget.words);
    });
  }

  // --- LEGACY BUSINESS LOGIC MAPPING ---
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
      // Không cần Navigator.push, chỉ gọi thẳng hàm này thôi
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
    return Container(
      // MESH GRADIENT BACKGROUND
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
        body: Consumer<LearningProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(
                child: CircularProgressIndicator(color: Colors.white),
              );
            }
            if (provider.words.isEmpty) return _buildEmptyState();
            return Stack(
              children: [
                SafeArea(
                  child: Column(
                    children: [
                      // GLASS HEADER
                      _buildGlassHeader(provider),

                      // MAIN FLASHCARD AREA
                      Expanded(
                        child: Padding(
                          padding: const EdgeInsets.all(
                            AppLayout.defaultPadding,
                          ),
                          child: _buildFlipCard(provider),
                        ),
                      ),

                      // FOOTER NAVIGATION
                      _buildFooterNav(provider),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),

                // RECORDING OVERLAY (5s COUNTDOWN)
                if (provider.isRecording) _buildRecordingOverlay(provider),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildGlassHeader(LearningProvider provider) {
    return ClipRRect(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
          color: Colors.white.withValues(alpha: 0.1),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(
                  CupertinoIcons.xmark,
                  color: AppColors.textPrimary,
                ),
                onPressed: () => Navigator.pop(context),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Text(
                  '${provider.currentIndex + 1} / ${provider.words.length}',
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              IconButton(
                icon: Icon(
                  provider.isCurrentWordSaved
                      ? CupertinoIcons.bookmark_solid
                      : CupertinoIcons.bookmark,
                  color: provider.isCurrentWordSaved
                      ? AppColors.error
                      : AppColors.textPrimary,
                ),
                onPressed: provider.toggleSave,
              ),
            ],
          ),
        ),
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

  // --- FRONT FACE: ENGLISH ---
  Widget _buildFrontFace(LearningProvider provider) {
    final word = provider.currentWord!;
    return GlassBentoCard(
      key: const ValueKey(false),
      onTap: null, // Tap handled by outer switcher
      child: Stack(
        children: [
          // TOP RIGHT: TOPIC TAG
          Align(
            alignment: Alignment.topRight,
            child: _buildTopicTag(word.topic),
          ),

          Column(
            children: [
              const SizedBox(height: 32),
              // WORD CENTERED (ZERO OVERFLOW)
              FittedBox(
                fit: BoxFit.scaleDown,
                child: Text(
                  word.word,
                  style: AppTypography.heading1.copyWith(fontSize: 48),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                ),
              ),
              const SizedBox(height: 32),

              // PRONUNCIATION ROW (50-50 SPLIT)
              Row(
                children: [
                  Expanded(
                    child: _buildPronunciationItem(
                      'US',
                      word.phoneticUS,
                      () => provider.playAudio('en-US'),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: _buildPronunciationItem(
                      'UK',
                      word.phoneticUK,
                      () => provider.playAudio('en-GB'),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 32),

              // MICROPHONE BUTTON
              _buildMicButton(provider),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // --- BACK FACE: MEANING & ANKI ---
  Widget _buildBackFace(LearningProvider provider) {
    final word = provider.currentWord!;
    return GlassBentoCard(
      key: const ValueKey(true),
      onTap: null,
      child: Stack(
        children: [
          Align(
            alignment: Alignment.topRight,
            child: _buildTopicTag(word.topic),
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 32),
              Text(
                word.meaning,
                style: AppTypography.heading2.copyWith(
                  color: AppColors.success,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 16),
              Text(
                word.example,
                style: AppTypography.bodyLarge.copyWith(
                  fontStyle: FontStyle.italic,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),

              // ANKI ACTION ROW
              Row(
                children: [
                  Expanded(
                    child: SmartActionButton(
                      text: "Quên",
                      color: AppColors.error,
                      onPressed: () => _handleAnkiAction(false, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SmartActionButton(
                      text: "Nhớ",
                      color: AppColors.meshBlue,
                      onPressed: () => _handleAnkiAction(true, false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: SmartActionButton(
                      text: "Dễ",
                      color: AppColors.success,
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

  // --- RECORDING OVERLAY ---
  Widget _buildRecordingOverlay(LearningProvider provider) {
    return Positioned.fill(
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          color: Colors.black.withValues(alpha: 0.5),
          child: Center(
            child: GlassBentoCard(
              onTap: null,
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
                            AppColors.meshMint,
                          ),
                        ),
                      ),
                      const Icon(
                        CupertinoIcons.mic_fill,
                        size: 60,
                        color: Colors.white,
                      ),
                    ],
                  ),
                  const SizedBox(height: 24),
                  Text(
                    "Đang nghe... 00:0${provider.timeRemaining}",
                    style: AppTypography.heading2,
                  ),
                  const SizedBox(height: 16),
                  TextButton(
                    onPressed: provider.stopRecording,
                    child: const Text(
                      "DỪNG",
                      style: TextStyle(
                        color: Colors.red,
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

  // ===========================================================================
  // SUB-WIDGETS
  // ===========================================================================

  Widget _buildTopicTag(String topic) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.2),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Text(
        topic.toUpperCase(),
        style: AppTypography.bodyMedium.copyWith(
          fontSize: 10,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _buildPronunciationItem(String label, String ipa, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white10),
        ),
        child: Column(
          children: [
            Text(
              label,
              style: AppTypography.bodyMedium.copyWith(
                fontWeight: FontWeight.bold,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 4),
            FittedBox(child: Text(ipa, style: AppTypography.ipaText)),
            const SizedBox(height: 8),
            const Icon(
              CupertinoIcons.speaker_2_fill,
              size: 18,
              color: AppColors.textPrimary,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMicButton(LearningProvider provider) {
    return GestureDetector(
      onTap: provider.isAnalyzing ? null : provider.startRecording,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: AppColors.meshBlue.withValues(alpha: 0.2),
          shape: BoxShape.circle,
          border: Border.all(color: AppColors.meshBlue, width: 2),
          boxShadow: [
            BoxShadow(
              color: AppColors.meshBlue.withValues(alpha: 0.3),
              blurRadius: 15,
            ),
          ],
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
                color: Colors.white,
              ),
      ),
    );
  }

  Widget _buildFooterNav(LearningProvider provider) {
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
              color: provider.currentIndex > 0 ? Colors.white : Colors.white24,
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
                  ? Colors.white
                  : Colors.white24,
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
        style: AppTypography.heading2,
      ),
    );
  }
}
