import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/screens/learning/quiz_configuration_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database/database_service.dart';
import '../../services/database/word_service.dart';
import '../../core/constants/constants.dart';
import 'study_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    // TỐI ƯU 1: Lắng nghe sự thay đổi của Progress Box thay vì Word Box
    final progressBoxListenable = Hive.box(
      DatabaseService.progressBoxName,
    ).listenable();

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('review.title'.tr(), style: AppConstants.subHeadingStyle),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: progressBoxListenable,
        builder: (context, box, _) {
          final reviewWords = _wordService.getWordsToReview();
          return reviewWords.isEmpty
              ? _buildEmptyState()
              : _buildReviewList(reviewWords);
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: progressBoxListenable,
        builder: (context, box, _) {
          final reviewWords = _wordService.getWordsToReview();
          return reviewWords.isNotEmpty
              ? Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    FloatingActionButton.extended(
                      heroTag: 'quiz_btn',
                      onPressed: () {
                        if (reviewWords.isNotEmpty) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  const QuizConfigurationScreen(
                                    initialTopic: 'Review',
                                  ),
                            ),
                          );
                        }
                      },
                      backgroundColor: AppConstants.primaryColor,
                      icon: const Icon(Icons.quiz_rounded, color: Colors.white),
                      label: Text(
                        'review.quiz_test'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'study_btn',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                const StudyScreen(topic: 'Review'),
                          ),
                        );
                      },
                      backgroundColor: AppConstants.accentColor,
                      icon: const Icon(
                        Icons.play_arrow_rounded,
                        color: Colors.white,
                      ),
                      label: Text(
                        'review.start_review'.tr(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                )
              : const SizedBox.shrink();
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline_rounded,
            size: 80,
            color: AppConstants.successColor.withValues(alpha: 0.5),
          ),
          const SizedBox(height: 24),
          Text(
            'review.empty_state_title'.tr(),
            style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
          Text(
            'review.empty_state_message'.tr(),
            style: const TextStyle(color: AppConstants.textSecondary),
          ),
        ],
      ),
    );
  }

  Widget _buildReviewList(List<Word> reviewWords) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      itemCount: reviewWords.length,
      separatorBuilder: (context, index) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = reviewWords[index];

        // TỐI ƯU 2: Lấy wrongCount (wc) từ thuật toán Anki
        final progress = _wordService.getWordProgress(word.id);
        final int wrongCount = progress['wc'] as int;

        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            title: Text(
              word.word,
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            subtitle: Text(
              word.meaning,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '$wrongCount mistakes', // Bạn có thể cân nhắc chuyển sang .tr() nếu muốn dịch chữ "mistakes"
                style: const TextStyle(
                  color: AppConstants.errorColor,
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}
