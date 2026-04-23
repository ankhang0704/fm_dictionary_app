import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/data/models/word_model.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- MODELS / PROVIDERS / SERVICES ---
import '../../../../data/services/database/word_service.dart';
import '../../../../data/services/features/quiz_service.dart';

class QuizConfigurationScreen extends StatefulWidget {
  final String? initialTopic;

  const QuizConfigurationScreen({super.key, this.initialTopic});

  @override
  State<QuizConfigurationScreen> createState() =>
      _QuizConfigurationScreenState();
}

class _QuizConfigurationScreenState extends State<QuizConfigurationScreen> {
  late String _selectedTopic;
  int _selectedCount = 10;
  QuizMode _selectedMode = QuizMode.viToEn;

  final WordService _wordService = WordService();
  final List<int> _questionCounts = [10, 20, 50, -1];

  final List<Map<String, dynamic>> _modes = [
    {
      'mode': QuizMode.enToVi,
      'title': 'quiz.modes.en_vi.title', // Key mapped
      'subtitle': 'quiz.modes.en_vi.subtitle', // Key mapped
      'icon': CupertinoIcons.arrow_right_arrow_left_square,
      'color': AppColors.bentoBlue,
    },
    {
      'mode': QuizMode.viToEn,
      'title': 'quiz.modes.vi_en.title', // Key mapped
      'subtitle': 'quiz.modes.vi_en.subtitle', // Key mapped
      'icon': CupertinoIcons.arrow_left_right_square_fill,
      'color': AppColors.bentoPurple,
    },
    {
      'mode': QuizMode.listening,
      'title': 'quiz.modes.listening.title', // Key mapped
      'subtitle': 'quiz.modes.listening.subtitle', // Key mapped
      'icon': CupertinoIcons.headphones,
      'color': AppColors.bentoMint,
    },
  ];

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.initialTopic ?? 'All';
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(AppLayout.defaultPadding),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    _buildSectionTitle(
                      context,
                      "quiz.config.topic_section".tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildTopicSelectionCard(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      context,
                      "quiz.config.count_section".tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildQuestionCountSection(),
                    const SizedBox(height: 24),

                    _buildSectionTitle(
                      context,
                      "quiz.config.mode_section".tr(),
                    ),
                    const SizedBox(height: 12),
                    _buildModeSelectionSection(),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ),
            _buildBottomAction(),
          ],
        ),
      ),
    );
  }

  PreferredSizeWidget _buildBentoHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        "quiz.config.title".tr(),
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Text(
      title,
      style: Theme.of(context).textTheme.displaySmall?.copyWith(fontSize: 18),
    );
  }

  Widget _buildTopicSelectionCard() {
    return BentoCard(
      onTap: _showTopicPickerBottomSheet,
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bentoPurple.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppConstants.topicIcons[_selectedTopic] ??
                  CupertinoIcons.book_fill,
              color: AppColors.bentoPurple,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "quiz.config.selecting".tr(),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  _selectedTopic == 'All'
                      ? "quiz.config.all_topics".tr()
                      : _selectedTopic,
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(fontSize: 18),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const Icon(CupertinoIcons.chevron_down, size: 20),
        ],
      ),
    );
  }

  Widget _buildQuestionCountSection() {
    return Wrap(
      spacing: 12,
      runSpacing: 12,
      children: _questionCounts.map((count) {
        final bool isSelected = _selectedCount == count;
        final String label = count == -1
            ? "common.all".tr()
            : "quiz.config.question_unit".tr(args: [count.toString()]);

        return GestureDetector(
          onTap: () => setState(() => _selectedCount = count),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width:
                (MediaQuery.of(context).size.width -
                    (AppLayout.defaultPadding * 2) -
                    36) /
                4,
            decoration: BoxDecoration(
              color: isSelected
                  ? AppColors.bentoBlue.withValues(alpha: 0.15)
                  : Theme.of(context).colorScheme.surface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected
                    ? AppColors.bentoBlue
                    : Theme.of(context).dividerColor.withValues(alpha: 0.1),
                width: 2,
              ),
            ),
            padding: const EdgeInsets.symmetric(vertical: 16),
            alignment: Alignment.center,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                color: isSelected ? AppColors.bentoBlue : null,
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildModeSelectionSection() {
    return Column(
      children: _modes.map((modeData) {
        final mode = modeData['mode'] as QuizMode;
        final bool isSelected = _selectedMode == mode;
        final Color modeColor = modeData['color'] as Color;

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: BentoCard(
            onTap: () => setState(() => _selectedMode = mode),
            bentoColor: isSelected ? modeColor.withValues(alpha: 0.08) : null,
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: modeColor.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    modeData['icon'] as IconData,
                    color: modeColor,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        (modeData['title'] as String).tr(),
                        style: Theme.of(
                          context,
                        ).textTheme.displaySmall?.copyWith(fontSize: 18),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        (modeData['subtitle'] as String).tr(),
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ],
                  ),
                ),
                if (isSelected)
                  Icon(CupertinoIcons.checkmark_circle_fill, color: modeColor),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildBottomAction() {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.defaultPadding),
      child: SmartActionButton(
        text: 'quiz.config.start_journey'.tr(),
        icon: Icons.rocket_launch_rounded,
        color: const Color(0xFF6366F1),
        textColor: Colors.white,
        onPressed: () {
          List words = _selectedTopic == 'All'
              ? _wordService.getAllWords()
              : _wordService.getWordsByTopic(_selectedTopic);

          if (words.length < 4) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                // Removed const
                content: Text('quiz.config.error_min_words'.tr()),
                backgroundColor: AppColors.error,
              ),
            );
            return;
          }

          words.shuffle();
          if (_selectedCount != -1 && words.length > _selectedCount) {
            words = words.sublist(0, _selectedCount);
          }

          context.read<QuizProvider>().initQuiz(
            words.cast<Word>(),
            _selectedMode,
            isFromRoadmap: false,
          );

          Navigator.pushNamed(context, AppRoutes.quiz);
        },
      ),
    );
  }

  void _showTopicPickerBottomSheet() {
    final allWords = _wordService.getAllWords();
    final Set<String> topicSet = {'All'};
    for (var w in allWords) {
      topicSet.add(w.topic);
    }
    final topics = topicSet.toList();

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => Container(
        height: MediaQuery.of(context).size.height * 0.6,
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppLayout.bentoBorderRadius),
          ),
        ),
        child: Column(
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              "quiz.config.choose_topic".tr(),
              style: Theme.of(context).textTheme.displaySmall,
            ),
            const SizedBox(height: 16),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: topics.length,
                separatorBuilder: (_, _) => const SizedBox(height: 8),
                itemBuilder: (context, index) {
                  final topic = topics[index];
                  final isSelected = _selectedTopic == topic;

                  return BentoCard(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 8,
                    ),
                    onTap: () {
                      setState(() => _selectedTopic = topic);
                      Navigator.pop(context);
                    },
                    bentoColor: isSelected
                        ? AppColors.bentoMint.withValues(alpha: 0.1)
                        : null,
                    child: Row(
                      children: [
                        Icon(
                          AppConstants.topicIcons[topic] ??
                              CupertinoIcons.book_fill,
                          color: isSelected ? AppColors.bentoMint : null,
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: Text(
                            topic == 'All'
                                ? 'quiz.config.all_topics'.tr()
                                : topic,
                            style: Theme.of(context).textTheme.bodyLarge
                                ?.copyWith(
                                  fontWeight: isSelected
                                      ? FontWeight.bold
                                      : null,
                                ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            CupertinoIcons.checkmark_alt,
                            color: AppColors.bentoMint,
                          ),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
