// file: lib/screens/learning/quiz_configuration_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/word_model.dart';
import '../../services/database/word_service.dart';
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final topics = ['All', 'Review', ..._wordService.getAllTopics()];
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
            fontSize: 22,
            fontStyle: FontStyle.normal,
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
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppConstants.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _SectionTitle(title: 'quiz_config.select_topic'.tr()),
                    const SizedBox(height: 12),
                    _TopicSelector(
                      topics: topics,
                      selectedTopic: _selectedTopic,
                      onChanged: (val) {
                        setState(() {
                          _selectedTopic = val;
                          _updateWordsPool();
                        });
                      },
                    ),
                    const SizedBox(height: 32),

                    _SectionTitle(title: 'quiz_config.select_count'.tr()),
                    const SizedBox(height: 12),
                    if (isNotEnoughWords)
                      _NotEnoughWordsWarning(maxWords: maxWords)
                    else
                      _CountSelector(
                        maxWords: maxWords,
                        selectedCount: _questionCount,
                        onChanged: (val) =>
                            setState(() => _questionCount = val),
                      ),
                    const SizedBox(height: 32),

                    _SectionTitle(title: 'quiz_config.select_mode'.tr()),
                    const SizedBox(height: 12),
                    _ModeSelector(
                      selectedMode: _selectedMode,
                      onChanged: (val) => setState(() => _selectedMode = val),
                    ),
                    const SizedBox(height: 32),
                  ],
                ),
              ),
            ),
            _StartButton(
              isNotEnoughWords: isNotEnoughWords,
              onPressed: _startQuiz,
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Text(
      title,
      style: AppConstants.bodyStyle.copyWith(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white : AppConstants.textPrimary,
      ),
    );
  }
}

class _TopicSelector extends StatelessWidget {
  final List<String> topics;
  final String selectedTopic;
  final ValueChanged<String> onChanged;

  const _TopicSelector({
    required this.topics,
    required this.selectedTopic,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          isExpanded: true,
          value: topics.contains(selectedTopic) ? selectedTopic : 'All',
          icon: const Padding(
            padding: EdgeInsets.only(right: 16.0),
            child: Icon(CupertinoIcons.chevron_down, size: 20),
          ),
          dropdownColor: isDark
              ? AppConstants.darkCardColor
              : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          items: topics.map((t) {
            String displayName = t;
            if (t == 'All') displayName = 'quiz_config.topic_all'.tr();
            if (t == 'Review') displayName = 'quiz_config.topic_review'.tr();

            return DropdownMenuItem(
              value: t,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Text(
                  displayName,
                  style: AppConstants.bodyStyle.copyWith(
                    fontWeight: FontWeight.w500,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
              ),
            );
          }).toList(),
          onChanged: (val) {
            if (val != null) onChanged(val);
          },
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
      spacing: 12,
      runSpacing: 12,
      children: options.map((count) {
        final isSelected = selectedCount == count;
        final label = count == 9999 ? "${'quiz_config.all'.tr()}($maxWords)" : "$count ${'quiz_config.count_suffix'.tr()}";

        return GestureDetector(
          onTap: () => onChanged(count),
          child: AnimatedContainer(
            duration: AppConstants.defaultAnimationDuration,
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            decoration: BoxDecoration(
              color: isSelected ? AppConstants.accentColor : Colors.transparent,
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
              border: Border.all(
                color: isSelected
                    ? AppConstants.accentColor
                    : Colors.grey.withValues(alpha: 0.3),
              ),
            ),
            child: Text(
              label,
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 14,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
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
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppConstants.accentColor.withValues(alpha: 0.1)
              : (isDark ? AppConstants.darkCardColor : AppConstants.cardColor),
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          border: Border.all(
            color: isSelected ? AppConstants.accentColor : Colors.transparent,
            width: 2,
          ),
          boxShadow: isDark || isSelected
              ? []
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.02),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppConstants.accentColor
                  : AppConstants.textSecondary,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                title,
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                  color: isSelected
                      ? AppConstants.accentColor
                      : (isDark ? Colors.white : AppConstants.textPrimary),
                ),
              ),
            ),
            if (isSelected)
              const Icon(
                CupertinoIcons.checkmark_circle_fill,
                color: AppConstants.accentColor,
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
        color: AppConstants.errorColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        border: Border.all(
          color: AppConstants.errorColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.exclamationmark_triangle,
            color: AppConstants.errorColor,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              'quiz_config.not_enough_words'.tr(args: [maxWords.toString()]),
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.errorColor,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _StartButton extends StatelessWidget {
  final bool isNotEnoughWords;
  final VoidCallback onPressed;

  const _StartButton({required this.isNotEnoughWords, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, -5),
          ),
        ],
      ),
      child: SizedBox(
        width: double.infinity,
        height: 56,
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: isNotEnoughWords
                ? Colors.grey
                : AppConstants.accentColor,
            foregroundColor: Colors.white,
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
            ),
          ),
          onPressed: isNotEnoughWords ? null : onPressed,
          child: Text(
            'quiz_config.start_btn'.tr().toUpperCase(),
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              letterSpacing: 1.2,
            ),
          ),
        ),
      ),
    );
  }
}
