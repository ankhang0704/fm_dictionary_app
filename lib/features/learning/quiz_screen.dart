import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
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

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 3),
    );
    // Lắng nghe sự thay đổi từ Provider
    _quizProvider = context.read<QuizProvider>();
    _quizProvider.addListener(_onQuizStateChanged);
  }

  @override
  void dispose() {
    // Quan trọng: Phải tháo listener khi thoát màn hình
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
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<QuizProvider>();

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Consumer<QuizProvider>(
          builder: (context, provider, child) {
            if (provider.questions.isEmpty) return const SizedBox.shrink();
            return Text(
              "Câu ${provider.currentIndex + 1}/${provider.questions.length}",
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            );
          },
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.xmark,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          onPressed: () {
            provider.clearQuiz();
            Navigator.pop(context);
          },
        ),
      ),
      body: (provider.questions.isEmpty && !provider.isFinished)
          ? const Center(child: CircularProgressIndicator())
          : SafeArea(
              child: Column(
                children: [
                  _buildProgressBar(provider),
                  Expanded(
                    child: SingleChildScrollView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 20,
                        vertical: 32,
                      ),
                      child: Column(
                        children: [
                          _buildQuestionSection(
                            provider.currentQuestion!,
                            provider,
                            isDark,
                          ),
                          const SizedBox(height: 48),
                          _buildOptionsSection(
                            provider.currentQuestion!,
                            provider,
                            isDark,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildProgressBar(QuizProvider provider) {
    final progress = (provider.currentIndex + 1) / provider.questions.length;
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: TweenAnimationBuilder<double>(
        duration: const Duration(milliseconds: 300),
        tween: Tween<double>(begin: 0, end: progress),
        builder: (context, value, _) => ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: value,
            backgroundColor: Colors.grey.withValues(alpha: 0.15),
            valueColor: const AlwaysStoppedAnimation<Color>(
              AppConstants.accentColor,
            ),
            minHeight: 8,
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionSection(
    QuizQuestion question,
    QuizProvider provider,
    bool isDark,
  ) {
    if (provider.currentMode == QuizMode.listening) {
      return GestureDetector(
        onTap: provider.playCurrentAudioManually,
        child: Container(
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppConstants.accentColor.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.accentColor.withValues(alpha: 0.3),
              width: 2,
            ),
          ),
          child: const Icon(
            CupertinoIcons.speaker_3_fill,
            size: 64,
            color: AppConstants.accentColor,
          ),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
      width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Text(
        provider.currentMode == QuizMode.viToEn
            ? question.wordObj.meaning
            : question.wordObj.word,
        style: TextStyle(
          fontSize: provider.currentMode == QuizMode.viToEn ? 24 : 32,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  Widget _buildOptionsSection(
    QuizQuestion question,
    QuizProvider provider,
    bool isDark,
  ) {
    return Column(
      children: question.options.map((option) {
        // Xử lý màu sắc Bento
        Color bgColor = isDark
            ? AppConstants.darkCardColor
            : AppConstants.cardColor;
        Color borderColor = Colors.grey.withValues(alpha: 0.1);
        Color textColor = isDark ? Colors.white : AppConstants.textPrimary;
        Widget? trailingIcon;

        if (provider.selectedAnswer != null) {
          if (option == question.correctAnswer) {
            bgColor = AppConstants.successColor.withValues(alpha: 0.1);
            borderColor = AppConstants.successColor;
            textColor = AppConstants.successColor;
            trailingIcon = const Icon(
              CupertinoIcons.checkmark_circle_fill,
              color: AppConstants.successColor,
            );
          } else if (option == provider.selectedAnswer) {
            bgColor = AppConstants.errorColor.withValues(alpha: 0.1);
            borderColor = AppConstants.errorColor;
            textColor = AppConstants.errorColor;
            trailingIcon = const Icon(
              CupertinoIcons.xmark_circle_fill,
              color: AppConstants.errorColor,
            );
          }
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 16),
          child: InkWell(
            onTap: () => provider.checkAnswer(option),
            borderRadius: BorderRadius.circular(16),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: double.infinity,
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: bgColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: borderColor,
                  width:
                      provider.selectedAnswer != null &&
                          (option == question.correctAnswer ||
                              option == provider.selectedAnswer)
                      ? 2
                      : 1,
                ),
              ),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (trailingIcon != null) trailingIcon,
                ],
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  void _showResultDialog(BuildContext context, QuizProvider provider) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSuccess = provider.score >= (provider.questions.length * 0.8);
    if (isSuccess) {
      _confettiController.play();
      // GỌI LOGIC GAMIFICATION (Đảm bảo SRP)
      // Tạm comment lại nếu bạn chưa import GamificationProvider vào main.dart
      context.read<GamificationProvider>().checkAndUnlockBadges(
        score: provider.score,
        maxScore: provider.questions.length,
        isRoadmap: provider.isFromRoadmap,
      );
    }
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Stack(
        // SỬ DỤNG STACK ĐỂ HIỆN CONFETTI ĐÈ LÊN DIALOG
        alignment: Alignment.center,
        children: [
          Dialog(
            backgroundColor: isDark
                ? AppConstants.darkCardColor
                : AppConstants.cardColor,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(28),
            ),
            child: Padding(
              padding: const EdgeInsets.all(32.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    isSuccess
                        ? CupertinoIcons.star_circle_fill
                        : CupertinoIcons.flag_circle_fill,
                    size: 80,
                    color: isSuccess ? Colors.amber : AppConstants.errorColor,
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isSuccess ? "Hoàn thành xuất sắc!" : "Chưa đạt rồi!",
                    style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    "Điểm: ${provider.score} / ${provider.questions.length}",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: isSuccess
                          ? AppConstants.successColor
                          : AppConstants.errorColor,
                    ),
                  ),
                  const SizedBox(height: 32),
                  SizedBox(
                    width: double.infinity,
                    height: 50,
                    child: ElevatedButton(
                      onPressed: () {
                        if (isSuccess) {
                          // Gọi Check Badge trước khi thoát
                          final gamification = context
                              .read<GamificationProvider>();
                          final roadmap = context.read<RoadmapProvider>();
                          final currentContext = context; // Scaffold context
                          gamification.checkAndUnlockBadges(
                            score: provider.score,
                            maxScore: provider.questions.length,
                            isRoadmap: provider.isFromRoadmap,
                          );
                          // Xử lý Database State
                          // 1. Lưu state
                          roadmap.refresh();
                          _quizProvider.clearQuiz();
                          // 2. Đóng dialog trước
                          Navigator.of(dialogContext).pop();
                          // 3. Thoát màn Quiz sau
                          Navigator.of(context).pop();
                           Future.delayed(const Duration(milliseconds: 300), () {
                            if (gamification.recentlyUnlocked.isNotEmpty &&
                                currentContext.mounted) {
                              for (var badge in gamification.recentlyUnlocked) {
                                ScaffoldMessenger.of(
                                  currentContext,
                                ).showSnackBar(
                                  SnackBar(
                                    content: Row(
                                      children: [
                                        Icon(
                                          badge.icon,
                                          color: Colors.amber,
                                          size: 30,
                                        ),
                                        const SizedBox(width: 12),
                                        Expanded(
                                          child: Column(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              Text(
                                                "Huy hiệu mới: ${badge.title}",
                                                style: const TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 16,
                                                  color: Colors.white,
                                                ),
                                              ),
                                              Text(
                                                badge.description,
                                                style: const TextStyle(
                                                  fontSize: 12,
                                                  color: Colors.white70,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                    backgroundColor: AppConstants.accentColor,
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
                        } else {
                          final words = provider.questions
                              .map((q) => q.wordObj)
                              .toList();
                          final mode = provider.currentMode;
                          final isRoadmap = provider.isFromRoadmap;

                          Navigator.of(dialogContext).pop();
                          _isDialogActive = false;

                          provider.clearQuiz();
                          provider.initQuiz(
                            words,
                            mode,
                            isFromRoadmap: isRoadmap,
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: isSuccess
                            ? AppConstants.accentColor
                            : AppConstants.errorColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      child: Text(
                        isSuccess ? "Quay về Lộ trình" : "Làm lại Quiz",
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  if (!isSuccess) ...[
                    const SizedBox(height: 12),
                    TextButton(
                      onPressed: () {
                        provider.clearQuiz();
                        Navigator.of(dialogContext).pop();
                        Navigator.of(context).pop();
                      },
                      child: const Text(
                        "Thoát",
                        style: TextStyle(color: Colors.grey),
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ), // WIDGET BẮN PHÁO HOA
          if (isSuccess)
            Align(
              alignment: Alignment.topCenter,
              child: ConfettiWidget(
                confettiController: _confettiController,
                blastDirectionality:
                    BlastDirectionality.explosive, // Bắn tung tóe 360 độ
                shouldLoop: false,
                colors: const [
                  Colors.green,
                  Colors.blue,
                  Colors.pink,
                  Colors.orange,
                  Colors.purple,
                ],
                createParticlePath: drawStar, // Hàm vẽ hình ngôi sao
              ),
            ),
        ],
      ),
    );
  }

  // Hàm vẽ hình pháo hoa thành hình ngôi sao (Tùy chọn cho đẹp)
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
