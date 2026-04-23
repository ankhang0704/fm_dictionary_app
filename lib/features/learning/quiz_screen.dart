import 'package:confetti/confetti.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE / THEMES ---
import '../../../../core/theme/app_colors.dart';
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

  // --- STRICTLY PRESERVED LOGIC ---
  void _onQuizStateChanged() {
    final provider = context.read<QuizProvider>();
    if (_quizProvider.isFinished && !_isDialogActive && mounted) {
      _isDialogActive = true;
      _showResultDialog(context, provider);
    }

    if (provider.selectedAnswer == null && _tempSelectedOption != null) {
      if (mounted) setState(() => _tempSelectedOption = null);
    }
  }

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<QuizProvider>();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context, provider),
      body: (provider.questions.isEmpty && !provider.isFinished)
          ? Center(
              child: CircularProgressIndicator(
                color: Theme.of(context).primaryColor,
              ),
            )
          : SafeArea(
              child: Column(
                children: [
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      padding: const EdgeInsets.all(AppLayout.defaultPadding),
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
                  // _buildFeedbackOverlay(provider),
                ],
              ),
            ),
    );
  }

  // ===========================================================================
  // RESULT DIALOG (STRICTLY PRESERVED LOGIC)
  // ===========================================================================
  // --- BẮN TỈA: LOGIC HIỆU ỨNG PHẢN HỒI TINH TẾ ---
//  Widget _buildFeedbackOverlay(QuizProvider provider) {
//     // 🚨 [LOGIC PRESERVED 100%]
//     if (provider.selectedAnswer == null || provider.currentQuestion == null) {
//       return const SizedBox.shrink();
//     }

//     final isCorrect =
//         provider.selectedAnswer == provider.currentQuestion!.correctAnswer;

//     // Bento UI Palette & Icons
//     final Color color = isCorrect
//         ? const Color(0xFF10B981)
//         : const Color(0xFFFF4757); // Emerald vs Red
//     final IconData icon = isCorrect
//         ? Icons.check_circle_rounded
//         : Icons.error_rounded;

//     // [LOCALIZATION ENFORCED] - Đổi text hardcode sang .tr()
//     final String text = isCorrect
//         ? "quiz.feedback.correct".tr()
//         : "quiz.feedback.wrong".tr();

//     return Positioned(
//       top:
//           MediaQuery.of(context).padding.top +
//           20, // Đẩy lên trên cùng (dưới thanh trạng thái)
//       left: 24,
//       right: 24,
//       child: TweenAnimationBuilder<double>(
//         duration: const Duration(milliseconds: 400),
//         tween: Tween(begin: 0.0, end: 1.0),
//         builder: (context, value, child) {
//           return Opacity(
//             opacity: value,
//             child: Transform.translate(
//               offset: Offset(0, -20 * (1 - value)), // Bay nhẹ từ trên xuống
//               child: Center(
//                 child: ConstrainedBox(
//                   // [ANTI-OVERFLOW]
//                   constraints: const BoxConstraints(maxWidth: 400),
//                   child: Container(
//                     padding: const EdgeInsets.symmetric(
//                       horizontal: 20,
//                       vertical: 14,
//                     ),
//                     decoration: BoxDecoration(
//                       color: color,
//                       borderRadius: BorderRadius.circular(
//                         24,
//                       ), // Bo góc dạng Bento viên thuốc
//                       boxShadow: [
//                         BoxShadow(
//                           color: color.withOpacity(0.3),
//                           blurRadius: 15,
//                           offset: const Offset(0, 8),
//                         ),
//                       ],
//                     ),
//                     child: Row(
//                       mainAxisSize: MainAxisSize.min, // Thu gọn theo text
//                       children: [
//                         // Icon bọc trong vòng tròn trắng để nổi bật trên nền màu
//                         Container(
//                           padding: const EdgeInsets.all(4),
//                           decoration: const BoxDecoration(
//                             color: Colors.white24,
//                             shape: BoxShape.circle,
//                           ),
//                           child: Icon(icon, color: Colors.white, size: 24),
//                         ),
//                         const SizedBox(width: 12),
//                         Flexible(
//                           // [ANTI-OVERFLOW] Cho phép text xuống dòng nếu quá dài
//                           child: Text(
//                             text,
//                             style: const TextStyle(
//                               color: Colors.white,
//                               fontWeight: FontWeight.bold,
//                               fontSize: 16,
//                               fontFamily: 'Quicksand',
//                             ),
//                           ),
//                         ),
//                       ],
//                     ),
//                   ),
//                 ),
//               ),
//             ),
//           );
//         },
//       ),
//     );
//   }
  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildBentoHeader(
    BuildContext context,
    QuizProvider provider,
  ) {
    final progress = provider.questions.isEmpty
        ? 0.0
        : (provider.currentIndex + 1) / provider.questions.length;

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
              CupertinoIcons.xmark,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
            onPressed: () {
              provider.clearQuiz();
              Navigator.pop(context);
            },
          ),
        ),
      ),
      title: Text(
        provider.questions.isEmpty
            ? ""
            : "quiz.screen.question_progress".tr(
                args: [
                  (provider.currentIndex + 1).toString(),
                  provider.questions.length.toString(),
                ],
              ), // INJECTED WITH ARGS
        style: Theme.of(context).textTheme.displaySmall,
      ),
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(6),
        child: TweenAnimationBuilder<double>(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: progress),
          builder: (context, value, _) => LinearProgressIndicator(
            value: value,
            minHeight: 6,
            backgroundColor: Theme.of(
              context,
            ).dividerColor.withValues(alpha: 0.1),
            valueColor: const AlwaysStoppedAnimation<Color>(AppColors.success),
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
        child: BentoCard(
          child: Container(
            height: 180,
            alignment: Alignment.center,
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.bentoBlue.withValues(alpha: 0.15),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.speaker_3_fill,
                size: 64,
                color: AppColors.bentoBlue,
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

    return BentoCard(
      child: Container(
        height: 180,
        padding: const EdgeInsets.all(16),
        alignment: Alignment.center,
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            displayText,
            style: Theme.of(context).textTheme.displayLarge?.copyWith(
              fontSize: 48,
              fontWeight: FontWeight.w900,
            ),
            textAlign: TextAlign.center,
            maxLines: 4,
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
        final bool isSelected =
            _tempSelectedOption == option || provider.selectedAnswer == option;
        final bool isCorrect = option == question.correctAnswer;

        Color? bentoColor;
        Color? borderColor;
        IconData? trailingIcon;
        Color? iconColor;

        if (hasAnswered) {
          if (isCorrect) {
            bentoColor = AppColors.success.withValues(alpha: 0.15);
            borderColor = AppColors.success;
            trailingIcon = CupertinoIcons.checkmark_circle_fill;
            iconColor = AppColors.success;
          } else if (isSelected) {
            bentoColor = AppColors.error.withValues(alpha: 0.15);
            borderColor = AppColors.error;
            trailingIcon = CupertinoIcons.xmark_circle_fill;
            iconColor = AppColors.error;
          }
        } else if (isSelected) {
          bentoColor = Theme.of(context).primaryColor.withValues(alpha: 0.15);
          borderColor = Theme.of(context).primaryColor;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
              border: Border.all(
                color:
                    borderColor ??
                    Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            child: BentoCard(
              onTap: hasAnswered
                  ? null
                  : () => setState(() => _tempSelectedOption = option),
              bentoColor: bentoColor,
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: Theme.of(
                        context,
                      ).textTheme.displaySmall?.copyWith(fontSize: 18),
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
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction(QuizProvider provider) {
    final bool hasAnswered = provider.selectedAnswer != null;
    final bool canCheck = _tempSelectedOption != null;

    // Lựa chọn màu sắc và Icon theo trạng thái Quiz (Bento State UI)
    final Color bentoColor = hasAnswered
        ? const Color(0xFF10B981) // Vibrant Emerald (Thành công/Tiếp tục)
        : (canCheck
              ? const Color(0xFF3B82F6)
              : const Color(
                  0xFF94A3B8,
                )); // Blue (Sẵn sàng) hoặc Slate (Chưa chọn)

    final IconData bentoIcon = hasAnswered
        ? Icons.arrow_forward_rounded
        : Icons.fact_check_rounded;

    return SafeArea(
      // [ANTI-OVERFLOW] Bảo vệ nút khỏi dính sát home indicator của các máy màn hình dài
      top: false,
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        child: ConstrainedBox(
          // [ANTI-OVERFLOW] Giới hạn chiều ngang tối đa trên Tablet để tránh nút quá dài
          constraints: const BoxConstraints(maxWidth: 500),
          child: SmartActionButton(
            // [LOCALIZATION PRESERVED]
            text: hasAnswered
                ? "quiz.screen.continue_btn".tr()
                : "quiz.screen.check_btn".tr(),
            icon: bentoIcon,
            color: bentoColor,
            textColor: Colors.white,
            onPressed: () {
              // 🚨 [LOGIC PRESERVED 100%] - Không thay đổi bất kỳ flow xử lý nào
              if (hasAnswered) {
                setState(() => _tempSelectedOption = null);
              } else if (canCheck) {
                provider.checkAnswer(_tempSelectedOption!);
              }
            },
          ),
        ),
      ),
    );
  }

  void _showResultDialog(BuildContext context, QuizProvider provider) {
    final isSuccess = provider.score >= provider.passThreshold;

    if (isSuccess) {
      _confettiController.play();
      context.read<GamificationProvider>().checkAndUnlockBadges(
        score: provider.score,
        maxScore: provider.questions.length,
        isRoadmap: provider.isFromRoadmap,
      );
    }

    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.5),
      builder: (dialogContext) => Stack(
        alignment: Alignment.center,
        children: [
          Material(
            color: Colors.transparent,
            child: Center(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24),
                child: BentoCard(
                  padding: const EdgeInsets.all(32.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(24),
                        decoration: BoxDecoration(
                          color: isSuccess
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.error.withValues(alpha: 0.15),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          isSuccess
                              ? CupertinoIcons.star_circle_fill
                              : CupertinoIcons.flag_circle_fill,
                          size: 80,
                          color: isSuccess
                              ? AppColors.success
                              : AppColors.error,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Text(
                        isSuccess
                            ? "quiz.results.success_title".tr()
                            : "quiz.results.fail_title".tr(), // INJECTED
                        style: Theme.of(context).textTheme.displayMedium,
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "quiz.results.score_display".tr(
                          args: [
                            provider.score.toString(),
                            provider.questions.length.toString(),
                          ],
                        ), // INJECTED WITH ARGS
                        style: Theme.of(context).textTheme.displayLarge
                            ?.copyWith(
                              color: isSuccess
                                  ? AppColors.success
                                  : AppColors.error,
                            ),
                      ),
                      const SizedBox(height: 32),
                      SmartActionButton(
                        text: isSuccess
                            ? "quiz.results.exit_roadmap".tr()
                            : "quiz.results.retry_btn".tr(), // INJECTED
                        onPressed: () {
                          if (isSuccess) {
                            _handleSuccessExit(dialogContext, provider);
                          } else {
                            _handleRetry(dialogContext, provider);
                          }
                        },
                      ),
                      if (!isSuccess) ...[
                        const SizedBox(height: 16),
                        TextButton(
                          onPressed: () {
                            provider.clearQuiz();
                            Navigator.of(dialogContext).pop();
                            Navigator.of(context).pop();
                          },
                          child: Text(
                            "common.exit".tr(), // INJECTED
                            style: Theme.of(context).textTheme.bodyLarge,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
          if (isSuccess)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality: BlastDirectionality.explosive,
                shouldLoop: false,
                colors: const [
                  AppColors.bentoBlue,
                  AppColors.bentoPurple,
                  AppColors.bentoMint,
                  AppColors.bentoPink,
                  AppColors.bentoYellow,
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

    roadmap.refresh();
    _quizProvider.clearQuiz();
    home.updateDailyProgress();

    Navigator.of(dialogContext).pop();
    Navigator.of(context).pop();

    Future.delayed(const Duration(milliseconds: 300), () {
      if (gamification.recentlyUnlocked.isNotEmpty && currentContext.mounted) {
        for (var badge in gamification.recentlyUnlocked) {
          ScaffoldMessenger.of(currentContext).showSnackBar(
            SnackBar(
              content: Row(
                children: [
                  Icon(badge.icon, color: AppColors.bentoYellow, size: 30),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "gamification.new_badge".tr(
                            args: [badge.title],
                          ), // INJECTED
                          style: Theme.of(currentContext).textTheme.bodyLarge
                              ?.copyWith(
                                fontWeight: FontWeight.bold,
                                color: Colors.white,
                              ),
                        ),
                        Text(
                          badge.description,
                          style: Theme.of(currentContext).textTheme.bodySmall
                              ?.copyWith(color: Colors.white70),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              backgroundColor: AppColors.bentoPurple,
              behavior: SnackBarBehavior.floating,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16),
              ),
              margin: const EdgeInsets.all(16),
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
