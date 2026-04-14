import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../data/services/features/quiz_service.dart';

class QuizScreen extends StatelessWidget {
  const QuizScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

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
            context.read<QuizProvider>().clearQuiz();
            Navigator.pop(context);
          },
        ),
      ),
      body: Consumer<QuizProvider>(
        builder: (context, provider, child) {
          if (provider.questions.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }

          // NẾU LÀM XONG -> HIỆN POPUP KẾT QUẢ
          if (provider.isFinished) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              _showResultDialog(context, provider);
            });
            return const SizedBox.shrink(); // Ẩn giao diện đi trong lúc show Dialog
          }

          final question = provider.currentQuestion!;

          return SafeArea(
            child: Column(
              children: [
                _buildProgressBar(provider),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 32,
                    ),
                    child: Column(
                      children: [
                        _buildQuestionSection(question, provider, isDark),
                        const SizedBox(height: 48),
                        _buildOptionsSection(question, provider, isDark),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          );
        },
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
    final isSuccess = provider.score >= provider.questions.length * 0.8;

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => Dialog(
        backgroundColor: isDark
            ? AppConstants.darkCardColor
            : AppConstants.cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(28)),
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
                color: isSuccess ? Colors.amber : AppConstants.accentColor,
              ),
              const SizedBox(height: 24),
              const Text(
                "Hoàn thành!",
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                "Điểm: ${provider.score} / ${provider.questions.length}",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isSuccess
                      ? AppConstants.successColor
                      : AppConstants.accentColor,
                ),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  onPressed: () {
                    provider.clearQuiz();
                    Navigator.pop(context); // Đóng Dialog
                    Navigator.pop(context); // Đóng QuizScreen
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                  ),
                  child: const Text(
                    "Quay về",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
