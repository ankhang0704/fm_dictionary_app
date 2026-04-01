import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/database/database_service.dart';
import 'package:hive_flutter/hive_flutter.dart';

class StatisticsSection extends StatelessWidget {
  const StatisticsSection({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder(
      valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
      builder: (context, box, _) {
        int learned = 0;
        int review = 0;
        int totalMistakes = 0;
        final now = DateTime.now().millisecondsSinceEpoch;

        for (var value in box.values) {
          final map = value as Map;
          if ((map['s'] ?? 0) >= 4) learned++;
          if ((map['nr'] ?? 0) <= now && (map['nr'] ?? 0) > 0) review++;
          totalMistakes += (map['wc'] ?? 0) as int;
        }

        return Row(
          children: [
            Expanded(
              child: _StatCard(
                title: 'profile.learned'.tr(),
                value: learned.toString(),
                color: AppConstants.successColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'profile.review'.tr(),
                value: review.toString(),
                color: AppConstants.accentColor,
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _StatCard(
                title: 'profile.mistakes'.tr(),
                value: totalMistakes.toString(),
                color: AppConstants.errorColor,
              ),
            ),
          ],
        );
      },
    );
  }
}

class _StatCard extends StatelessWidget {
  final String title;
  final String value;
  final Color color;

  const _StatCard({
    required this.title,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: isDark ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        border: Border.all(color: color.withValues(alpha: 0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: AppConstants.headingStyle.copyWith(
              fontSize: 28,
              color: color,
              fontStyle: FontStyle.normal,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: AppConstants.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withValues(alpha: 0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}
