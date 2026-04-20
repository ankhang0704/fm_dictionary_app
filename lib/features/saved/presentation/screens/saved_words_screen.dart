import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE UI & THEME ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';

class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  final WordService _wordService = WordService();
  String _searchQuery = "";

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
        appBar: _buildGlassHeader(context),
        body: ValueListenableBuilder(
          valueListenable: Hive.box(DatabaseService.saveBoxName).listenable(),
          builder: (context, box, _) {
            // --- DATA LOGIC EXTRACTION ---
            final allSavedWords = _wordService.getSavedWords();

            // Search Filtering
            final filteredWords = allSavedWords
                .where(
                  (word) =>
                      word.word.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ) ||
                      word.meaning.toLowerCase().contains(
                        _searchQuery.toLowerCase(),
                      ),
                )
                .toList();

            if (allSavedWords.isEmpty) {
              return _buildEmptyState(context);
            }

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.all(AppLayout.defaultPadding),
              child: Column(
                children: [
                  // SECTION 1: STUDY BANNER
                  _buildStudyBanner(allSavedWords),
                  const SizedBox(height: 16),

                  // SECTION 2: SEARCH BAR
                  _buildSearchBar(),
                  const SizedBox(height: 24),

                  // SECTION 3: SAVED LIST
                  if (filteredWords.isEmpty)
                    _buildNoSearchResults()
                  else
                    ListView.separated(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: filteredWords.length,
                      separatorBuilder: (context, index) =>
                          const SizedBox(height: 12),
                      itemBuilder: (context, index) {
                        return _buildSavedWordCard(filteredWords[index]);
                      },
                    ),

                  const SizedBox(height: 100), // Space for bottom nav
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:0.1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Từ vựng đã lưu",
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.white.withValues(alpha:0.2), height: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStudyBanner(List<Word> words) {
    return GlassBentoCard(
      onTap: null,
      child: Row(
        children: [
          const Icon(
            CupertinoIcons.sparkles,
            size: 40,
            color: AppColors.meshMint,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bạn có ${words.length} từ cần ôn tập",
                  style: AppTypography.bodyLarge.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 8),
                SmartActionButton(
                  text: "Học ngay 🚀",
                  isGlass: false,
                  onPressed: () {
                    Navigator.pushNamed(
                      context,
                      AppRoutes.study,
                      arguments: {'words': words},
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
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
            hintText: 'Tìm kiếm từ đã lưu...',
            hintStyle: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
            prefixIcon: const Icon(
              CupertinoIcons.search,
              color: AppColors.textSecondary,
            ),
            filled: true,
            fillColor: Colors.white.withValues(alpha:0.15),
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

  Widget _buildSavedWordCard(Word word) {
    return GlassBentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.wordDetail,
        arguments: {'word': word},
      ),
      child: Row(
        children: [
          // WORD INFO (ZERO OVERFLOW POLICY)
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

          // ACTION BUTTONS
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              // TTS Speaker
              IconButton(
                icon: const Icon(
                  CupertinoIcons.speaker_2_fill,
                  color: AppColors.textPrimary,
                  size: 20,
                ),
                onPressed: () {
                  // TODO: Add TTS Logic call
                },
              ),
              // Unsave Button
              IconButton(
                icon: const Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColors.error,
                  size: 22,
                ),
                onPressed: () => _wordService.toggleSaveWord(word.id),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(AppLayout.defaultPadding * 2),
        child: GlassBentoCard(
          onTap: null,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(
                CupertinoIcons.heart_slash,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                "Chưa có từ vựng nào",
                style: AppTypography.heading3,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Hãy lưu lại những từ vựng quan trọng để ôn tập chúng sau nhé!",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SmartActionButton(
                text: "Khám phá từ mới 📚",
                isGlass: false,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.dashboard,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildNoSearchResults() {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Text(
        "Không tìm thấy từ '$_searchQuery'",
        style: AppTypography.bodyLarge.copyWith(color: AppColors.textSecondary),
      ),
    );
  }
}
