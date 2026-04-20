import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/search/presentation/providers/search_provider.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
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
        body: SafeArea(
          child: Column(
            children: [
              // TOP: Glassmorphism Search Bar & Back Button
              _buildTopBar(context),

              // BODY: Search Results or Empty State
              Expanded(
                child: Consumer<SearchProvider>(
                  builder: (context, provider, _) {
                    if (provider.currentQuery.isEmpty) {
                      return _buildHistoryAndSuggestions(provider);
                    }
                    if (provider.searchResults.isEmpty) {
                      return _buildEmptyInfo();
                    }

                    return _buildSearchResults(provider);
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildTopBar(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      child: Row(
        children: [
          // Glass Back Button
          Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          const SizedBox(width: 12),

          // Prominent Glassmorphism Search Field
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                child: TextField(
                  controller: _controller,
                  autofocus: true,
                  onChanged: (val) =>
                      context.read<SearchProvider>().search(val),
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: 'Tìm kiếm từ vựng...',
                    hintStyle: AppTypography.bodyLarge.copyWith(
                      color: AppColors.textSecondary,
                    ),
                    prefixIcon: const Icon(
                      CupertinoIcons.search,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    suffixIcon: _controller.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(
                              CupertinoIcons.clear_thick_circled,
                              size: 18,
                              color: AppColors.textSecondary,
                            ),
                            onPressed: () {
                              _controller.clear();
                              context.read<SearchProvider>().clearSearch();
                            },
                          )
                        : null,
                    filled: true,
                    fillColor: Colors.white.withValues(alpha:0.15),
                    contentPadding: const EdgeInsets.symmetric(
                      vertical: 14,
                      horizontal: 16,
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppLayout.bentoBorderRadius,
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha:0.3),
                        width: 1,
                      ),
                    ),
                    enabledBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppLayout.bentoBorderRadius,
                      ),
                      borderSide: BorderSide(
                        color: Colors.white.withValues(alpha:0.3),
                        width: 1,
                      ),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(
                        AppLayout.bentoBorderRadius,
                      ),
                      borderSide: const BorderSide(
                        color: AppColors.meshMint,
                        width: 1.5,
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHistoryAndSuggestions(SearchProvider provider) {
    if (provider.history.isEmpty) {
      return Center(
        child: Text(
          "Nhập từ vựng để tìm kiếm...",
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return SingleChildScrollView(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.all(AppLayout.defaultPadding),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Gợi ý & Lịch sử',
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
              GestureDetector(
                onTap: provider.clearHistory,
                child: Text(
                  'Xóa lịch sử',
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.error,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Wrap of Glass Chips
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
                    color: Colors.white.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: Colors.white.withValues(alpha:0.2)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.clock,
                        size: 14,
                        color: AppColors.textSecondary,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        term,
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textPrimary,
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

  Widget _buildSearchResults(SearchProvider provider) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.only(
        left: AppLayout.defaultPadding,
        right: AppLayout.defaultPadding,
        top: 8,
        bottom: 100, // Safe padding for smooth scrolling
      ),
      itemCount: provider.searchResults.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = provider.searchResults[index];
        return GlassBentoCard(
          onTap: () {
            // Dismiss keyboard
            FocusScope.of(context).unfocus();

            // Legacy Logic: Save to search history
            provider.saveToHistory(word.word);

            // Explicit Routing mapped
            Navigator.pushNamed(
              context,
              AppRoutes.wordDetail,
              arguments: {'word': word},
            );
          },
          child: Row(
            children: [
              // ZERO PIXEL OVERFLOW Strategy
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

              // Trailing Glass TTS Button
              Container(
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha:0.15),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(
                    CupertinoIcons.speaker_2_fill,
                    color: AppColors.textPrimary,
                    size: 20,
                  ),
                  onPressed: () {
                    // TODO: Add logic here for direct TTS audio playback
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildEmptyInfo() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(
            CupertinoIcons.search,
            size: 60,
            color: AppColors.textSecondary,
          ),
          const SizedBox(height: 16),
          Text(
            "Không tìm thấy kết quả",
            style: AppTypography.bodyLarge.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}
