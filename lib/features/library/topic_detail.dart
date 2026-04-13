// file: lib/screens/library/topic_detail_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../data/models/word_model.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/database/word_service.dart';
import '../../core/constants/constants.dart';
import '../learning/study_screen.dart';
import '../learning/quiz_configuration_screen.dart';
import '../search/word_detail_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final String topic;
  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  String _searchQuery = "";
  final WordService _wordService = WordService();
  final ScrollController _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
      builder: (context, wordBox, child) {
        final allWords = _wordService.getWordsByTopic(widget.topic);
        final filteredWords = allWords
            .where(
              (w) => w.word.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();

        final learnedCount = allWords
            .where((w) => _wordService.isWordLearned(w.id))
            .length;
        final progress = allWords.isEmpty
            ? 0.0
            : learnedCount / allWords.length;

        return Scaffold(
          backgroundColor: isDark
              ? AppConstants.darkBgColor
              : AppConstants.backgroundColor,
          body: CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              _TopicSliverAppBar(
                topic: widget.topic,
                learnedCount: learnedCount,
                totalCount: allWords.length,
                progress: progress,
                isDark: isDark,
              ),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    children: [
                      _SearchBar(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        isDark: isDark,
                      ),
                      const SizedBox(height: 24),
                      Row(
                        children: [
                          Expanded(
                            child: _ActionButton(
                              icon: CupertinoIcons.play_arrow_solid,
                              label: 'topic.study'.tr(),
                              color: AppConstants.accentColor,
                              onTap: () => Navigator.push(
                                context,
                                CupertinoPageRoute(
                                  builder: (_) =>
                                      StudyScreen(topic: widget.topic),
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _ActionButton(
                              icon: CupertinoIcons.question_circle_fill,
                              label: 'topic.take_quiz'.tr(),
                              color: Colors.blueAccent,
                              onTap: () {
                                if (allWords.length < 4) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'topic.not_enough_words'.tr(
                                          args: [allWords.length.toString()],
                                        ),
                                      ),
                                      backgroundColor: AppConstants.errorColor,
                                      behavior: SnackBarBehavior.floating,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                          AppConstants.inputRadius,
                                        ),
                                      ),
                                    ),
                                  );
                                  return;
                                }
                                Navigator.push(
                                  context,
                                  CupertinoPageRoute(
                                    builder: (_) => QuizConfigurationScreen(
                                      initialTopic: widget.topic,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              if (filteredWords.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'search.no_results'.tr(args: [_searchQuery]),
                      style: AppConstants.bodyStyle.copyWith(
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final word = filteredWords[index];
                      final isLearned = _wordService.isWordLearned(word.id);

                      return _WordListTile(
                        word: word,
                        isLearned: isLearned,
                        isDark: isDark,
                      );
                    }, childCount: filteredWords.length),
                  ),
                ),
              const SliverToBoxAdapter(child: SizedBox(height: 40)),
            ],
          ),
        );
      },
    );
  }
}

class _TopicSliverAppBar extends StatelessWidget {
  final String topic;
  final int learnedCount;
  final int totalCount;
  final double progress;
  final bool isDark;

  const _TopicSliverAppBar({
    required this.topic,
    required this.learnedCount,
    required this.totalCount,
    required this.progress,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 240,
      pinned: true,
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      elevation: 0,
      leading: Padding(
        padding: const EdgeInsets.only(left: 8.0),
        child: Container(
          margin: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: (isDark ? Colors.black : Colors.white).withValues(
              alpha: 0.3,
            ),
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: isDark ? Colors.white : AppConstants.textPrimary,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      flexibleSpace: FlexibleSpaceBar(
        centerTitle: true,
        titlePadding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
        title: Text(
          topic,
          style: AppConstants.headingStyle.copyWith(
            fontSize: 18,
            fontStyle: FontStyle.normal,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        background: Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
            borderRadius: const BorderRadius.vertical(
              bottom: Radius.circular(32),
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const SizedBox(height: 20),
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppConstants.accentColor.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  AppConstants.topicIcons[topic] ?? CupertinoIcons.book_fill,
                  size: 36,
                  color: AppConstants.accentColor,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                "$learnedCount / $totalCount ${'topic.words_learned'.tr()}",
                style: AppConstants.bodyStyle.copyWith(
                  color: isDark ? Colors.white70 : AppConstants.textSecondary,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 16),
              FractionallySizedBox(
                widthFactor: 0.6,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    value: progress,
                    minHeight: 8,
                    backgroundColor: Colors.grey.withValues(alpha: 0.15),
                    valueColor: AlwaysStoppedAnimation<Color>(
                      progress == 1.0
                          ? AppConstants.successColor
                          : AppConstants.accentColor,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 30), // Không gian cho title
            ],
          ),
        ),
      ),
    );
  }
}

class _SearchBar extends StatelessWidget {
  final ValueChanged<String> onChanged;
  final bool isDark;

  const _SearchBar({required this.onChanged, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextField(
      onChanged: onChanged,
      style: TextStyle(color: isDark ? Colors.white : AppConstants.textPrimary),
      decoration: InputDecoration(
        hintText: 'topic.search_words'.tr(),
        hintStyle: TextStyle(color: AppConstants.textSecondary),
        prefixIcon: Icon(
          CupertinoIcons.search,
          color: AppConstants.textSecondary,
        ),
        filled: true,
        fillColor: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: isDark
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(
            color: AppConstants.accentColor,
            width: 1.5,
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 56,
      child: ElevatedButton.icon(
        onPressed: onTap,
        icon: Icon(icon, size: 20),
        label: Text(
          label,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15),
        ),
        style: ElevatedButton.styleFrom(
          backgroundColor: color,
          foregroundColor: Colors.white,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
      ),
    );
  }
}

class _WordListTile extends StatelessWidget {
  final Word word;
  final bool isLearned;
  final bool isDark;

  const _WordListTile({
    required this.word,
    required this.isLearned,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
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
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
        leading: Icon(
          isLearned
              ? CupertinoIcons.checkmark_seal_fill
              : CupertinoIcons.circle,
          color: isLearned ? AppConstants.successColor : AppConstants.textLight,
          size: 26,
        ),
        title: Text(
          word.word,
          style: AppConstants.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 16,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        subtitle: Padding(
          padding: const EdgeInsets.only(top: 4),
          child: Text(
            word.meaning,
            style: AppConstants.bodyStyle.copyWith(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
        trailing: Icon(
          CupertinoIcons.chevron_right,
          color: AppConstants.textLight,
          size: 18,
        ),
        onTap: () => Navigator.push(
          context,
          CupertinoPageRoute(builder: (_) => WordDetailScreen(word: word)),
        ),
      ),
    );
  }
}
