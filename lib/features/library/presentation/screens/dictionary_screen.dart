import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/progress_keys.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        bottom: false,
        child: ValueListenableBuilder<Box<Word>>(
          valueListenable: Hive.box<Word>(
            DatabaseService.wordBoxName,
          ).listenable(),
          builder: (context, wordBox, child) {
            // --- STRICTLY PRESERVED BUSINESS LOGIC ---
            final Map<String, int> topicTotalCount = {};
            final Map<String, int> topicLearnedCount = {};

            for (var word in wordBox.values) {
              topicTotalCount[word.topic] =
                  (topicTotalCount[word.topic] ?? 0) + 1;
              final progressBox = Hive.box(DatabaseService.progressBoxName);
              final raw = progressBox.get(word.id);
              if (raw is Map) {
                final step = (raw[ProgressKeys.step] ?? 0) as int;
                if (step >= 4) {
                  topicLearnedCount[word.topic] =
                      (topicLearnedCount[word.topic] ?? 0) + 1;
                }
              }
            }

            final topics = topicTotalCount.keys.toList()..sort();
            final int totalTopics = topics.length;

            int masteredTopics = 0;
            for (var topic in topics) {
              if (topicTotalCount[topic]! > 0 &&
                  topicTotalCount[topic] == (topicLearnedCount[topic] ?? 0)) {
                masteredTopics++;
              }
            }

            final double overallProgress = totalTopics == 0
                ? 0.0
                : (masteredTopics / totalTopics).clamp(0.0, 1.0);

            // --- VIBRANT BENTO UI CONSTRUCTION ---
            return CustomScrollView(
              physics: const BouncingScrollPhysics(),
              slivers: [
                // --- TOP SECTION (Search Bar & Overall Progress) ---
                SliverPadding(
                  padding: const EdgeInsets.all(AppLayout.defaultPadding),
                  sliver: SliverList(
                    delegate: SliverChildListDelegate([
                      _buildHeader(context),
                      const SizedBox(height: 24),
                      _buildSearchBar(context),
                      const SizedBox(height: 16),
                      _buildOverallProgressCard(
                        context,
                        masteredTopics,
                        totalTopics,
                        overallProgress,
                      ),
                    ]),
                  ),
                ),

                // --- TOPIC GRID (Bento Cards) ---
                SliverPadding(
                  padding: const EdgeInsets.only(
                    left: AppLayout.defaultPadding,
                    right: AppLayout.defaultPadding,
                    bottom: 140, // Extra padding for navigation clearance
                  ),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          crossAxisSpacing: 16,
                          mainAxisSpacing: 16,
                          childAspectRatio: 0.9,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final topic = topics[index];
                      final totalWords = topicTotalCount[topic] ?? 0;
                      final learnedWords = topicLearnedCount[topic] ?? 0;
                      final double topicProgress = totalWords == 0
                          ? 0.0
                          : (learnedWords / totalWords).clamp(0.0, 1.0);

                      return _buildTopicCard(
                        context,
                        topic,
                        totalWords,
                        learnedWords,
                        topicProgress,
                      );
                    }, childCount: topics.length),
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

  Widget _buildHeader(BuildContext context) {
    return Text('Kho Từ Điển', style: Theme.of(context).textTheme.displayLarge);
  }

  Widget _buildSearchBar(BuildContext context) {
    return BentoCard(
      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Row(
        children: [
          Icon(
            CupertinoIcons.search,
            color: Theme.of(context).colorScheme.primary,
          ),
          const SizedBox(width: 12),
          Text(
            "Tìm kiếm từ vựng...",
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              color: Theme.of(
                context,
              ).textTheme.bodyLarge?.color?.withValues(alpha: 0.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverallProgressCard(
    BuildContext context,
    int mastered,
    int total,
    double progress,
  ) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.checkmark_seal_fill,
                  color: AppColors.success,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      "Mức độ thông thạo",
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Hoàn thành $mastered/$total Chủ đề",
                      style: Theme.of(context).textTheme.displaySmall,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 10,
              backgroundColor: AppColors.success.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.success,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(
    BuildContext context,
    String topic,
    int totalWords,
    int learnedWords,
    double progress,
  ) {
    final IconData topicIcon =
        AppConstants.topicIcons[topic] ?? CupertinoIcons.book_fill;
    final int percentage = (progress * 100).toInt();

    return BentoCard(
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.topicDetail,
        arguments: {'topic': topic},
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          // Top Centered Icon with Bento Tint
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.bentoBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.doc_plaintext,
              color: AppColors.bentoBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),

          // Topic Name
          Expanded(
            child: Text(
              topic,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(fontSize: 16),
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
            ),
          ),

          // Progress Section
          Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "$learnedWords/$totalWords từ",
                    style: Theme.of(
                      context,
                    ).textTheme.bodySmall?.copyWith(fontSize: 10),
                  ),
                  Text(
                    "$percentage%",
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: progress == 1.0 ? AppColors.success : null,
                      fontWeight: FontWeight.bold,
                      fontSize: 10,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 6),
              ClipRRect(
                borderRadius: BorderRadius.circular(100),
                child: LinearProgressIndicator(
                  value: progress,
                  minHeight: 6,
                  backgroundColor: Theme.of(
                    context,
                  ).dividerColor.withValues(alpha: 0.1),
                  valueColor: AlwaysStoppedAnimation<Color>(
                    progress == 1.0 ? AppColors.success : AppColors.bentoBlue,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
