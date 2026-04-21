import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/bento_tts_button.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE UI & THEME ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, box, _) {
          // --- ABSOLUTE ZERO-TOUCH DATA LOGIC ---
          final allSavedWords = _wordService.getSavedWords();

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
            padding: const EdgeInsets.all(AppLayout.defaultPadding),
            child: Column(
              children: [
                // SECTION 1: STUDY BANNER
                _buildStudyBanner(context, allSavedWords),
                const SizedBox(height: 16),

                // SECTION 2: SEARCH BAR
                _buildSearchBar(context),
                const SizedBox(height: 24),

                // SECTION 3: SAVED LIST
                if (filteredWords.isEmpty)
                  _buildNoSearchResults(context)
                else
                  ListView.separated(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: filteredWords.length,
                    separatorBuilder: (context, index) =>
                        const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      return _buildSavedWordCard(context, filteredWords[index]);
                    },
                  ),

                const SizedBox(height: 100),
              ],
            ),
          );
        },
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

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
        "Từ vựng đã lưu",
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget _buildStudyBanner(BuildContext context, List<Word> words) {
    return BentoCard(
      bentoColor: AppColors.bentoMint.withValues(alpha: 0.1),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.bentoMint,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.sparkles,
              size: 32,
              color: Colors.white,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Bạn có ${words.length} từ cần ôn tập",
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 12),
                SmartActionButton(
                  text: "Học ngay 🚀",
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

  Widget _buildSearchBar(BuildContext context) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: TextField(
        onChanged: (v) => setState(() => _searchQuery = v),
        style: Theme.of(context).textTheme.bodyLarge,
        decoration: InputDecoration(
          hintText: 'Tìm kiếm từ đã lưu...',
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

  Widget _buildSavedWordCard(BuildContext context, Word word) {
    return BentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.wordDetail,
        arguments: {'word': word},
      ),
      child: Row(
        children: [
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
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              BentoTtsButton(text: word.word),
              IconButton(
                icon: const Icon(
                  CupertinoIcons.heart_fill,
                  color: AppColors.error,
                  size: 24,
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
        child: BentoCard(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: AppColors.bentoPink.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.heart_slash,
                  size: 64,
                  color: AppColors.bentoPink,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "Chưa có từ vựng nào",
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Hãy lưu lại những từ vựng quan trọng để ôn tập chúng sau nhé!",
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SmartActionButton(
                text: "Khám phá từ mới 📚",
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

  Widget _buildNoSearchResults(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Text(
        "Không tìm thấy từ '$_searchQuery'",
        style: Theme.of(context).textTheme.bodyLarge,
      ),
    );
  }
}
