import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../providers/gamification_provider.dart';

class BadgesBento extends StatelessWidget {
  const BadgesBento({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gamification = context.watch<GamificationProvider>();

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(Icons.military_tech, color: Colors.amber, size: 24),
              const SizedBox(width: 8),
              Text(
                "Bộ sưu tập Huy hiệu",
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          // Hiển thị danh sách dạng Grid 
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 4, // 4 Huy hiệu 1 hàng ngang
              crossAxisSpacing: 12,
              mainAxisSpacing: 12,
              childAspectRatio: 0.75, // Chỉnh tỷ lệ hình chữ nhật
            ),
            itemCount: gamification.badges.length,
            itemBuilder: (context, index) {
              final badge = gamification.badges[index];
              return _buildBadgeItem(badge, isDark);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBadgeItem(BadgeModel badge, bool isDark) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(
            color: badge.isUnlocked 
                ? AppConstants.accentColor.withValues(alpha: 0.15) 
                : Colors.grey.withValues(alpha: 0.1),
            shape: BoxShape.circle,
            border: Border.all(
              color: badge.isUnlocked ? AppConstants.accentColor : Colors.transparent,
              width: 2,
            ),
          ),
          child: Icon(
            badge.icon,
            color: badge.isUnlocked ? Colors.amber : Colors.grey.withValues(alpha: 0.4),
            size: 28,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          badge.title,
          textAlign: TextAlign.center,
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontSize: 11,
            fontWeight: FontWeight.bold,
            color: badge.isUnlocked 
                ? (isDark ? Colors.white : AppConstants.textPrimary) 
                : Colors.grey,
          ),
        ),
      ],
    );
  }
}