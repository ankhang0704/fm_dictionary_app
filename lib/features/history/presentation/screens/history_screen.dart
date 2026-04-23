import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE UI & THEME ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, box, _) {
          // --- STRICTLY PRESERVED DATA LOGIC ---
          final historyWords = _wordService.getHistoryWords();

          if (historyWords.isEmpty) {
            return _buildEmptyState(context);
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.fromLTRB(
              AppLayout.defaultPadding,
              AppLayout.defaultPadding,
              AppLayout.defaultPadding,
              100,
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
        "history.title".tr(), // INJECTED
        style: Theme.of(context).textTheme.displaySmall,
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
                  color: AppColors.bentoPurple.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.clock_fill,
                  size: 64,
                  color: AppColors.bentoPurple,
                ),
              ),
              const SizedBox(height: 24),
              Text(
                "history.empty_title".tr(), // INJECTED
                style: Theme.of(context).textTheme.displaySmall,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),
              Text(
                "history.empty_desc".tr(), // INJECTED
                style: Theme.of(context).textTheme.bodyMedium,
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 32),
   SmartActionButton(
                text: "history.explore_btn"
                    .tr(), // [PRESERVED] Logic localization
                icon:
                    Icons.explore_rounded, // [NEW] Icon la bàn khám phá rực rỡ
                color: const Color(
                  0xFF3B82F6,
                ), // [NEW] Vibrant Blue (Màu xanh năng động)
                textColor: Colors.white,
                onPressed: () => Navigator.pushReplacementNamed(
                  context,
                  AppRoutes.dashboard, // [PRESERVED] Logic navigation
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHistoryItem(BuildContext context, Word word) {
    // Determine icon based on topic using existing mapping (Logic Preserved)
    final IconData topicIcon =
        AppConstants.topicIcons[word.topic] ?? CupertinoIcons.book_fill;

    return BentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.wordDetail,
        arguments: {'word': word},
      ),
      child: Row(
        children: [
          // LEFT: Activity/Topic Indicator (Vibrant Bento Style)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bentoBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.doc_text_fill,
              color: AppColors.bentoBlue,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),

          // CENTER: Word Info (Zero Overflow policy)
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
                Row(
                  children: [
                    Icon(topicIcon, size: 14, color: AppColors.bentoPurple),
                    const SizedBox(width: 6),
                    Expanded(
                      child: Text(
                        word.topic,
                        style: Theme.of(context).textTheme.bodyMedium,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // RIGHT: Simple Activity Indicator (Learned checkmark)
          const Icon(
            CupertinoIcons.checkmark_seal_fill,
            color: AppColors.success,
            size: 24,
          ),
        ],
      ),
    );
  }
}
