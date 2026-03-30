import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/models/word_model.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/tts_service.dart';
import 'quiz_configuration_screen.dart'; // import Enum QuizMode


class QuizScreen extends StatefulWidget {
  final List<Word> targetWords;
  final List<Word> distractorPool;
  final int questionCount; // Nhận số lượng câu hỏi từ bên ngoài
  final QuizMode mode; // Nhận loại quiz từ bên ngoài
  const QuizScreen({
    super.key, 
    required this.targetWords, 
    required this.distractorPool,
    this.questionCount = 10, // Mặc định là 10
    required this.mode 
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
    quizData =[];
    final pool = List<Word>.from(widget.distractorPool);
    
    for (var word in widget.targetWords) {
      pool.shuffle();
      final distractors = pool.where((w) => w.id != word.id).take(3).toList();
      
      String correctAnswer;
      List<String> options =[];

      // Logic Map Đáp Án Theo Mode
      if (widget.mode == QuizMode.viToEn) {
        correctAnswer = word.word;
        options =[correctAnswer, ...distractors.map((w) => w.word)];
      } else {
        // EnToVi và Listening đều có chung kiểu đáp án là Tiếng Việt
        correctAnswer = word.meaning;
        options =[correctAnswer, ...distractors.map((w) => w.meaning)];
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
      _ttsService.speak(currentWord.word, accent:'en-US');
    }
  }
  void _checkAnswer(String option) {
    if (selectedAnswer != null) return;

    bool correct = option == quizData[currentIndex]['correctAnswer'];
    setState(() {
      selectedAnswer = option;
      if (correct) score++;
    });

    Future.delayed(const Duration(milliseconds: 1000), () {
      if (!mounted) return;
      if (currentIndex < quizData.length - 1) {
        setState(() {
          currentIndex++;
          selectedAnswer = null;
        });
        _playAudioIfListeningMode(); // Tự động phát âm thanh câu tiếp theo
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
          Navigator.pop(context); // Close dialog
          Navigator.pop(context); // Return to dashboard
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (quizData.isEmpty) {
      return Scaffold(
        appBar: AppBar(title:  Text('quiz.title'.tr(), style: AppConstants.headingStyle)),
        body:  Center(child: Text('quiz.noData'.tr(), style: AppConstants.subHeadingStyle)),
      );
    }

    final currentQuestion = quizData[currentIndex];
    // final Word word = currentQuestion['wordObj'] as Word;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("${'quiz.question'.tr()} ${currentIndex + 1}/${quizData.length}",
            style: AppConstants.subHeadingStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close_rounded),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            children: [
              _buildProgressBar(),
              const SizedBox(height: 30),
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      _buildQuestionSection(currentQuestion['wordObj'] as Word),
                      const SizedBox(height: 40),
                      _buildOptionsSection(currentQuestion),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProgressBar() {
    return LinearProgressIndicator(
      value: (currentIndex + 1) / quizData.length,
      backgroundColor: Colors.grey.withValues(alpha:0.1),
      valueColor: const AlwaysStoppedAnimation<Color>(AppConstants.accentColor),
      borderRadius: BorderRadius.circular(10),
      minHeight: 8,
    );
  }

Widget _buildQuestionSection(Word currentWord) {
  return Column(
      mainAxisSize: MainAxisSize.min,
      children:[
        Text(
          widget.mode == QuizMode.listening 
              ? 'quiz.listen_instruction'.tr() 
              : 'quiz.translation_instruction'.tr(),
          style: TextStyle(color: Colors.grey[600], fontSize: 16),
        ),
        const SizedBox(height: 24),

        if (widget.mode == QuizMode.listening)
          Column(
            children:[
              Container(
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  iconSize: 80,
                  color: Theme.of(context).colorScheme.primary,
                  icon: const Icon(Icons.volume_up_rounded),
                  onPressed: () => _ttsService.speak(currentWord.word, accent:'en-US'),
                ),
              ),
              const SizedBox(height: 12),
              Text('quiz.tap_to_listen'.tr(), style: const TextStyle(fontStyle: FontStyle.italic, color: Colors.blue)),
            ],
          )
        else
          Text(
            // Nếu là Mode ViToEn -> Hiển thị Tiếng Việt, ngược lại hiển thị Tiếng Anh
            widget.mode == QuizMode.viToEn ? currentWord.meaning : currentWord.word, 
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
              fontWeight: FontWeight.bold,
              color: Theme.of(context).colorScheme.onSurface,
            ),
            textAlign: TextAlign.center,
          ),
      ],
    );
  }


  Widget _buildOptionsSection(Map<String, dynamic> currentQuestion) {
    final List<String> options = List<String>.from(currentQuestion['options']);
    return Column(
      children: options.map((option) {
        return _QuizOption(
          option: option,
          correctAnswer: currentQuestion['correctAnswer'],
          selectedAnswer: selectedAnswer,
          onTap: () => _checkAnswer(option),
        );
      }).toList(),
    );
  }

}
class _QuizOption extends StatelessWidget {
  final String option;
  final String correctAnswer;
  final String? selectedAnswer;
  final VoidCallback onTap;

  const _QuizOption({
    required this.option,
    required this.correctAnswer,
    this.selectedAnswer,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    Color bgColor = Theme.of(context).cardColor;
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.black;
    Color borderColor = Colors.grey.withValues(alpha: 0.1);

    if (selectedAnswer != null) {
      if (option == correctAnswer) {
        bgColor = AppConstants.successColor.withValues(alpha: 0.2);
        borderColor = AppConstants.successColor;
        textColor = AppConstants.successColor;
      } else if (option == selectedAnswer) {
        bgColor = AppConstants.errorColor.withValues(alpha: 0.2);
        borderColor = AppConstants.errorColor;
        textColor = AppConstants.errorColor;
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        width: double.infinity,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: borderColor, width: selectedAnswer != null && (option == correctAnswer || option == selectedAnswer) ? 2 : 1),
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(16),
            onTap: onTap,
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                option,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: textColor),
                textAlign: TextAlign.center,
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
    return AlertDialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      title:  Text('quiz.completed'.tr(),
          textAlign: TextAlign.center, style: AppConstants.headingStyle),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.emoji_events_rounded, size: 80, color: Colors.amber),
          const SizedBox(height: 16),
          Text(
            '${'quiz.score'.tr()} $score / $total',
            style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            score >= total * 0.8 ? 'quiz.excellent'.tr() : 'quiz.keepPracticing'.tr(),
            style: const TextStyle(color: AppConstants.textSecondary),
          ),
        ],
      ),
      actions: [
        Center(
          child: ElevatedButton(
            onPressed: onClose,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
            ),
            child: Text('quiz.backToHome'.tr(),
                style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          ),
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
