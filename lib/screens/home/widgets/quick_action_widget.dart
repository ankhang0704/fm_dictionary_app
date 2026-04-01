import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/screens/learning/quiz_configuration_screen.dart';
import 'package:fm_dictionary/screens/learning/study_screen.dart';
import 'package:fm_dictionary/services/database/word_service.dart';
import 'package:fm_dictionary/widgets/common/smart_action_button.dart';

class QuickActionsList extends StatelessWidget {
  final WordService wordService;
  final bool isDark;

  const QuickActionsList({
    super.key,
    required this.wordService,
    required this.isDark,
  });

  void _handleContinue(BuildContext context) {
    final topics = wordService.getAllTopics();
    String targetTopic = topics.isNotEmpty ? topics.first : 'General';
    for (var topic in topics) {
      final words = wordService.getWordsByTopic(topic);
      if (words.any((w) => !wordService.isWordLearned(w.id))) {
        targetTopic = topic;
        break;
      }
    }
    Navigator.push(
      context,
      CupertinoPageRoute(builder: (context) => StudyScreen(topic: targetTopic)),
    );
  }

  void _handleReviewMistakes(BuildContext context) {
    final reviewCount = wordService.getWordsToReview().length;
    if (reviewCount == 0) {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          backgroundColor: isDark
              ? AppConstants.darkCardColor
              : AppConstants.cardColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.cardRadius / 2),
          ),
          title: Text(
            'dashboard.review_mistakes_anouncement'.tr(),
            style: TextStyle(
              color: isDark ? Colors.white : AppConstants.textPrimary,
            ),
          ),
          content: Text(
            'dashboard.review_mistakes_message'.tr(),
            style: TextStyle(
              color: isDark ? Colors.white70 : AppConstants.textSecondary,
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text(
                'dashboard.btn_close'.tr(),
                style: const TextStyle(color: AppConstants.accentColor),
              ),
            ),
          ],
        ),
      );
    } else {
      Navigator.push(
        context,
        CupertinoPageRoute(
          builder: (context) => const StudyScreen(topic: 'Review'),
        ),
      );
    }
  }

  void _handleDailyTest(BuildContext context) {
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (context) =>
            const QuizConfigurationScreen(initialTopic: 'All'),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        SmartActionButton(
          icon: CupertinoIcons.play_arrow_solid,
          title: 'dashboard.continue_title'.tr(),
          subtitle: 'dashboard.continue_subtitle'.tr(),
          color: AppConstants.accentColor.withValues(alpha: 0.1),
          iconColor: AppConstants.accentColor,
          onTap: () => _handleContinue(context),
        ),
        const SizedBox(height: 12),
        SmartActionButton(
          icon: CupertinoIcons.exclamationmark_triangle_fill,
          title: 'dashboard.review_mistakes'.tr(),
          subtitle: 'dashboard.review_mistakes_subtitle'.tr(),
          color: AppConstants.errorColor.withValues(alpha: 0.1),
          iconColor: AppConstants.errorColor,
          onTap: () => _handleReviewMistakes(context),
        ),
        const SizedBox(height: 12),
        SmartActionButton(
          icon: CupertinoIcons.shuffle,
          title: 'dashboard.daily_test'.tr(),
          subtitle: 'dashboard.daily_test_subtitle'.tr(),
          color: AppConstants.successColor.withValues(alpha: 0.1),
          iconColor: AppConstants.successColor,
          onTap: () => _handleDailyTest(context),
        ),
      ],
    );
  }
}
