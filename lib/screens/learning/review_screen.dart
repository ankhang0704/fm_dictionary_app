import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../services/word_service.dart';
import '../../core/utils/constants.dart';
import 'study_screen.dart';
import 'quiz_screen.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({super.key});

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title:  Text(
          'review.title'.tr(),
          style: AppConstants.subHeadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
        builder: (context, box, _) {
          final reviewWords = _wordService.getWordsToReview();
          return reviewWords.isEmpty
              ? _buildEmptyState()
              : _buildReviewList(reviewWords);
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
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
                       final reviewWords = _wordService.getWordsToReview();

                        if (reviewWords.isNotEmpty) {
                          // Lấy toàn bộ từ trong DB để làm đáp án gây nhiễu
                          final allWords = Hive.box<Word>(
                            DatabaseService.wordBoxName,
                          ).values.toList();

                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => QuizScreen(
                                targetWords:
                                    reviewWords, // Các từ sai cần ôn lại
                                distractorPool:
                                    allWords, // Kho từ để lấy đáp án sai
                                questionCount: reviewWords
                                    .length, // Hỏi hết các từ đang bị sai
                              ),
                            ),
                          );
                        } else {
                          // Thông báo nếu không có từ nào cần ôn tập (Như ta đã bàn ở trên)
                          showDialog(
                            context: context,
                            builder: (context) => AlertDialog(
                              title:  Text('review.no_words'.tr()),
                              content:  Text(
                                'review.no_words_desc'.tr(),
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(context),
                                  child:  Text('review.close'.tr()),
                                ),
                              ],
                            ),
                          );
                        }
                      },
                      backgroundColor: AppConstants.primaryColor,
                      icon: const Icon(Icons.quiz_rounded, color: Colors.white),
                      label:  Text('review.quiz_test'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                    const SizedBox(height: 12),
                    FloatingActionButton.extended(
                      heroTag: 'study_btn',
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => const StudyScreen(topic: 'Review'),
                          ),
                        );
                      },
                      backgroundColor: AppConstants.accentColor,
                      icon: const Icon(Icons.play_arrow_rounded, color: Colors.white),
                      label:  Text('review.start_review'.tr(), style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
          Icon(Icons.check_circle_outline_rounded, size: 80, color: AppConstants.successColor.withValues(alpha: 0.5)),
          const SizedBox(height: 24),
           Text(
            'review.empty_state_title'.tr(),
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 8),
           Text(
            'review.empty_state_message'.tr(),
            style: TextStyle(color: AppConstants.textSecondary),
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
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            title: Text(word.word, style: const TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text(word.meaning, maxLines: 1, overflow: TextOverflow.ellipsis),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${word.wrongCount} mistakes',
                style: const TextStyle(color: AppConstants.errorColor, fontSize: 10, fontWeight: FontWeight.bold),
              ),
            ),
          ),
        );
      },
    );
  }
}
