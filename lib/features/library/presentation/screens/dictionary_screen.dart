import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/progress_keys.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/app_routes.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';

class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

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
          bottom: false, // Prevents bottom padding over the glassy nav bar
          child: ValueListenableBuilder<Box<Word>>(
            valueListenable: Hive.box<Word>(
              DatabaseService.wordBoxName,
            ).listenable(),
            builder: (context, wordBox, child) {
              // --- 1. DATA EXTRACTION & PROGRESS LOGIC ---
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

              // --- 2. UI CONSTRUCTION ---
              return CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // --- TOP SECTION (Search Bar & Overall Progress) ---
                  SliverPadding(
                    padding: EdgeInsets.all(AppLayout.defaultPadding),
                    sliver: SliverList(
                      delegate: SliverChildListDelegate([
                        _buildHeader(),
                        const SizedBox(height: 24),
                        _buildSearchBar(context),
                        const SizedBox(height: 16),
                        _buildOverallProgressCard(
                          masteredTopics,
                          totalTopics,
                          overallProgress,
                        ),
                      ]),
                    ),
                  ),

                  // --- TOPIC GRID (Bento Cards) ---
                  SliverPadding(
                    padding: EdgeInsets.only(
                      left: AppLayout.defaultPadding,
                      right: AppLayout.defaultPadding,
                      bottom:
                          120, // Extra padding to clear Bottom Navigation safely
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
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildHeader() {
    return Text(
      'Kho Từ Điển',
      style: AppTypography.heading1.copyWith(color: AppColors.textPrimary),
    );
  }

  Widget _buildSearchBar(BuildContext context) {
    return GestureDetector(
      onTap: () => Navigator.pushNamed(context, AppRoutes.search),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(16),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.3),
                width: 1,
              ),
            ),
            child: Row(
              children: [
                const Icon(CupertinoIcons.search, color: AppColors.textPrimary),
                const SizedBox(width: 12),
                Text(
                  "Tìm kiếm từ vựng...",
                  style: AppTypography.bodyLarge.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOverallProgressCard(int mastered, int total, double progress) {
    return GlassBentoCard(
      onTap: null, // Just an informational display
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.success.withValues(alpha: 0.2),
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
                      style: AppTypography.bodyMedium.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      "Hoàn thành $mastered/$total Chủ đề",
                      style: AppTypography.heading3.copyWith(
                        color: AppColors.textPrimary,
                      ),
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
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 8,
              backgroundColor: Colors.white.withValues(alpha: 0.15),
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

    return GlassBentoCard(
      // Ensure we navigate to the specific topic detail using the defined route
      onTap: () => Navigator.pushNamed(
        context,
        AppRoutes.topicDetail,
        arguments: {'topic': topic},
      ),
      child: Stack(
        children: [
          // Large faded background icon
          Positioned(
            right: -20,
            top: -20,
            child: Icon(
              topicIcon,
              size: 100,
              color: Colors.white.withValues(alpha: 0.05),
            ),
          ),

          // Card Content
          Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Top Centered Icon
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: AppColors.meshBlue.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(topicIcon, color: AppColors.meshBlue, size: 28),
              ),
              const SizedBox(height: 12),

              // Topic Name (Zero Overflow Strategy)
              Expanded(
                child: Text(
                  topic,
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Progress Section at Bottom
              Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        "$learnedWords/$totalWords từ",
                        style: AppTypography.bodyMedium.copyWith(
                          color: AppColors.textSecondary,
                          fontSize: 11,
                        ),
                      ),
                      Text(
                        "$percentage%",
                        style: AppTypography.bodyMedium.copyWith(
                          color: progress == 1.0
                              ? AppColors.success
                              : AppColors.textPrimary,
                          fontWeight: FontWeight.bold,
                          fontSize: 11,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: progress,
                      minHeight: 4,
                      backgroundColor: Colors.white.withValues(alpha: 0.1),
                      valueColor: AlwaysStoppedAnimation<Color>(
                        progress == 1.0
                            ? AppColors.success
                            : AppColors.meshMint,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}
