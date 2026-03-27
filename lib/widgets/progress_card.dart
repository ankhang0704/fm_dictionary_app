import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../core/utils/constants.dart';

class ProgressCard extends StatelessWidget {
  final int learnedCount;
  final int totalCount;

  const ProgressCard({
    super.key,
    required this.learnedCount,
    required this.totalCount,
  });

  @override
  Widget build(BuildContext context) {
  final double progress = totalCount > 0 ? learnedCount / totalCount : 0;
  final theme = Theme.of(context);
  final isDark = theme.brightness == Brightness.dark;

  return Container(
    width: double.infinity,
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      // Dùng primaryContainer giúp màu nền dịu hơn và tương phản tốt hơn
      color: isDark ? theme.colorScheme.surfaceContainerHighest : theme.colorScheme.primary,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      boxShadow: [
        if (!isDark) BoxShadow(color: theme.primaryColor.withValues(alpha: 0.3), blurRadius: 15, offset: const Offset(0, 8))
      ],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'widget.progress_title'.tr(),
          style: TextStyle(
            color: isDark ? theme.colorScheme.onSurfaceVariant : Colors.white70, 
            fontSize: 12,
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          '$learnedCount / $totalCount ${'widget.words'.tr()}',
          style: TextStyle(
            color: isDark ? theme.colorScheme.onSurface : Colors.white,
            fontSize: 26,
            fontWeight: FontWeight.bold,
          ),
        ),
        const SizedBox(height: 20),
        Stack(
          children: [
            // Thanh progress nền
            Container(
              height: 10,
              decoration: BoxDecoration(
                color: isDark ? Colors.white10 : Colors.white24,
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            // Thanh progress chạy
            AnimatedContainer(
              duration: const Duration(milliseconds: 500),
              height: 10,
              width: (MediaQuery.of(context).size.width - 96) * progress,
              decoration: BoxDecoration(
                color: isDark ? theme.colorScheme.primary : Colors.white,
                borderRadius: BorderRadius.circular(10),
                boxShadow: [
                  if (!isDark) const BoxShadow(color: Colors.white54, blurRadius: 4)
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}}