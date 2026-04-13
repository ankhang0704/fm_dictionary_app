// file: lib/screens/learning/quiz_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../data/models/word_model.dart';
import '../../core/constants/constants.dart';
import '../../data/services/ai_speech/text_to_speech/speech_service.dart';
import 'quiz_configuration_screen.dart';

class QuizScreen extends StatefulWidget {
  final List<Word> targetWords;
  final List<Word> distractorPool;
  final int questionCount;
  final QuizMode mode;

  const QuizScreen({
    super.key,
    required this.targetWords,
    required this.distractorPool,
    this.questionCount = 10,
    required this.mode,
  });

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  late List<Map<String, dynamic>> quizData;
  int currentIndex = 0;
  String? selectedAnswer;
  int score = 0;
  final TtsService _ttsService = TtsService();

  @override
  void initState() {
    super.initState();
    _generateDynamicQuiz();
    _playAudioIfListeningMode();
  }

  void _generateDynamicQuiz() {
    quizData = [];
    final pool = List<Word>.from(widget.distractorPool);

    for (var word in widget.targetWords) {
      pool.shuffle();
      final distractors = pool.where((w) => w.id != word.id).take(3).toList();

      String correctAnswer;
      List<String> options = [];

      if (widget.mode == QuizMode.viToEn) {
        correctAnswer = word.word;
        options = [correctAnswer, ...distractors.map((w) => w.word)];
      } else {
        correctAnswer = word.meaning;
        options = [correctAnswer, ...distractors.map((w) => w.meaning)];
      }
      options.shuffle();

      quizData.add({
        'wordObj': word,
        'correctAnswer': correctAnswer,
        'options': options,
      });
    }
  }

  void _playAudioIfListeningMode() {
    if (widget.mode == QuizMode.listening && quizData.isNotEmpty) {
      final Word currentWord = quizData[currentIndex]['wordObj'];
      _ttsService.speak(currentWord.word, accent: 'en-US');
    }
  }

  void _checkAnswer(String option) {
    if (selectedAnswer != null) return;

    bool correct = option == quizData[currentIndex]['correctAnswer'];
    setState(() {
      selectedAnswer = option;
      if (correct) score++;
    });

    Future.delayed(const Duration(milliseconds: 1200), () {
      if (!mounted) return;
      if (currentIndex < quizData.length - 1) {
        setState(() {
          currentIndex++;
          selectedAnswer = null;
        });
        _playAudioIfListeningMode();
      } else {
        _showResult();
      }
    });
  }

  void _showResult() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => _ResultDialog(
        score: score,
        total: quizData.length,
        onClose: () {
          Navigator.pop(context);
          Navigator.pop(context);
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (quizData.isEmpty) {
      return Scaffold(
        backgroundColor: isDark
            ? AppConstants.darkBgColor
            : AppConstants.backgroundColor,
        appBar: AppBar(
          title: Text(
            'quiz.title'.tr(),
            style: AppConstants.headingStyle.copyWith(fontSize: 20),
          ),
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        body: Center(
          child: Text('quiz.noData'.tr(), style: AppConstants.subHeadingStyle),
        ),
      );
    }

    final currentQuestion = quizData[currentIndex];
    final currentWord = currentQuestion['wordObj'] as Word;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          "${'quiz.question'.tr()} ${currentIndex + 1}/${quizData.length}",
          style: AppConstants.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 18,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.xmark,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            _buildProgressBar(),
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.symmetric(
                  horizontal: AppConstants.defaultPadding,
                  vertical: 32,
                ),
                child: Column(
                  children: [
                    _buildQuestionSection(currentWord, isDark),
                    const SizedBox(height: 48),
                    _buildOptionsSection(currentQuestion),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    final progress = (currentIndex + 1) / quizData.length;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: TweenAnimationBuilder<double>(
        duration: AppConstants.defaultAnimationDuration,
        curve: Curves.easeInOut,
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

  Widget _buildQuestionSection(Word currentWord, bool isDark) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(
          widget.mode == QuizMode.listening
              ? 'quiz.listen_instruction'.tr()
              : 'quiz.translation_instruction'.tr(),
          style: AppConstants.bodyStyle.copyWith(
            color: AppConstants.textSecondary,
            fontSize: 14,
          ),
        ),
        const SizedBox(height: 32),
        if (widget.mode == QuizMode.listening)
          GestureDetector(
            onTap: () => _ttsService.speak(currentWord.word, accent: 'en-US'),
            child: Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppConstants.accentColor.withValues(alpha: 0.3),
                  width: 2,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AppConstants.accentColor.withValues(alpha: 0.2),
                    blurRadius: 20,
                    spreadRadius: 5,
                  ),
                ],
              ),
              child: const Icon(
                CupertinoIcons.speaker_3_fill,
                size: 64,
                color: AppConstants.accentColor,
              ),
            ),
          )
        else
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
            width: double.infinity,
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.darkCardColor
                  : AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.05),
                        blurRadius: 15,
                        offset: const Offset(0, 5),
                      ),
                    ],
            ),
            child: Text(
              widget.mode == QuizMode.viToEn
                  ? currentWord.meaning
                  : currentWord.word,
              style: AppConstants.headingStyle.copyWith(
                fontSize: widget.mode == QuizMode.viToEn ? 24 : 32,
                fontStyle: FontStyle.normal,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
          ),
      ],
    );
  }

  Widget _buildOptionsSection(Map<String, dynamic> currentQuestion) {
    final List<String> options = List<String>.from(currentQuestion['options']);
    return Column(
      children: options.map((option) {
        return _QuizOptionCard(
          option: option,
          correctAnswer: currentQuestion['correctAnswer'],
          selectedAnswer: selectedAnswer,
          onTap: () => _checkAnswer(option),
        );
      }).toList(),
    );
  }
}

class _QuizOptionCard extends StatelessWidget {
  final String option;
  final String correctAnswer;
  final String? selectedAnswer;
  final VoidCallback onTap;

  const _QuizOptionCard({
    required this.option,
    required this.correctAnswer,
    this.selectedAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    Color bgColor = isDark
        ? AppConstants.darkCardColor
        : AppConstants.cardColor;
    Color textColor = isDark ? Colors.white : AppConstants.textPrimary;
    Color borderColor = Colors.grey.withValues(alpha: 0.1);

    if (selectedAnswer != null) {
      if (option == correctAnswer) {
        bgColor = AppConstants.successColor.withValues(alpha: 0.1);
        borderColor = AppConstants.successColor;
        textColor = AppConstants.successColor;
      } else if (option == selectedAnswer) {
        bgColor = AppConstants.errorColor.withValues(alpha: 0.1);
        borderColor = AppConstants.errorColor;
        textColor = AppConstants.errorColor;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          border: Border.all(
            color: borderColor,
            width:
                selectedAnswer != null &&
                    (option == correctAnswer || option == selectedAnswer)
                ? 2
                : 1,
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 5,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            onTap: selectedAnswer == null ? onTap : null,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Expanded(
                    child: Text(
                      option,
                      style: AppConstants.bodyStyle.copyWith(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: textColor,
                      ),
                    ),
                  ),
                  if (selectedAnswer != null && option == correctAnswer)
                    const Icon(
                      CupertinoIcons.checkmark_circle_fill,
                      color: AppConstants.successColor,
                    ),
                  if (selectedAnswer != null &&
                      option == selectedAnswer &&
                      option != correctAnswer)
                    const Icon(
                      CupertinoIcons.xmark_circle_fill,
                      color: AppConstants.errorColor,
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ResultDialog extends StatelessWidget {
  final int score;
  final int total;
  final VoidCallback onClose;

  const _ResultDialog({
    required this.score,
    required this.total,
    required this.onClose,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isSuccess = score >= total * 0.8;

    return Dialog(
      backgroundColor: isDark
          ? AppConstants.darkCardColor
          : AppConstants.cardColor,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(AppConstants.cardRadius),
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
              color: isSuccess ? Colors.amber : AppConstants.accentColor,
            ),
            const SizedBox(height: 24),
            Text(
              'quiz.completed'.tr(),
              style: AppConstants.headingStyle.copyWith(
                fontSize: 24,
                fontStyle: FontStyle.normal,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              '${'quiz.score'.tr()} $score / $total',
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: isSuccess
                    ? AppConstants.successColor
                    : AppConstants.accentColor,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              isSuccess ? 'quiz.excellent'.tr() : 'quiz.keepPracticing'.tr(),
              textAlign: TextAlign.center,
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 32),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppConstants.accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonRadius,
                    ),
                  ),
                ),
                child: Text(
                  'quiz.backToHome'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
