import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/glass_tts_button.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.meshBlue,
            AppColors.meshPurple,
            AppColors.meshMint,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        // Listen to ProgressBox to instantly update checkmarks and progress circle
        body: ValueListenableBuilder<Box>(
          valueListenable: Hive.box(
            DatabaseService.progressBoxName,
          ).listenable(),
          builder: (context, progressBox, child) {
            // --- 1. LEGACY STATE EXTRACTION ---
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

            // --- 2. UI CONSTRUCTION ---
            return CustomScrollView(
              controller: _scrollController,
              physics: const BouncingScrollPhysics(),
              slivers: [
                // GLASS HEADER
                _buildGlassSliverAppBar(),

                // TOP CONTENT: Hero, Actions, Search
                SliverToBoxAdapter(
                  child: Padding(
                    padding: EdgeInsets.all(AppLayout.defaultPadding),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildHeroCard(learnedCount, allWords.length, progress),
                        const SizedBox(height: 16),
                        _buildActionRow(allWords),
                        const SizedBox(height: 16),
                        _buildSearchBar(),
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
                        'Không tìm thấy từ vựng nào.',
                        style: AppTypography.bodyLarge.copyWith(
                          color: AppColors.textSecondary,
                        ),
                      ),
                    ),
                  )
                else
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: AppLayout.defaultPadding,
                      right: AppLayout.defaultPadding,
                      bottom: 120, // Avoid bottom nav overlap if any
                    ),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate((context, index) {
                        final word = filteredWords[index];
                        final isLearned = _wordService.isWordLearned(word.id);
                        return _buildWordCard(word, isLearned);
                      }, childCount: filteredWords.length),
                    ),
                  ),
              ],
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildGlassSliverAppBar() {
    return SliverAppBar(
      pinned: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      leading: IconButton(
        icon: const Icon(CupertinoIcons.back, color: AppColors.textPrimary),
        onPressed: () => Navigator.pop(context),
      ),
      flexibleSpace: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: FlexibleSpaceBar(
            centerTitle: true,
            title: Text(
              widget.topic,
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            background: Container(
              // Border line to define the glass edge
              decoration: BoxDecoration(
                border: Border(
                  bottom: BorderSide(
                    color: Colors.white.withValues(alpha:0.2),
                    width: 1,
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard(int learnedCount, int totalCount, double progress) {
    return GlassBentoCard(
      onTap: null,
      child: Row(
        children: [
          // LEFT: Icon & Topic Name
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.meshBlue.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(
              AppConstants.topicIcons[widget.topic] ?? CupertinoIcons.book_fill,
              color: AppColors.meshBlue,
              size: 32,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Tiến độ học",
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
                const SizedBox(height: 4),
                // ZERO OVERFLOW
                Text(
                  widget.topic,
                  style: AppTypography.heading2.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
          const SizedBox(width: 16),

          // RIGHT: Circular Progress with fraction
          SizedBox(
            width: 65,
            height: 65,
            child: Stack(
              fit: StackFit.expand,
              children: [
                CircularProgressIndicator(
                  value: progress,
                  strokeWidth: 6,
                  backgroundColor: Colors.white.withValues(alpha:0.15),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppColors.success : AppColors.meshMint,
                  ),
                ),
                Center(
                  child: Padding(
                    padding: const EdgeInsets.all(12.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(
                        "$learnedCount/$totalCount",
                        style: AppTypography.heading3.copyWith(
                          color: progress == 1.0
                              ? AppColors.success
                              : AppColors.textPrimary,
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

  Widget _buildActionRow(List<Word> allWords) {
    return Row(
      children: [
        // Button 1: Study (Glassy Look)
        Expanded(
          child: SmartActionButton(
            text: "Học",
            isGlass: true, // Use glass style for secondary/study action
            isLoading: false,
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

        // Button 2: Quiz (Solid/Vibrant Look)
        Expanded(
          child: SmartActionButton(
            text: "Kiểm tra",
            isGlass: false, // Use solid prominent color for the Quiz challenge
            isLoading: false,
            onPressed: () {
              // Legacy constraint check
              if (allWords.length < 4) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(
                      'Cần ít nhất 4 từ để tạo bài kiểm tra! (Hiện có: ${allWords.length})',
                    ),
                    backgroundColor: AppColors.error,
                    behavior: SnackBarBehavior.floating,
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

  Widget _buildSearchBar() {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: TextField(
          onChanged: (v) => setState(() => _searchQuery = v),
          style: AppTypography.bodyLarge.copyWith(color: AppColors.textPrimary),
          decoration: InputDecoration(
            hintText: 'Tìm kiếm từ vựng...',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha:0.15),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 20,
              vertical: 16,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha:0.3),
                width: 1,
              ),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
              borderSide: BorderSide(
                color: Colors.white.withValues(alpha:0.3),
                width: 1,
              ),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
              borderSide: const BorderSide(
                color: AppColors.meshMint,
                width: 1.5,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildWordCard(Word word, bool isLearned) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12.0),
      child: GlassBentoCard(
        onTap: () => Navigator.pushNamed(
          context,
          AppRoutes.wordDetail,
          arguments: {'word': word},
        ),
        child: Row(
          children: [
            // Checkmark if learned
            if (isLearned) ...[
              const Icon(
                CupertinoIcons.checkmark_seal_fill,
                color: AppColors.success,
                size: 24,
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
                    style: AppTypography.heading3.copyWith(
                      color: AppColors.textPrimary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    word.meaning,
                    style: AppTypography.bodyMedium.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),

            // Right TTS Glass Button
            Container(
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.15),
                shape: BoxShape.circle,
              ),
              child: GlassTtsButton(text: word.word),
            ),
          ],
        ),
      ),
    );
  }
}
