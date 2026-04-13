// Đường dẫn: lib/features/auth/presentation/widgets/statistics_bento.dart

import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/services/database/database_service.dart';

class StatisticsSectionBento extends StatelessWidget {
  const StatisticsSectionBento({super.key});

  @override
  Widget build(BuildContext context) {
    // Vẫn dùng Hive Listenable để tối ưu performance nội bộ cho Widget này
    return ValueListenableBuilder(
      valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
      builder: (context, box, _) {
        int learned = 0;
        int review = 0;
        int totalMistakes = 0;
        final now = DateTime.now().millisecondsSinceEpoch;

        // Thuật toán tính toán nhanh từ dữ liệu Local
        for (var value in box.values) {
          final map = value as Map;
          if ((map['s'] ?? 0) >= 4) learned++;
          if ((map['nr'] ?? 0) <= now && (map['nr'] ?? 0) > 0) review++;
          totalMistakes += (map['wc'] ?? 0) as int;
        }

        return Row(
          children: [
            Expanded(
              child: _buildStatCardBento(
                context,
                title: 'Đã thuộc',
                value: learned.toString(),
                color: Colors.green, // AppConstants.successColor
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCardBento(
                context,
                title: 'Cần ôn',
                value: review.toString(),
                color: Colors.blue, // AppConstants.accentColor
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildStatCardBento(
                context,
                title: 'Lỗi sai',
                value: totalMistakes.toString(),
                color: Colors.red, // AppConstants.errorColor
              ),
            ),
          ],
        );
      },
    );
  }

  // KHỐI BENTO CHO TỪNG THỐNG KÊ
  Widget _buildStatCardBento(
    BuildContext context, {
    required String title,
    required String value,
    required Color color,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 8),
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.1),
        borderRadius: BorderRadius.circular(20), // Góc bo tròn to chuẩn Bento
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: color,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            title,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.8),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}