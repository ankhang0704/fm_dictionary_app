import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/progress_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- MODELS / PROVIDERS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';

class SmartReviewScreen extends StatefulWidget {
  const SmartReviewScreen({super.key});

  @override
  State<SmartReviewScreen> createState() => _SmartReviewScreenState();
}

class _SmartReviewScreenState extends State<SmartReviewScreen> {
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
            // --- LEGACY LOGIC EXTRACTION ---
            final reviewWords = _wordService.getWordsToReview();

            if (reviewWords.isEmpty) return const _EmptyReviewState();

            return Stack(
              children: [
                // THE SCROLLABLE LIST
                _buildReviewList(reviewWords),

                // FIXED GLASS BOTTOM ACTION BAR
                _buildStickyBottomAction(context, reviewWords),
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

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:  0.1),
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
              'Ôn tập từ vựng',
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

  Widget _buildReviewList(List<Word> reviewWords) {
    return ListView.separated(
      physics: const BouncingScrollPhysics(),
      padding: EdgeInsets.fromLTRB(
        AppLayout.defaultPadding,
        AppLayout.defaultPadding,
        AppLayout.defaultPadding,
        140, // Significant bottom padding for the fixed action bar
      ),
      itemCount: reviewWords.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = reviewWords[index];
        final progress = _wordService.getWordProgress(word.id);
        final int wrongCount = progress[ProgressKeys.wrongCount] as int;

        // VISUAL FEEDBACK: If errors exist, add a subtle red tint to the card
        final isUrgent = wrongCount > 0;

        return GlassBentoCard(
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

              // URGENCY INDICATOR
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha:0.15),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.error.withValues(alpha:0.3)),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        CupertinoIcons.exclamationmark_triangle_fill,
                        size: 14,
                        color: AppColors.error,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        '$wrongCount lỗi',
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: AppColors.success,
                  size: 24,
                ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildStickyBottomAction(
    BuildContext context,
    List<Word> reviewWords,
  ) {
    return Positioned(
      bottom: 0,
      left: 0,
      right: 0,
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: EdgeInsets.fromLTRB(
              AppLayout.defaultPadding,
              16,
              AppLayout.defaultPadding,
              MediaQuery.of(context).padding.bottom + 16,
            ),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha:0.2), width: 1),
              ),
            ),
            child: Row(
              children: [
                // ACTION 1: QUIZ (Glass Variant)
                Expanded(
                  child: SmartActionButton(
                    text: "Làm Quiz",
                    isGlass: true,
                    isLoading: false,
                    onPressed: () => Navigator.pushNamed(
                      context,
                      AppRoutes.quizConfig,
                      arguments: 'Review',
                    ),
                  ),
                ),
                const SizedBox(width: 16),

                // ACTION 2: STUDY (Solid Variant)
                Expanded(
                  child: SmartActionButton(
                    text: "Học Lại",
                    isGlass: false,
                    isLoading: false,
                    onPressed: () {
                      // Legacy logic: Fetching words via HomeProvider for the 'Review' virtual topic
                      final words = context
                          .read<HomeProvider>()
                          .getWordsByTopicName('Review');
                      Navigator.pushNamed(
                        context,
                        AppRoutes.study,
                        arguments: {'words': words},
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ===========================================================================
// EMPTY STATE (BENTO STYLE)
// ===========================================================================

class _EmptyReviewState extends StatelessWidget {
  const _EmptyReviewState();

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hero Icon Container
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha:0.15),
                shape: BoxShape.circle,
                border: Border.all(
                  color: AppColors.success.withValues(alpha:0.3),
                  width: 2,
                ),
              ),
              child: const Icon(
                CupertinoIcons.checkmark_seal_fill,
                size: 80,
                color: AppColors.success,
              ),
            ),
            const SizedBox(height: 32),

            Text(
              "Tuyệt vời!",
              style: AppTypography.heading1.copyWith(
                color: AppColors.textPrimary,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),

            Text(
              "Bạn đã hoàn thành tất cả các từ cần ôn tập cho hôm nay. Hãy tiếp tục duy trì phong độ này nhé!",
              textAlign: TextAlign.center,
              style: AppTypography.bodyLarge.copyWith(
                color: AppColors.textSecondary,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 40),

            // Encouraging Action
            SmartActionButton(
              text: "Quay về Trang chủ",
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
              isGlass: true,
            ),
          ],
        ),
      ),
    );
  }
}
