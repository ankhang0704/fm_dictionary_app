// file: lib/screens/learning/review_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/learning/quiz_configuration_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/word_model.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/database/word_service.dart';
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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressBoxListenable = Hive.box(
      DatabaseService.progressBoxName,
    ).listenable();

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'review.title'.tr(),
          style: AppConstants.headingStyle.copyWith(
            fontSize: 22,
            fontStyle: FontStyle.normal,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ValueListenableBuilder(
        valueListenable: progressBoxListenable,
        builder: (context, box, _) {
          final reviewWords = _wordService.getWordsToReview();
          return reviewWords.isEmpty
              ? const _EmptyReviewState()
              : _ReviewList(
                  reviewWords: reviewWords,
                  wordService: _wordService,
                );
        },
      ),
      floatingActionButton: ValueListenableBuilder(
        valueListenable: progressBoxListenable,
        builder: (context, box, _) {
          final reviewWords = _wordService.getWordsToReview();
          if (reviewWords.isEmpty) return const SizedBox.shrink();

          return Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              FloatingActionButton.extended(
                heroTag: 'quiz_btn',
                onPressed: () {
                  Navigator.push(
                    context,
                    CupertinoPageRoute(
                      builder: (context) =>
                          const QuizConfigurationScreen(initialTopic: 'Review'),
                    ),
                  );
                },
                backgroundColor: isDark
                    ? AppConstants.darkCardColor
                    : AppConstants.cardColor,
                icon: Icon(
                  CupertinoIcons.question_circle_fill,
                  color: AppConstants.accentColor,
                ),
                label: Text(
                  'review.quiz_test'.tr(),
                  style: const TextStyle(
                    color: AppConstants.accentColor,
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
                    CupertinoPageRoute(
                      builder: (context) => const StudyScreen(topic: 'Review'),
                    ),
                  );
                },
                backgroundColor: AppConstants.accentColor,
                icon: const Icon(
                  CupertinoIcons.play_arrow_solid,
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
          );
        },
      ),
    );
  }
}

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppConstants.successColor.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 80,
                color: AppConstants.successColor,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'review.empty_state_title'.tr(),
              textAlign: TextAlign.center,
              style: AppConstants.headingStyle.copyWith(
                fontSize: 24,
                fontStyle: FontStyle.normal,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'review.empty_state_message'.tr(),
              textAlign: TextAlign.center,
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondary,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReviewList extends StatelessWidget {
  final List<Word> reviewWords;
  final WordService wordService;

  const _ReviewList({required this.reviewWords, required this.wordService});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        8,
        AppConstants.defaultPadding,
        160,
      ),
      physics: const BouncingScrollPhysics(),
      itemCount: reviewWords.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = reviewWords[index];
        final progress = wordService.getWordProgress(word.id);
        final int wrongCount = progress['wc'] as int;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
            boxShadow: isDark
                ? []
                : [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.02),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 8,
            ),
            title: Text(
              word.word,
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 16,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            subtitle: Padding(
              padding: const EdgeInsets.only(top: 4),
              child: Text(
                word.meaning,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: AppConstants.bodyStyle.copyWith(
                  fontSize: 14,
                  color: AppConstants.textSecondary,
                ),
              ),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: AppConstants.errorColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    CupertinoIcons.exclamationmark_triangle_fill,
                    size: 12,
                    color: AppConstants.errorColor,
                  ),
                  const SizedBox(width: 4),
                  Text(
                    '$wrongCount',
                    style: const TextStyle(
                      color: AppConstants.errorColor,
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
