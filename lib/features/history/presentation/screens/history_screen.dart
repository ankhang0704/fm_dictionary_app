import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE UI & THEME ---
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

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final WordService _wordService = WordService();

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
          valueListenable: Hive.box(
            DatabaseService.progressBoxName,
          ).listenable(),
          builder: (context, box, _) {
            // MAPPING LEGACY DATA LOGIC
            final historyWords = _wordService.getHistoryWords();

            if (historyWords.isEmpty) {
              return _buildEmptyState(context);
            }

            return ListView.separated(
              physics: const BouncingScrollPhysics(),
              padding: EdgeInsets.fromLTRB(
                AppLayout.defaultPadding,
                AppLayout.defaultPadding,
                AppLayout.defaultPadding,
                100, // Clearance for bottom navigation if applicable
              ),
              itemCount: historyWords.length,
              separatorBuilder: (context, index) => const SizedBox(height: 12),
              itemBuilder: (context, index) {
                final word = historyWords[index];
                return _buildHistoryItem(context, word);
              },
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
              "Lịch sử học",
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            // Note: Add trash icon here if clear all logic is implemented in WordService
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.white.withValues(alpha:0.2), height: 1),
            ),
          ),
        ),
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
                CupertinoIcons.clock_fill,
                size: 64,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: 24),
              Text(
                "Chưa có hoạt động nào",
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "Hãy bắt đầu hành trình chinh phục từ vựng ngay hôm nay!",
                style: AppTypography.bodyMedium.copyWith(
                  color: AppColors.textSecondary,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
              SmartActionButton(
                text: "Khám phá ngay",
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

  Widget _buildHistoryItem(BuildContext context, Word word) {
    // Determine icon based on topic using existing mapping
    final IconData topicIcon =
        AppConstants.topicIcons[word.topic] ?? CupertinoIcons.book_fill;

    return GlassBentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.wordDetail,
        arguments: {'word': word},
      ),
      child: Row(
        children: [
          // LEFT: Activity/Topic Indicator
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.meshBlue.withValues(alpha:0.2),
              shape: BoxShape.circle,
            ),
            child: Icon(topicIcon, color: AppColors.meshBlue, size: 24),
          ),
          const SizedBox(width: 16),

          // CENTER: Word Info (Zero Overflow policy)
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
                  word.topic,
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),

          // RIGHT: Simple Activity Indicator (Learned checkmark)
          const Icon(
            CupertinoIcons.checkmark_seal_fill,
            color: AppColors.success,
            size: 20,
          ),
        ],
      ),
    );
  }
}
