// file: lib/screens/library/library_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/screens/library/topic_detail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database/database_service.dart';
import '../../services/database/word_service.dart';
import '../../core/constants/constants.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});
  static final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, progressBox, child) {
          return SafeArea(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppConstants.defaultPadding,
                    24,
                    AppConstants.defaultPadding,
                    16,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'categories.title'.tr(),
                        style: AppConstants.headingStyle.copyWith(
                          fontSize: 28,
                          fontStyle: FontStyle.normal,
                          color: isDark
                              ? Colors.white
                              : AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'categories.explore_title'.tr(),
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.textSecondary,
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ValueListenableBuilder(
                    valueListenable: Hive.box<Word>(
                      DatabaseService.wordBoxName,
                    ).listenable(),
                    builder: (context, wordBox, child) {
                      final Map<String, int> topicCounts = {};
                      final Map<String, int> learnedCounts = {};

                      for (var word in wordBox.values) {
                        topicCounts[word.topic] =
                            (topicCounts[word.topic] ?? 0) + 1;
                        if (_wordService.isWordLearned(word.id)) {
                          learnedCounts[word.topic] =
                              (learnedCounts[word.topic] ?? 0) + 1;
                        }
                      }
                      final topics = topicCounts.keys.toList();
                      // Tùy chọn: Sắp xếp topics theo alphabet hoặc custom
                      topics.sort();

                      return ListView.separated(
                        physics: const BouncingScrollPhysics(),
                        padding: const EdgeInsets.only(
                          left: AppConstants.defaultPadding,
                          right: AppConstants.defaultPadding,
                          bottom:
                              100, // Thêm padding bottom để không bị che bởi BottomNav
                        ),
                        itemCount: topics.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: 16),
                        itemBuilder: (context, index) {
                          final name = topics[index];
                          final totalCount = topicCounts[name] ?? 0;
                          final learnedCount = learnedCounts[name] ?? 0;
                          final icon =
                              AppConstants.topicIcons[name] ??
                              CupertinoIcons.book_fill;
                          final progress = totalCount > 0
                              ? learnedCount / totalCount
                              : 0.0;

                          return _TopicCard(
                            name: name,
                            totalCount: totalCount,
                            learnedCount: learnedCount,
                            progress: progress,
                            icon: icon,
                            isDark: isDark,
                            onTap: () => Navigator.push(
                              context,
                              CupertinoPageRoute(
                                builder: (context) =>
                                TopicDetailScreen(topic: name),
                              ),
                            ),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _TopicCard extends StatelessWidget {
  final String name;
  final int totalCount;
  final int learnedCount;
  final double progress;
  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;

  const _TopicCard({
    required this.name,
    required this.totalCount,
    required this.learnedCount,
    required this.progress,
    required this.icon,
    required this.isDark,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius / 1.5),
          border: Border.all(
            color: isDark
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.1),
          ),
          boxShadow: isDark
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.03),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Icon(icon, color: AppConstants.accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: AppConstants.bodyStyle.copyWith(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$learnedCount / $totalCount ${'categories.words_learned'.tr()}',
                    style: AppConstants.bodyStyle.copyWith(
                      fontSize: 13,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  const SizedBox(height: 12),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      backgroundColor: Colors.grey.withValues(alpha: 0.15),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0
                            ? AppConstants.successColor
                            : AppConstants.accentColor,
                      ),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Icon(
              CupertinoIcons.chevron_right,
              color: AppConstants.textLight,
              size: 20,
            ),
          ],
        ),
      ),
    );
  }
}
