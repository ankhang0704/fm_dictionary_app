import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/progress_keys.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';
import '../../../../core/constants/constants.dart';
import 'quiz_configuration_screen.dart';
import 'study_screen.dart';

class SmartReviewScreen extends StatefulWidget {
  const SmartReviewScreen({super.key});

  @override
  State<SmartReviewScreen> createState() => _SmartReviewScreenState();
}

class _SmartReviewScreenState extends State<SmartReviewScreen> {
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
          'Ôn tập thông minh', // Thay đổi tên cho chuyên nghiệp
          style: TextStyle(
            fontSize: 22,
            fontWeight: FontWeight.bold,
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

          if (reviewWords.isEmpty) return const _EmptyReviewState();

          return Stack(
            children: [
              _buildReviewList(reviewWords, isDark),
              _buildStickyBottomAction(
                context,
                isDark,
              ), // Thanh action bar thay cho FAB
            ],
          );
        },
      ),
    );
  }

  Widget _buildReviewList(List<Word> reviewWords, bool isDark) {
    return ListView.separated(
      padding: const EdgeInsets.fromLTRB(
        AppConstants.defaultPadding,
        8,
        AppConstants.defaultPadding,
        120,
      ), // Padding đáy chừa chỗ cho bottom bar
      physics: const BouncingScrollPhysics(),
      itemCount: reviewWords.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = reviewWords[index];
        final progress = _wordService.getWordProgress(word.id);
        final int wrongCount = progress[ProgressKeys.wrongCount] as int;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
            borderRadius: BorderRadius.circular(20), // Chuẩn Bento
            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
          ),
          child: ListTile(
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 12,
            ),
            title: Text(
              word.word,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
            ),
            subtitle: Text(
              word.meaning,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: Colors.grey),
            ),
            trailing: wrongCount > 0
                ? Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: AppConstants.errorColor.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          CupertinoIcons.exclamationmark_triangle_fill,
                          size: 14,
                          color: AppConstants.errorColor,
                        ),
                        const SizedBox(width: 4),
                        Text(
                          '$wrongCount lỗi',
                          style: const TextStyle(
                            color: AppConstants.errorColor,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  )
                : const Icon(
                    CupertinoIcons.checkmark_seal_fill,
                    color: AppConstants.successColor,
                  ),
          ),
        );
      },
    );
  }

  Widget _buildStickyBottomAction(BuildContext context, bool isDark) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              20,
              16,
              20,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color:
                  (isDark
                          ? AppConstants.darkBgColor
                          : AppConstants.backgroundColor)
                      .withValues(alpha: 0.8),
              border: Border(
                top: BorderSide(color: Colors.grey.withValues(alpha: 0.1)),
              ),
            ),
            child: Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants
                            .cardColor, // Nút test có màu nền nổi bật
                        foregroundColor: AppConstants.accentColor,
                        elevation: 0,
                        side: const BorderSide(color: AppConstants.accentColor),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(CupertinoIcons.question_circle_fill),
                      label: const Text(
                        'Làm Test',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () => Navigator.push(
                        context,
                        CupertinoPageRoute(
                          builder: (_) => const QuizConfigurationScreen(
                            initialTopic: 'Review',
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: SizedBox(
                    height: 56,
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppConstants.accentColor,
                        foregroundColor: Colors.white,
                        elevation: 0,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                        ),
                      ),
                      icon: const Icon(CupertinoIcons.play_arrow_solid),
                      label: const Text(
                        'Học ngay',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      onPressed: () {
                        final words = context
                            .read<HomeProvider>()
                            .getWordsByTopicName('Review');
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => StudyScreen(words: words),
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// EMPTY STATE CHUẨN BENTO
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
              "Tuyệt vời!",
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              "Bạn đã ôn tập xong tất cả các từ vựng cần thiết cho hôm nay. Não bộ của bạn đang được nghỉ ngơi.",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: AppConstants.textSecondary,
                height: 1.5,
                fontSize: 16,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
