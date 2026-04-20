import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/gamification/presentation/widgets/glass_badge_widget.dart';
import 'package:provider/provider.dart';

// --- CORE UI ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';

// --- PROVIDERS ---
import '../providers/gamification_provider.dart';

class BadgesBento extends StatelessWidget {
  const BadgesBento({super.key});

  @override
  Widget build(BuildContext context) {
    final gamification = context.watch<GamificationProvider>();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Section Header
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 12),
          child: Row(
            children: [
              const Icon(
                CupertinoIcons.rosette,
                color: AppColors.warning,
                size: 24,
              ),
              const SizedBox(width: 12),
              Text(
                "Bộ sưu tập Huy hiệu",
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
        ),

        // The Badge Grid (Atomic units)
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 4, // 4 Badges per row
            crossAxisSpacing: 12,
            mainAxisSpacing: 12,
            childAspectRatio:
                0.75, // Tall vertical aspect ratio for name & date
          ),
          itemCount: gamification.badges.length,
          itemBuilder: (context, index) {
            final badge = gamification.badges[index];

            // Legacy Logic Mapping:
            // - title maps to badgeName
            // - icon maps to icon
            // - isUnlocked maps to isUnlocked
            return GlassBadgeWidget(
              badgeName: badge.title,
              icon: badge.icon,
              isUnlocked: badge.isUnlocked,
              // If you have a timestamp in your model, pass it here
              dateUnlocked: badge.isUnlocked ? "Đã đạt" : null,
            );
          },
        ),
      ],
    );
  }
}
