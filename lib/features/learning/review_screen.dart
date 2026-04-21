import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:provider/provider.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/progress_keys.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, box, _) {
          // --- STRICTLY PRESERVED BUSINESS LOGIC ---
          final reviewWords = _wordService.getWordsToReview();

          if (reviewWords.isEmpty) return const _EmptyReviewState();

          return Stack(
            children: [
              // THE SCROLLABLE LIST
              _buildReviewList(reviewWords),

              // FIXED BENTO BOTTOM ACTION BAR
              _buildStickyBottomAction(context, reviewWords),
            ],
          );
        },
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
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
        'Ôn tập từ vựng',
        style: Theme.of(context).textTheme.displaySmall,
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
        160, // Clearance for fixed bottom bar
      ),
      itemCount: reviewWords.length,
      separatorBuilder: (_, _) => const SizedBox(height: 12),
      itemBuilder: (context, index) {
        final word = reviewWords[index];
        final progress = _wordService.getWordProgress(word.id);
        final int wrongCount = progress[ProgressKeys.wrongCount] as int;
        final bool isUrgent = wrongCount > 0;

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

              // URGENCY INDICATOR (VIBRANT BENTO STYLE)
              if (isUrgent)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.error.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
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
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.error,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                )
              else
                const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: AppColors.success,
                  size: 28,
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
      child: Container(
        padding: EdgeInsets.fromLTRB(
          AppLayout.defaultPadding,
          24,
          AppLayout.defaultPadding,
          MediaQuery.of(context).padding.bottom + 24,
        ),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppLayout.bentoBorderRadius),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: Row(
          children: [
            Expanded(
              child: SmartActionButton(
                text: "Làm Quiz",
                // Passing a specific color can make it look like the "glass" variant but flat
                onPressed: () => Navigator.pushNamed(
                  context,
                  AppRoutes.quizConfig,
                  arguments: 'Review',
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: SmartActionButton(
                text: "Học Lại",
                onPressed: () {
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
    );
  }
}

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
            Container(
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.15),
                shape: BoxShape.circle,
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
              style: Theme.of(context).textTheme.displayMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Text(
              "Bạn đã hoàn thành tất cả các từ cần ôn tập cho hôm nay. Hãy tiếp tục duy trì phong độ này nhé!",
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 40),
            SmartActionButton(
              text: "Quay về Trang chủ",
              onPressed: () =>
                  Navigator.pushReplacementNamed(context, AppRoutes.dashboard),
            ),
          ],
        ),
      ),
    );
  }
}
