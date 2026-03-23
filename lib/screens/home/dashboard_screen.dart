import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../services/word_service.dart';
import '../../utils/constants.dart';
import '../../widgets/progress_card.dart';
import '../../widgets/smart_action_button.dart';
import '../learning/study_screen.dart';
import '../learning/quiz_screen.dart';
import '../../widgets/home_search_bar.dart'; // Import widget mới tạo

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WordService _wordService = WordService();
  
  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
        builder: (context, box, _) {
          final learnedCount = box.values.where((w) => w.isLearned).length;
          final totalCount = box.length;
          final reviewCount = _wordService.getWordsToReview().length;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Good Morning,', style: AppConstants.subHeadingStyle),
                  Text(settings.userName, style: AppConstants.headingStyle),
                  const SizedBox(height: 24),

                  // Search Bar
                  const HomeSearchBar(),
                  const SizedBox(height: 32),

                  ProgressCard(learnedCount: learnedCount, totalCount: totalCount),
                  
                  const SizedBox(height: 32),
                  const Text('QUICK ACTIONS', style: AppConstants.subHeadingStyle),
                  const SizedBox(height: 16),

                  SmartActionButton(
                    icon: Icons.play_circle_fill_rounded,
                    title: 'Continue Learning',
                    subtitle: 'Pick up where you left off',
                    color: isDark ? const Color(0xFF1A3B5C) : const Color(0xFFE3F2FD),
                    iconColor: Colors.blue,
                    onTap: () {
                      final topics = _wordService.getAllTopics();
                      String targetTopic = topics.isNotEmpty ? topics.first : 'General';
                      for (var topic in topics) {
                        final words = _wordService.getWordsByTopic(topic);
                        if (words.any((w) => !w.isLearned)) {
                          targetTopic = topic;
                          break;
                        }
                      }
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => StudyScreen(topic: targetTopic)),
                      );
                    },
                  ),
                  const SizedBox(height: 12),
                  SmartActionButton(
                    icon: Icons.error_outline_rounded,
                    title: 'Review Mistakes',
                    subtitle: '$reviewCount words need attention',
                    color: isDark ? const Color(0xFF4A1C1C) : const Color(0xFFFFEBEE),
                    iconColor: Colors.red,
                    onTap: () {
                      final reviewCount = _wordService.getWordsToReview().length;
                      if (reviewCount == 0) {
                        // Hiển thị thông báo thay vì chuyển màn hình
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text("Tuyệt vời!"),
                            content: const Text("Bạn không có từ nào cần ôn tập lúc này. Hãy tiếp tục học từ mới nhé!"),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child: const Text("Đóng"))
                            ],
                          ),
                        );
                      } else {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => const StudyScreen(topic: 'Review')),
                        );
                      }
                    },
                  ),
                  const SizedBox(height: 12),
                  SmartActionButton(
                    icon: Icons.shuffle_rounded,
                    title: 'Random 10 Words',
                    subtitle: 'Quick daily test',
                    color: isDark ? const Color(0xFF1E3A23) : const Color(0xFFF1F8E9),
                    iconColor: Colors.green,
                    onTap: () {
                      final randomWords = _wordService.getRandomWords(10);
                      if (randomWords.isNotEmpty) {
                        Navigator.push(
                          context,
                          MaterialPageRoute(builder: (context) => QuizScreen(words: randomWords)),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('No words available for quiz!')),
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
