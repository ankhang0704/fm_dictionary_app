import 'dart:ui';
import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- PROVIDERS & SERVICES ---
import '../../../../data/services/features/quiz_service.dart';

class QuizScreen extends StatefulWidget {
  const QuizScreen({super.key});

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  bool _isDialogActive = false;
  late QuizProvider _quizProvider;
  late ConfettiController _confettiController;

  // UI state to support the "Check/Next" Smart Action Button flow
  String? _tempSelectedOption;

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );

    // Listen to Provider changes for Quiz Completion
    _quizProvider = context.read<QuizProvider>();
    _quizProvider.addListener(_onQuizStateChanged);
  }

  @override
  void dispose() {
    _quizProvider.removeListener(_onQuizStateChanged);
    _confettiController.dispose();
    super.dispose();
  }

  void _onQuizStateChanged() {
    final provider = context.read<QuizProvider>();
    if (_quizProvider.isFinished && !_isDialogActive && mounted) {
      _isDialogActive = true;
      _showResultDialog(context, provider);
    }

    // Auto-reset local selection if provider moves to next question automatically
    if (provider.selectedAnswer == null && _tempSelectedOption != null) {
      if (mounted) setState(() => _tempSelectedOption = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

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
        appBar: _buildGlassHeader(context, provider),
        body: (provider.questions.isEmpty && !provider.isFinished)
            ? const Center(
                child: CircularProgressIndicator(color: Colors.white),
              )
            : SafeArea(
                child: Column(
                  children: [
                    Expanded(
                      child: SingleChildScrollView(
                        physics: const BouncingScrollPhysics(),
                        padding: EdgeInsets.all(AppLayout.defaultPadding),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            // HERO QUESTION CARD
                            _buildHeroQuestionCard(provider),
                            const SizedBox(height: 32),

                            // ANSWERS SECTION
                            _buildOptionsSection(provider),
                          ],
                        ),
                      ),
                    ),

                    // BOTTOM ACTION BUTTON
                    _buildBottomAction(provider),
                  ],
                ),
              ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildGlassHeader(
    BuildContext context,
    QuizProvider provider,
  ) {
    final progress = provider.questions.isEmpty
        ? 0.0
        : (provider.currentIndex + 1) / provider.questions.length;

    return PreferredSize(
      preferredSize: const Size.fromHeight(
        kToolbarHeight + 6,
      ), // Extra height for progress bar
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:0.1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.xmark,
                color: AppColors.textPrimary,
              ),
              onPressed: () {
                provider.clearQuiz();
                Navigator.pop(context);
              },
            ),
            title: Text(
              provider.questions.isEmpty
                  ? ""
                  : "Câu ${provider.currentIndex + 1}/${provider.questions.length}",
              style: AppTypography.heading3.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(6),
              child: TweenAnimationBuilder<double>(
                duration: const Duration(milliseconds: 300),
                tween: Tween<double>(begin: 0, end: progress),
                builder: (context, value, _) => LinearProgressIndicator(
                  value: value,
                  minHeight: 6,
                  backgroundColor: Colors.white.withValues(alpha:0.2),
                  valueColor: const AlwaysStoppedAnimation<Color>(
                    AppColors.success,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroQuestionCard(QuizProvider provider) {
    if (provider.currentQuestion == null) return const SizedBox.shrink();

    final question = provider.currentQuestion!;

    // LISTENING MODE: Show Audio Button
    if (provider.currentMode == QuizMode.listening) {
      return GestureDetector(
        onTap: provider.playCurrentAudioManually,
        child: GlassBentoCard(
          onTap: null,
          child: Container(
            height: 180,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.meshBlue.withValues(alpha:0.2),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.meshBlue.withValues(alpha:0.5),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.meshBlue.withValues(alpha:0.3),
                    blurRadius: 20,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.speaker_3_fill,
                size: 64,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      );
    }

    // NORMAL MODE: Show Text
    final displayText = provider.currentMode == QuizMode.viToEn
        ? question.wordObj.meaning
        : question.wordObj.word;

    return GlassBentoCard(
      onTap: null,
      child: Container(
        height: 180, // Fixed hero height for consistency
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            displayText,
            style: AppTypography.heading1.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
            maxLines: 4, // Zero Overflow protection
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsSection(QuizProvider provider) {
    if (provider.currentQuestion == null) return const SizedBox.shrink();
    final question = provider.currentQuestion!;
    final bool hasAnswered = provider.selectedAnswer != null;

    return Column(
      children: question.options.map((option) {
        // --- VISUAL FEEDBACK LOGIC ---
        final bool isSelected =
            _tempSelectedOption == option || provider.selectedAnswer == option;
        final bool isCorrect = option == question.correctAnswer;

        Color bgColor = Colors.white.withValues(alpha:0.1);
        Color borderColor = Colors.white.withValues(alpha:0.2);
        IconData? trailingIcon;
        Color? iconColor;

        if (hasAnswered) {
          if (isCorrect) {
            bgColor = AppColors.success.withValues(alpha:0.3);
            borderColor = AppColors.success;
            trailingIcon = CupertinoIcons.checkmark_circle_fill;
            iconColor = AppColors.success;
          } else if (isSelected) {
            // Wrong answer picked
            bgColor = AppColors.error.withValues(alpha:0.3);
            borderColor = AppColors.error;
            trailingIcon = CupertinoIcons.xmark_circle_fill;
            iconColor = AppColors.error;
          }
        } else if (isSelected) {
          // Highlight currently selected before checking
          bgColor = AppColors.meshBlue.withValues(alpha:0.3);
          borderColor = AppColors.meshBlue;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: GestureDetector(
            onTap: () {
              if (hasAnswered) return; // Prevent changing after checked
              setState(() => _tempSelectedOption = option);
            },
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(
                  AppLayout.bentoBorderRadius,
                ),
                border: Border.all(
                  color: borderColor,
                  width: isSelected || (hasAnswered && isCorrect) ? 2 : 1,
                ),
              ),
              child: GlassBentoCard(
                onTap:
                    null, // Outer GestureDetector handles tap for animation consistency
                child: Row(
                  children: [
                    Expanded(
                      child: Text(
                        option,
                        style: AppTypography.heading3.copyWith(
                          color: AppColors.textPrimary,
                        ),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    if (trailingIcon != null) ...[
                      const SizedBox(width: 12),
                      Icon(trailingIcon, color: iconColor, size: 28),
                    ],
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction(QuizProvider provider) {
    final bool hasAnswered = provider.selectedAnswer != null;
    final bool canCheck = _tempSelectedOption != null;

    return Padding(
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      child: SmartActionButton(
        text: hasAnswered ? "Tiếp tục" : "Kiểm tra",
        isGlass: !canCheck && !hasAnswered, // Dim/glassy if disabled
        isLoading: false,
        onPressed: () {
          if (hasAnswered) {
            // NOTE: If provider automatically advances via timer, this button
            // acts as a manual fast-forward or just a visual cue.
            // Calling checkAnswer again is a no-op in legacy, but we clear temp state.
            setState(() => _tempSelectedOption = null);
            // TODO: If you add `provider.nextQuestion()` in the future, call it here.
          } else if (canCheck) {
            provider.checkAnswer(_tempSelectedOption!);
          }
        },
      ),
    );
  }

  // ===========================================================================
  // RESULT DIALOG (LEGACY LOGIC RETAINED COMPLETELY)
  // ===========================================================================

  void _showResultDialog(BuildContext context, QuizProvider provider) {
    final isSuccess = provider.score >= provider.passThreshold;

    if (isSuccess) {
      _confettiController.play();
      // Gamification check (SRP)
      context.read<GamificationProvider>().checkAndUnlockBadges(
        score: provider.score,
        maxScore: provider.questions.length,
        isRoadmap: provider.isFromRoadmap,
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.transparent,
      builder: (dialogContext) => Stack(
        alignment: Alignment.center,
        children: [
          // Glassmorphism Dialog Background
          ClipRRect(
            borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
              child: Container(
                width: MediaQuery.of(context).size.width * 0.85,
                padding: const EdgeInsets.all(32.0),
                decoration: BoxDecoration(
                  color: AppColors.meshBlue.withValues(alpha:0.15),
                  borderRadius: BorderRadius.circular(
                    AppLayout.bentoBorderRadius,
                  ),
                  border: Border.all(
                    color: Colors.white.withValues(alpha:0.3),
                    width: 1.5,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Icon
                    Container(
                      padding: const EdgeInsets.all(24),
                      decoration: BoxDecoration(
                        color: isSuccess
                            ? AppColors.success.withValues(alpha:0.2)
                            : AppColors.error.withValues(alpha:0.2),
                        shape: BoxShape.circle,
                      ),
                      child: Icon(
                        isSuccess
                            ? CupertinoIcons.star_circle_fill
                            : CupertinoIcons.flag_circle_fill,
                        size: 80,
                        color: isSuccess ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Title
                    Text(
                      isSuccess ? "Hoàn thành xuất sắc!" : "Chưa đạt rồi!",
                      style: AppTypography.heading2.copyWith(
                        color: AppColors.textPrimary,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),

                    // Score
                    Text(
                      "Điểm: ${provider.score} / ${provider.questions.length}",
                      style: AppTypography.heading1.copyWith(
                        color: isSuccess ? AppColors.success : AppColors.error,
                      ),
                    ),
                    const SizedBox(height: 32),

                    // Action Button
                    SmartActionButton(
                      text: isSuccess ? "Quay về Lộ trình" : "Làm lại Quiz",
                      isGlass: false,
                      isLoading: false,
                      onPressed: () {
                        if (isSuccess) {
                          _handleSuccessExit(dialogContext, provider);
                        } else {
                          _handleRetry(dialogContext, provider);
                        }
                      },
                    ),

                    // Exit Option for failure
                    if (!isSuccess) ...[
                      const SizedBox(height: 16),
                      TextButton(
                        onPressed: () {
                          provider.clearQuiz();
                          Navigator.of(dialogContext).pop();
                          Navigator.of(context).pop();
                        },
                        child: Text(
                          "Thoát",
                          style: AppTypography.bodyLarge.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),

          // Confetti overlay
          if (isSuccess)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: drawStar,
              ),
            ),
        ],
      ),
    );
  }

  void _handleSuccessExit(BuildContext dialogContext, QuizProvider provider) {
    final gamification = context.read<GamificationProvider>();
    final roadmap = context.read<RoadmapProvider>();
    final currentContext = context;
    final home = context.read<HomeProvider>();

    gamification.checkAndUnlockBadges(
      score: provider.score,
      maxScore: provider.questions.length,
      isRoadmap: provider.isFromRoadmap,
    );

    // Database State refresh
    roadmap.refresh();
    _quizProvider.clearQuiz();
    home.updateDailyProgress();

    // Pop Dialog & Screen
    Navigator.of(dialogContext).pop();
    Navigator.of(context).pop();

    // Show Badge SnackBar sequentially
    Future.delayed(const Duration(milliseconds: 300), () {
      if (gamification.recentlyUnlocked.isNotEmpty && currentContext.mounted) {
        for (var badge in gamification.recentlyUnlocked) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(badge.icon, color: Colors.amber, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Huy hiệu mới: ${badge.title}",
                          style: AppTypography.bodyLarge.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          badge.description,
                          style: AppTypography.bodyMedium.copyWith(
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.meshBlue,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
              duration: const Duration(seconds: 4),
            ),
          );
        }
        gamification.clearRecentlyUnlocked();
      }
    });
  }

  void _handleRetry(BuildContext dialogContext, QuizProvider provider) {
    final words = provider.questions.map((q) => q.wordObj).toList();
    final mode = provider.currentMode;
    final isRoadmap = provider.isFromRoadmap;

    Navigator.of(dialogContext).pop();
    _isDialogActive = false;

    provider.clearQuiz();
    provider.initQuiz(words, mode, isFromRoadmap: isRoadmap);
  }

  Path drawStar(Size size) {
    double vw = size.width / 2;
    double vh = size.height / 2;
    Path path = Path();
    path.moveTo(vw, 0);
    path.lineTo(vw * 1.3, vh * 0.7);
    path.lineTo(size.width, vh * 0.7);
    path.lineTo(vw * 1.5, vh * 1.3);
    path.lineTo(vw * 1.7, size.height);
    path.lineTo(vw, vh * 1.6);
    path.lineTo(vw * 0.3, size.height);
    path.lineTo(vw * 0.5, vh * 1.3);
    path.lineTo(0, vh * 0.7);
    path.lineTo(vw * 0.7, vh * 0.7);
    path.close();
    return path;
  }
}
