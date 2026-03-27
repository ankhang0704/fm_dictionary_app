import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../services/word_service.dart';
import '../../core/utils/constants.dart';
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
          // final reviewCount = _wordService.getWordsToReview().length;

          return SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('dashboard.good_morning'.tr(), style: AppConstants.subHeadingStyle),
                  Text(settings.userName, style: AppConstants.headingStyle),
                  const SizedBox(height: 24),

                  // Search Bar
                  const HomeSearchBar(),
                  const SizedBox(height: 32),

                  ProgressCard(learnedCount: learnedCount, totalCount: totalCount),
                  
                  const SizedBox(height: 32),
                  Text('dashboard.quick_action'.tr(), 
                    style: AppConstants.subHeadingStyle),
                  const SizedBox(height: 16),

                  SmartActionButton(
                    icon: Icons.play_circle_fill_rounded,
                    title: 'dashboard.continue_title'.tr(),
                    subtitle: 'dashboard.continue_subtitle'.tr(),
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
                    title: 'dashboard.review_mistakes'.tr(),
                    subtitle: 'dashboard.review_mistakes_subtitle'.tr(),
                    color: isDark ? const Color(0xFF4A1C1C) : const Color(0xFFFFEBEE),
                    iconColor: Colors.red,
                    onTap: () {
                      final reviewCount = _wordService.getWordsToReview().length;
                      if (reviewCount == 0) {
                        // Hiển thị thông báo thay vì chuyển màn hình
                        showDialog(
                          context: context,
                          builder: (context) => AlertDialog(
                            title:  Text('dashboard.review_mistakes_anouncement'.tr()),
                            content:  Text('dashboard.review_mistakes_message'.tr()),
                            actions: [
                              TextButton(onPressed: () => Navigator.pop(context), child:  Text('dashboard.btn_close'.tr())),
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
                    title: 'dashboard.daily_test'.tr(),
                    subtitle: 'dashboard.daily_test_subtitle'.tr(),
                    color: isDark ? const Color(0xFF1E3A23) : const Color(0xFFF1F8E9),
                    iconColor: Colors.green,
                    onTap: () {
                      final randomWords = _wordService.getRandomWords(10);

                      if (randomWords.isNotEmpty) {
                        // Lấy toàn bộ từ trong DB để làm đáp án gây nhiễu
                        final allWords = Hive.box<Word>(
                          DatabaseService.wordBoxName,
                        ).values.toList();

                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => QuizScreen(
                              targetWords: randomWords, // Các từ cần hỏi
                              distractorPool:
                                  allWords, // Kho từ để lấy đáp án sai
                              questionCount: randomWords
                                  .length, // Số lượng câu hỏi (thường là 10)
                            ),
                          ),
                        );
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                           SnackBar(
                            content: Text('dashboard.daily_test_message'.tr()),
                          ),
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
