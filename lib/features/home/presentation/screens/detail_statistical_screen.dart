import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/progress_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';

class DetailStatisticalScreen extends StatelessWidget {
  const DetailStatisticalScreen({super.key});

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
          builder: (context, progressBox, _) {
            return ValueListenableBuilder<Box<Word>>(
              valueListenable: Hive.box<Word>(
                DatabaseService.wordBoxName,
              ).listenable(),
              builder: (context, wordBox, _) {
                // --- LEGACY DATA EXTRACTION ---
                final int totalWords = wordBox.length;
                int masterCount = 0; // Progress Step >= 4
                int learningCount = 0; // Progress Step between 1 and 3
                int reviewCount = 0; // Needs review today
                int mistakeCount = 0; // Sum of wrongCount

                final now = DateTime.now().millisecondsSinceEpoch;

                for (var value in progressBox.values) {
                  final map = value as Map;
                  final step = (map[ProgressKeys.step] ?? 0) as int;

                  if (step >= 4) {
                    masterCount++;
                  } else if (step > 0) {
                    learningCount++;
                  }

                  if ((map[ProgressKeys.nextReview] ?? 0) <= now &&
                      (map[ProgressKeys.nextReview] ?? 0) > 0) {
                    reviewCount++;
                  }
                  mistakeCount += (map[ProgressKeys.wrongCount] ?? 0) as int;
                }

                final int unstartedCount =
                    totalWords - (masterCount + learningCount);

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: EdgeInsets.all(AppLayout.defaultPadding),
                  child: Column(
                    children: [
                      // SECTION 1: GLOBAL PROGRESS
                      _buildGlobalProgressCard(masterCount, totalWords),
                      const SizedBox(height: 16),

                      // SECTION 2: CORE METRICS (3-Card Row)
                      _buildCoreMetricsRow(
                        masterCount,
                        reviewCount,
                        mistakeCount,
                      ),
                      const SizedBox(height: 16),

                      // SECTION 3: ACHIEVEMENT & TOPICS (2-Card Row)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(child: _buildAchievementCard(masterCount)),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _buildLearningStatusCard(
                              masterCount,
                              learningCount,
                              unstartedCount,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),

                      // SECTION 4: 7-DAY ACTIVITY
                      _buildActivityBarChart(progressBox),

                      const SizedBox(height: 40),
                    ],
                  ),
                );
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
              "Thống kê chi tiết",
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGlobalProgressCard(int master, int total) {
    final double progress = total > 0 ? (master / total).clamp(0.0, 1.0) : 0.0;
    final int percent = (progress * 100).toInt();

    return GlassBentoCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiến độ tổng thể",
                style: AppTypography.bodyLarge.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Icon(CupertinoIcons.flame_fill, color: AppColors.warning),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              "$master / $total từ",
              style: AppTypography.heading1.copyWith(fontSize: 36),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: Colors.white.withValues(alpha:0.15),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.meshMint,
              ),
            ),
          ),
          const SizedBox(height: 8),
          Text(
            "Bạn đã hoàn thành $percent% lộ trình học tập.",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCoreMetricsRow(int master, int review, int errors) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            "Đã thuộc",
            master.toString(),
            AppColors.success,
            CupertinoIcons.checkmark_seal_fill,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            "Cần ôn",
            review.toString(),
            AppColors.meshBlue,
            CupertinoIcons.book_fill,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            "Lỗi sai",
            errors.toString(),
            AppColors.error,
            CupertinoIcons.exclamationmark_circle_fill,
          ),
        ),
      ],
    );
  }

  Widget _buildMetricCard(
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          Icon(icon, color: color, size: 24),
          const SizedBox(height: 8),
          FittedBox(
            child: Text(
              value,
              style: AppTypography.heading2.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(int masterCount) {
    // Legacy logic mapping for Badge naming
    String levelName = "Người mới";
    if (masterCount >= 200) levelName = "Sơ cấp";
    if (masterCount >= 500) levelName = "Trung cấp";
    if (masterCount >= 900) levelName = "Cao cấp";

    return GlassBentoCard(
      onTap: null,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(CupertinoIcons.rosette, size: 50, color: Colors.amber),
          const SizedBox(height: 12),
          Text(
            "Achievement",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
          FittedBox(
            child: Text(
              levelName,
              style: AppTypography.heading3.copyWith(color: Colors.amber),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStatusCard(int mastered, int learning, int unstarted) {
    final total = mastered + learning + unstarted;
    return GlassBentoCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Learning Status",
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 12),
          _buildStatusBar("Mastered", mastered, total, AppColors.success),
          const SizedBox(height: 8),
          _buildStatusBar("Learning", learning, total, AppColors.meshBlue),
          const SizedBox(height: 8),
          _buildStatusBar(
            "Unstarted",
            unstarted,
            total,
            AppColors.textSecondary.withValues(alpha:0.5),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(String label, int count, int total, Color color) {
    double widthFactor = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: const TextStyle(
                fontSize: 10,
                color: AppColors.textSecondary,
              ),
            ),
            Text(
              count.toString(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        const SizedBox(height: 4),
        ClipRRect(
          borderRadius: BorderRadius.circular(4),
          child: LinearProgressIndicator(
            value: widthFactor,
            minHeight: 4,
            backgroundColor: Colors.white.withValues(alpha:0.05),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityBarChart(Box progressBox) {
    // DATA LOGIC: Extract review counts for the last 7 days
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final List<int> counts = List.filled(7, 0);

    for (var value in progressBox.values) {
      final map = value as Map;
      final int lr = map[ProgressKeys.lastReview] ?? 0;
      if (lr > 0) {
        final reviewDate = DateTime.fromMillisecondsSinceEpoch(lr);
        final diff = today
            .difference(
              DateTime(reviewDate.year, reviewDate.month, reviewDate.day),
            )
            .inDays;
        if (diff >= 0 && diff < 7) {
          counts[6 - diff]++;
        }
      }
    }

    int maxVal = counts.reduce((a, b) => a > b ? a : b);
    if (maxVal == 0) maxVal = 1;

    return GlassBentoCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Hoạt động 7 ngày qua", style: AppTypography.heading3),
          const SizedBox(height: 24),
          SizedBox(
            height: 120,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: List.generate(7, (index) {
                final double heightFactor = counts[index] / (maxVal * 1.2);
                final dayName = [
                  'T2',
                  'T3',
                  'T4',
                  'T5',
                  'T6',
                  'T7',
                  'CN',
                ][(now.subtract(Duration(days: 6 - index)).weekday - 1) % 7];

                return Column(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    Expanded(
                      child: FractionallySizedBox(
                        heightFactor: heightFactor.clamp(0.05, 1.0),
                        child: Container(
                          width: 16,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [
                                AppColors.meshPurple,
                                AppColors.meshBlue,
                              ],
                              begin: Alignment.topCenter,
                              end: Alignment.bottomCenter,
                            ),
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayName,
                      style: const TextStyle(
                        fontSize: 10,
                        color: AppColors.textSecondary,
                      ),
                    ),
                  ],
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
