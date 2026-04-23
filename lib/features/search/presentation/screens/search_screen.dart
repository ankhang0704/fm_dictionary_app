import 'package:easy_localization/easy_localization.dart'; // IMPORTED
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/bento_tts_button.dart';
import 'package:fm_dictionary/features/search/presentation/providers/search_provider.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // TOP: Bento Search Bar & Back Button
            _buildTopBar(context),

            // BODY: Search Results or Empty State
            Expanded(
              child: Consumer<SearchProvider>(
                builder: (context, provider, _) {
                  if (provider.currentQuery.isEmpty) {
                    return _buildHistoryAndSuggestions(context, provider);
                  }
                  if (provider.searchResults.isEmpty) {
                    return _buildEmptyInfo(context);
                  }

                  return _buildSearchResults(context, provider);
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(AppLayout.defaultPadding),
      child: Row(
        children: [
          // Bento Back Button
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                CupertinoIcons.back,
                color: Theme.of(context).textTheme.displayLarge?.color,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),

          // Solid Bento Search Field
          Expanded(
            child: BentoCard(
              padding: EdgeInsets.zero,
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: (val) => context.read<SearchProvider>().search(val),
                style: Theme.of(context).textTheme.bodyLarge,
                decoration: InputDecoration(
                  hintText: 'search.hint'.tr(), // INJECTED
                  hintStyle: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
                  ),
                  prefixIcon: Icon(
                    CupertinoIcons.search,
                    size: 20,
                    color: Theme.of(context).colorScheme.primary,
                  ),
                  suffixIcon: _controller.text.isNotEmpty
                      ? IconButton(
                          icon: Icon(
                            CupertinoIcons.clear_thick_circled,
                            size: 18,
                            color: Theme.of(context).dividerColor,
                          ),
                          onPressed: () {
                            _controller.clear();
                            context.read<SearchProvider>().clearSearch();
                          },
                        )
                      : null,
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 16,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryAndSuggestions(
    BuildContext context,
    SearchProvider provider,
  ) {
    if (provider.history.isEmpty) {
      return Center(
        child: Text(
          'search.initial_prompt'.tr(), // INJECTED
          style: Theme.of(context).textTheme.bodyLarge,
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.all(AppLayout.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'search.history'.tr(), // INJECTED
                style: Theme.of(context).textTheme.displaySmall,
              ),
              GestureDetector(
                onTap: provider.clearHistory,
                child: Text(
                  'search.clear_history'.tr(), // INJECTED
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Wrap of Vibrant Bento Chips
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: provider.history.map((term) {
              return GestureDetector(
                onTap: () {
                  _controller.text = term;
                  provider.search(term);
                },
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.1),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: Theme.of(context).colorScheme.primary,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        term,
                        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ],
      ),
    );
  }

  Widget _buildSearchResults(BuildContext context, SearchProvider provider) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: const EdgeInsets.only(
        left: AppLayout.defaultPadding,
        right: AppLayout.defaultPadding,
        top: 8,
        bottom: 100,
      ),
      itemCount: provider.searchResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = provider.searchResults[index];
        return BentoCard(
          onTap: () {
            FocusScope.of(context).unfocus();
            provider.saveToHistory(word.word);
            Navigator.pushNamed(
              context,
              AppRoutes.wordDetail,
              arguments: {'word': word},
            );
          },
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

              // Trailing Bento TTS Button
              BentoTtsButton(text: word.word),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyInfo(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.search,
              size: 60,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.3),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'search.no_results_simple'.tr(), // INJECTED
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ],
      ),
    );
  }
}
