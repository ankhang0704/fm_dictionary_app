import 'package:easy_localization/easy_localization.dart';
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
        'stats.header_detail'.tr(),
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
                'stats.overall_progress'.tr(),
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
              'stats.word_count'.tr(
                args: [master.toString(), total.toString()],
              ),
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
            'stats.completion_summary'.tr(args: [percent.toString()]),
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
            'stats.mastered'.tr(),
            master.toString(),
            AppColors.success,
            CupertinoIcons.checkmark_seal_fill,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'stats.to_review'.tr(),
            review.toString(),
            AppColors.bentoBlue,
            CupertinoIcons.book_fill,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildMetricCard(
            context,
            'stats.mistakes'.tr(),
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
    String levelName = 'stats.level_newbie'.tr();
    if (masterCount >= 200) levelName = 'stats.level_beginner'.tr();
    if (masterCount >= 500) levelName = 'stats.level_intermediate'.tr();
    if (masterCount >= 900) levelName = 'stats.level_advanced'.tr();

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
          Text(
            'stats.achievements'.tr(),
            style: Theme.of(context).textTheme.bodySmall,
          ),
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
            'stats.status'.tr(),
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 16),
          _buildStatusBar(
            context,
            'stats.mastered_title'.tr(),
            mastered,
            total,
            AppColors.success,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            context,
            'stats.learning_title'.tr(),
            learning,
            total,
            AppColors.bentoBlue,
          ),
          const SizedBox(height: 12),
          _buildStatusBar(
            context,
            'stats.unstarted_title'.tr(),
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
    // 🚨 ABSOLUTE LOGIC PRESERVED
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
          // LOCALIZATION PRESERVED
          Text(
            'stats.last_7_days'.tr(),
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize: 18,
            ),
          ),
          const SizedBox(height: 32),
          SizedBox(
            height: 140,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: List.generate(7, (index) {
                final double heightFactor = counts[index] / (maxVal * 1.1);
                final targetDate = now.subtract(Duration(days: 6 - index));
                String formatday = 'stats.format'.tr();
                // GIẢI PHÁP AN TOÀN TUYỆT ĐỐI: Dùng DateFormat
                // Nó sẽ tự động ra "Mon", "Tue"... dựa theo ngôn ngữ máy mà không bị crash
                final String dayLabel = DateFormat.E(
                  formatday,
                ).format(targetDate);

                return Expanded(
                  child: Column(
                    children: [
                      // CỘT BIỂU ĐỒ - GHIM SÁT XUỐNG ĐÁY
                      Expanded(
                        child: Align(
                          alignment: Alignment
                              .bottomCenter, // Đảm bảo mọc ngược từ dưới lên
                          child: FractionallySizedBox(
                            heightFactor: heightFactor.clamp(0.08, 1.0),
                            child: Container(
                              width: 18,
                              decoration: BoxDecoration(
                                // Gradient nhẹ cho chuẩn Vibrant Bento
                                gradient: LinearGradient(
                                  begin: Alignment.topCenter,
                                  end: Alignment.bottomCenter,
                                  colors: [
                                    const Color(0xFF60A5FA), // Light Blue
                                    const Color(0xFF3B82F6), // Vibrant Blue
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(6),
                                boxShadow: [
                                  BoxShadow(
                                    color: const Color(
                                      0xFF3B82F6,
                                    ).withValues(alpha: 0.15),
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 12),
                      // TÊN NGÀY - NGAY SÁT DƯỚI CHÂN CỘT
                      Text(
                        dayLabel,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: Theme.of(context).hintColor,
                        ),
                        maxLines: 1,
                      ),
                    ],
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
