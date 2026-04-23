import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/bento_tts_button.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';

class DictionaryDetailScreen extends StatefulWidget {
  final String topic;
  const DictionaryDetailScreen({super.key, required this.topic});

  @override
  State<DictionaryDetailScreen> createState() => _DictionaryDetailScreenState();
}

class _DictionaryDetailScreenState extends State<DictionaryDetailScreen> {
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      // ABSOLUTE LOGIC PRESERVATION: Listen to ProgressBox for reactive updates
      body: ValueListenableBuilder<Box>(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, progressBox, child) {
          // --- STRICTLY PRESERVED DATA LOGIC ---
          final allWords = _wordService.getWordsByTopic(widget.topic);

          final filteredWords = allWords
              .where(
                (w) =>
                    w.word.toLowerCase().contains(_searchQuery.toLowerCase()),
              )
              .toList();

          final learnedCount = allWords
              .where((w) => _wordService.isWordLearned(w.id))
              .length;

          final progress = allWords.isEmpty
              ? 0.0
              : learnedCount / allWords.length;

          // --- VIBRANT BENTO UI CONSTRUCTION ---
          return CustomScrollView(
            controller: _scrollController,
            physics: const BouncingScrollPhysics(),
            slivers: [
              // BENTO APP BAR (Flat & Solid)
              _buildBentoSliverAppBar(context),

              // TOP CONTENT: Hero, Actions, Search
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(AppLayout.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _buildHeroCard(
                        context,
                        learnedCount,
                        allWords.length,
                        progress,
                      ),
                      const SizedBox(height: 16),
                      _buildActionRow(context, allWords),
                      const SizedBox(height: 16),
                      _buildSearchBar(context),
                      const SizedBox(height: 24),
                    ],
                  ),
                ),
              ),

              // WORD LIST
              if (filteredWords.isEmpty)
                SliverFillRemaining(
                  hasScrollBody: false,
                  child: Center(
                    child: Text(
                      'dictionary.no_words_found'.tr(), // INJECTED
                      style: Theme.of(context).textTheme.bodyLarge,
                    ),
                  ),
                )
              else
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppLayout.defaultPadding,
                    right: AppLayout.defaultPadding,
                    bottom: 120,
                  ),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final word = filteredWords[index];
                      final isLearned = _wordService.isWordLearned(word.id);
                      return _buildWordCard(context, word, isLearned);
                    }, childCount: filteredWords.length),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  Widget _buildBentoSliverAppBar(BuildContext context) {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
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
        widget.topic,
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget _buildHeroCard(
    BuildContext context,
    int learnedCount,
    int totalCount,
    double progress,
  ) {
    return BentoCard(
      child: Row(
        children: [
          // LEFT: Icon & Topic Name (Vibrant Circle)
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bentoBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppConstants.topicIcons[widget.topic] ?? CupertinoIcons.book_fill,
              color: AppColors.bentoBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "dictionary.study_progress".tr(), // INJECTED
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 4),
                Text(
                  widget.topic,
                  style: Theme.of(
                    context,
                  ).textTheme.displaySmall?.copyWith(fontSize: 18),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // RIGHT: Circular Progress (Flat Design)
          SizedBox(
            width: 65,
            height: 65,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  strokeCap: StrokeCap.round,
                  backgroundColor: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppColors.success : AppColors.bentoMint,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "dictionary.progress_unit".tr(
                          args: [
                            learnedCount.toString(),
                            totalCount.toString(),
                          ],
                        ), // INJECTED
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: progress == 1.0 ? AppColors.success : null,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // New Vibrant Bento UI block (Logic, Theme, and Localization perfectly preserved!)

  Widget _buildActionRow(BuildContext context, List<Word> allWords) {
    return Row(
      children: [
        // Button 1: Study (Primary Bento Color - Vibrant Blue)
        Expanded(
          child: SmartActionButton(
            text: "dictionary.study_btn".tr(), // INJECTED
            icon: Icons.school_rounded,
            color: const Color(0xFF3B82F6), // Vibrant Bento Blue
            onPressed: () {
              Navigator.pushNamed(
                context,
                AppRoutes.study,
                arguments: {'words': allWords},
              );
            },
          ),
        ),
        const SizedBox(width: 16),

        // Button 2: Quiz (Secondary Bento Color - Playful Orange)
        Expanded(
          child: SmartActionButton(
            text: "dictionary.quiz_btn".tr(), // INJECTED
            icon: Icons.videogame_asset_rounded,
            color: const Color(0xFFF97316), // Vibrant Bento Orange
            onPressed: () {
              if (allWords.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    // Removed const
                    content: Text('quiz.config.error_min_words'.tr()),
                    backgroundColor: AppColors.error,
                  ),
                );
                return;
              }
              Navigator.pushNamed(
                context,
                AppRoutes.quizConfig,
                arguments: widget.topic,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'dictionary.search_hint'.tr(), // INJECTED
          hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
            color: Theme.of(
              context,
            ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
          ),
          prefixIcon: Icon(
            CupertinoIcons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 16,
          ),
        ),
      ),
    );
  }

  Widget _buildWordCard(BuildContext context, Word word, bool isLearned) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: BentoCard(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.wordDetail,
          arguments: {'word': word},
        ),
        child: Row(
          children: [
            // Checkmark if learned (Vibrant Color)
            if (isLearned) ...[
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: AppColors.success,
                size: 28,
              ),
              const SizedBox(width: 12),
            ],

            // Text Content (Zero Overflow)
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    word.word,
                    style: Theme.of(
                      context,
                    ).textTheme.displaySmall?.copyWith(fontSize: 18),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.meaning,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Bento TTS Button (Architectural Component)
            BentoTtsButton(text: word.word),
          ],
        ),
      ),
    );
  }
}
