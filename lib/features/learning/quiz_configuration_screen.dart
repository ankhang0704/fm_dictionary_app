import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../data/models/word_model.dart';
import '../../data/services/database/word_service.dart';
import '../../core/constants/constants.dart';
import 'quiz_screen.dart';

enum QuizMode { enToVi, viToEn, listening }

class QuizConfigurationScreen extends StatefulWidget {
  final String initialTopic;
  const QuizConfigurationScreen({super.key, this.initialTopic = 'All'});

  @override
  State<QuizConfigurationScreen> createState() =>
      _QuizConfigurationScreenState();
}

class _QuizConfigurationScreenState extends State<QuizConfigurationScreen> {
  final WordService _wordService = WordService();
  late String _selectedTopic;
  int _questionCount = 10;
  QuizMode _selectedMode = QuizMode.enToVi;

  List<Word> _currentWordsPool = [];

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.initialTopic;
    _updateWordsPool();
  }

  void _updateWordsPool() {
    if (_selectedTopic == 'All') {
      _currentWordsPool = _wordService.getRandomWords(9999);
    } else if (_selectedTopic == 'Review') {
      _currentWordsPool = _wordService.getWordsToReview();
    } else {
      _currentWordsPool = _wordService.getWordsByTopic(_selectedTopic);
    }

    final maxWords = _currentWordsPool.length;
    if (maxWords < 4) {
      _questionCount = maxWords;
    } else {
      if (_questionCount > maxWords && _questionCount != 9999) {
        _questionCount = 10;
      }
      if (_questionCount == 10 && maxWords < 10) {
        _questionCount = 9999;
      }
    }
  }

  void _startQuiz() {
    List<Word> targetWords = List.from(_currentWordsPool);
    targetWords.shuffle();

    if (_questionCount != 9999) {
      targetWords = targetWords.take(_questionCount).toList();
    }

    final distractorPool = _wordService.getRandomWords(9999);

    Navigator.pushReplacement(
      context,
      CupertinoPageRoute(
        builder: (_) => QuizScreen(
          targetWords: targetWords,
          distractorPool: distractorPool,
          questionCount: targetWords.length,
          mode: _selectedMode,
        ),
      ),
    );
  }

  String _getTopicDisplayName(String topic) {
    if (topic == 'All') return 'quiz_config.topic_all'.tr();
    if (topic == 'Review') return 'quiz_config.topic_review'.tr();
    return topic;
  }

  void _showTopicPicker() {
    final topics = ['All', 'Review', ..._wordService.getAllTopics()];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppConstants.cardRadius),
            ),
          ),
          constraints: BoxConstraints(
            maxHeight: MediaQuery.of(context).size.height * 0.7,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(height: 12),
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.withValues(alpha: 0.3),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'quiz_config.select_topic'.tr(),
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 16),
              Flexible(
                child: ListView.builder(
                  shrinkWrap: true,
                  physics: const BouncingScrollPhysics(),
                  itemCount: topics.length,
                  itemBuilder: (context, index) {
                    final topic = topics[index];
                    final isSelected = _selectedTopic == topic;
                    return InkWell(
                      onTap: () {
                        setState(() {
                          _selectedTopic = topic;
                          _updateWordsPool();
                        });
                        Navigator.pop(context);
                      },
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 24,
                          vertical: 16,
                        ),
                        color: isSelected
                            ? AppConstants.accentColor.withValues(alpha: 0.1)
                            : Colors.transparent,
                        child: Row(
                          children: [
                            Icon(
                              topic == 'Review'
                                  ? CupertinoIcons.refresh_thick
                                  : CupertinoIcons.tag_fill,
                              size: 22,
                              color: isSelected
                                  ? AppConstants.accentColor
                                  : AppConstants.textSecondary,
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: Text(
                                _getTopicDisplayName(topic),
                                style: AppConstants.bodyStyle.copyWith(
                                  fontSize: 16,
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : FontWeight.normal,
                                  color: isSelected
                                      ? AppConstants.accentColor
                                      : (isDark
                                            ? Colors.white
                                            : AppConstants.textPrimary),
                                ),
                              ),
                            ),
                            if (isSelected)
                              const Icon(
                                CupertinoIcons.checkmark_alt,
                                color: AppConstants.accentColor,
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final maxWords = _currentWordsPool.length;
    final bool isNotEnoughWords = maxWords < 4;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'quiz_config.config_title'.tr(),
          style: AppConstants.headingStyle.copyWith(
            fontSize: 20,
            fontWeight: FontWeight.w800,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      body: Stack(
        children: [
          SafeArea(
            child: ListView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.symmetric(
                horizontal: AppConstants.defaultPadding,
              ),
              children: [
                const SizedBox(height: 12),
                _SectionHeader(title: 'quiz_config.select_topic'.tr()),
                _TopicTile(
                  topicName: _getTopicDisplayName(_selectedTopic),
                  onTap: _showTopicPicker,
                ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'quiz_config.select_count'.tr()),
                if (isNotEnoughWords)
                  _NotEnoughWordsWarning(maxWords: maxWords)
                else
                  _CountSelector(
                    maxWords: maxWords,
                    selectedCount: _questionCount,
                    onChanged: (val) => setState(() => _questionCount = val),
                  ),
                const SizedBox(height: 24),
                _SectionHeader(title: 'quiz_config.select_mode'.tr()),
                _ModeSelector(
                  selectedMode: _selectedMode,
                  onChanged: (val) => setState(() => _selectedMode = val),
                ),
                const SizedBox(height: 120),
              ],
            ),
          ),
          _StickyBottomAction(
            isNotEnoughWords: isNotEnoughWords,
            onPressed: _startQuiz,
          ),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4, bottom: 10),
      child: Text(
        title.toUpperCase(),
        style: AppConstants.bodyStyle.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: AppConstants.textSecondary,
          letterSpacing: 1.2,
        ),
      ),
    );
  }
}

class _TopicTile extends StatelessWidget {
  final String topicName;
  final VoidCallback onTap;

  const _TopicTile({required this.topicName, required this.onTap});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.15)),
        ),
        child: Row(
          children: [
            const Icon(
              CupertinoIcons.book_fill,
              color: Colors.blueAccent,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                topicName,
                style: AppConstants.bodyStyle.copyWith(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
              ),
            ),
            Icon(
              CupertinoIcons.chevron_up_chevron_down,
              size: 16,
              color: AppConstants.textSecondary,
            ),
          ],
        ),
      ),
    );
  }
}

class _CountSelector extends StatelessWidget {
  final int maxWords;
  final int selectedCount;
  final ValueChanged<int> onChanged;

  const _CountSelector({
    required this.maxWords,
    required this.selectedCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final List<int> options = [];
    if (maxWords >= 10) options.add(10);
    if (maxWords >= 20) options.add(20);
    if (maxWords >= 50) options.add(50);
    options.add(9999);

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: options.map((count) {
        final isSelected = selectedCount == count;
        final label = count == 9999
            ? "${'quiz_config.all'.tr()}($maxWords)"
            : "$count";

        return InkWell(
          onTap: () => onChanged(count),
          borderRadius: BorderRadius.circular(12),
          child: AnimatedContainer(
            duration: AppConstants.defaultAnimationDuration,
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppConstants.accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppConstants.accentColor
                    : Colors.grey.withValues(alpha: 0.3),
                width: 1.5,
              ),
            ),
            child: Text(
              label,
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 14,
                fontWeight: FontWeight.bold,
                color: isSelected ? Colors.white : AppConstants.textSecondary,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ModeSelector extends StatelessWidget {
  final QuizMode selectedMode;
  final ValueChanged<QuizMode> onChanged;

  const _ModeSelector({required this.selectedMode, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ModeCard(
          title: 'quiz_config.mode_en_vi'.tr(),
          icon: CupertinoIcons.arrow_right_arrow_left,
          isSelected: selectedMode == QuizMode.enToVi,
          onTap: () => onChanged(QuizMode.enToVi),
        ),
        const SizedBox(height: 12),
        _ModeCard(
          title: 'quiz_config.mode_vi_en'.tr(),
          icon: CupertinoIcons.arrow_left_right_square,
          isSelected: selectedMode == QuizMode.viToEn,
          onTap: () => onChanged(QuizMode.viToEn),
        ),
        const SizedBox(height: 12),
        _ModeCard(
          title: 'quiz_config.mode_listening'.tr(),
          icon: CupertinoIcons.headphones,
          isSelected: selectedMode == QuizMode.listening,
          onTap: () => onChanged(QuizMode.listening),
        ),
      ],
    );
  }
}

class _ModeCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final bool isSelected;
  final VoidCallback onTap;

  const _ModeCard({
    required this.title,
    required this.icon,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.accentColor.withValues(alpha: 0.1)
              : (isDark ? AppConstants.darkCardColor : AppConstants.cardColor),
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          border: Border.all(
            color: isSelected
                ? AppConstants.accentColor
                : Colors.grey.withValues(alpha: 0.1),
            width: 2,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppConstants.accentColor
                  : AppConstants.textSecondary,
              size: 22,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w600,
                  fontSize: 14,
                  color: isSelected
                      ? AppConstants.accentColor
                      : (isDark ? Colors.white : AppConstants.textPrimary),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_alt_circle_fill,
                color: AppConstants.accentColor,
                size: 22,
              ),
          ],
        ),
      ),
    );
  }
}

class _NotEnoughWordsWarning extends StatelessWidget {
  final int maxWords;
  const _NotEnoughWordsWarning({required this.maxWords});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppConstants.errorColor.withValues(alpha: 0.08),
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        border: Border.all(color: AppConstants.errorColor.withValues(alpha: 0.2)),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_circle_fill,
            color: AppConstants.errorColor,
            size: 22,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'quiz_config.not_enough_words'.tr(args: [maxWords.toString()]),
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.errorColor,
                fontWeight: FontWeight.w600,
                fontSize: 14,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StickyBottomAction extends StatelessWidget {
  final bool isNotEnoughWords;
  final VoidCallback onPressed;

  const _StickyBottomAction({
    required this.isNotEnoughWords,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppConstants.defaultPadding,
              16,
              AppConstants.defaultPadding,
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
            child: SizedBox(
              width: double.infinity,
              height: 58,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: isNotEnoughWords
                      ? Colors.grey
                      : AppConstants.accentColor,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.buttonRadius,
                    ),
                  ),
                ),
                onPressed: isNotEnoughWords ? null : onPressed,
                child: Text(
                  'quiz_config.start_btn'.tr().toUpperCase(),
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
