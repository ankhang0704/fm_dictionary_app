import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:hive_flutter/hive_flutter.dart';

// --- CORE / THEMES ---
import '../../../../core/constants/progress_keys.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';

class DetailStatisticalScreen extends StatelessWidget {
  const DetailStatisticalScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: ValueListenableBuilder(
        valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
        builder: (context, progressBox, _) {
          return ValueListenableBuilder<Box<Word>>(
            valueListenable: Hive.box<Word>(
              DatabaseService.wordBoxName,
            ).listenable(),
            builder: (context, wordBox, _) {
              // --- STRICTLY PRESERVED BUSINESS LOGIC ---
              final int totalWords = wordBox.length;
              int masterCount = 0;
              int learningCount = 0;
              int reviewCount = 0;
              int mistakeCount = 0;

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
                padding: const EdgeInsets.all(AppLayout.defaultPadding),
                child: Column(
                  children: [
                    // SECTION 1: GLOBAL PROGRESS
                    _buildGlobalProgressCard(context, masterCount, totalWords),
                    const SizedBox(height: 16),

                    // SECTION 2: CORE METRICS
                    _buildCoreMetricsRow(
                      context,
                      masterCount,
                      reviewCount,
                      mistakeCount,
                    ),
                    const SizedBox(height: 16),

                    // SECTION 3: ACHIEVEMENT & STATUS
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Expanded(
                          child: _buildAchievementCard(context, masterCount),
                        ),
                        const SizedBox(width: 16),
                        Expanded(
                          child: _buildLearningStatusCard(
                            context,
                            masterCount,
                            learningCount,
                            unstartedCount,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // SECTION 4: 7-DAY ACTIVITY
                    _buildActivityBarChart(context, progressBox),

                    const SizedBox(height: 40),
                  ],
                ),
              );
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
        "Thống kê chi tiết",
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget _buildGlobalProgressCard(BuildContext context, int master, int total) {
    final double progress = total > 0 ? (master / total).clamp(0.0, 1.0) : 0.0;
    final int percent = (progress * 100).toInt();

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                "Tiến độ tổng thể",
                style: Theme.of(
                  context,
                ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
              ),
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.warning.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.flame_fill,
                  color: AppColors.warning,
                  size: 18,
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              "$master / $total từ",
              style: Theme.of(
                context,
              ).textTheme.displayLarge?.copyWith(fontSize: 36),
            ),
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(100),
            child: LinearProgressIndicator(
              value: progress,
              minHeight: 12,
              backgroundColor: AppColors.bentoMint.withValues(alpha: 0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(
                AppColors.bentoMint,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Bạn đã hoàn thành $percent% lộ trình học tập.",
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Widget _buildCoreMetricsRow(
    BuildContext context,
    int master,
    int review,
    int errors,
  ) {
    return Row(
      children: [
        Expanded(
          child: _buildMetricCard(
            context,
            "Đã thuộc",
            master.toString(),
            AppColors.success,
            CupertinoIcons.checkmark_seal_fill,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            "Cần ôn",
            review.toString(),
            AppColors.bentoBlue,
            CupertinoIcons.book_fill,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
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
    BuildContext context,
    String title,
    String value,
    Color color,
    IconData icon,
  ) {
    return BentoCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 8),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 20),
          ),
          const SizedBox(height: 12),
          FittedBox(
            child: Text(
              value,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: color),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              fontSize: 11,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAchievementCard(BuildContext context, int masterCount) {
    String levelName = "Người mới";
    if (masterCount >= 200) levelName = "Sơ cấp";
    if (masterCount >= 500) levelName = "Trung cấp";
    if (masterCount >= 900) levelName = "Cao cấp";

    return BentoCard(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.bentoYellow.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.rosette,
              size: 40,
              color: AppColors.bentoYellow,
            ),
          ),
          const SizedBox(height: 16),
          Text("Achievement", style: Theme.of(context).textTheme.bodySmall),
          FittedBox(
            child: Text(
              levelName,
              style: Theme.of(
                context,
              ).textTheme.displaySmall?.copyWith(color: AppColors.bentoYellow),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLearningStatusCard(
    BuildContext context,
    int mastered,
    int learning,
    int unstarted,
  ) {
    final total = mastered + learning + unstarted;
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Status",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatusBar(
            context,
            "Mastered",
            mastered,
            total,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            context,
            "Learning",
            learning,
            total,
            AppColors.bentoBlue,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            context,
            "Unstarted",
            unstarted,
            total,
            Theme.of(context).dividerColor,
          ),
        ],
      ),
    );
  }

  Widget _buildStatusBar(
    BuildContext context,
    String label,
    int count,
    int total,
    Color color,
  ) {
    double widthFactor = total > 0 ? (count / total) : 0.0;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              label,
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(fontSize: 10),
            ),
            Text(
              count.toString(),
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 10,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        const SizedBox(height: 6),
        ClipRRect(
          borderRadius: BorderRadius.circular(100),
          child: LinearProgressIndicator(
            value: widthFactor,
            minHeight: 6,
            backgroundColor: color.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      ],
    );
  }

  Widget _buildActivityBarChart(BuildContext context, Box progressBox) {
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

    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Hoạt động 7 ngày qua",
            style: Theme.of(context).textTheme.displaySmall,
          ),
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
                            color: AppColors.bentoBlue,
                            borderRadius: BorderRadius.circular(4),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      dayName,
                      style: Theme.of(
                        context,
                      ).textTheme.bodySmall?.copyWith(fontSize: 10),
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
