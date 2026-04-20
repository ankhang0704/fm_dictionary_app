import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/theme/app_colors.dart';
import 'package:fm_dictionary/core/theme/app_typography.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';

// --- CORE UI & THEME ---


class GlassBadgeWidget extends StatelessWidget {
  final String badgeName;
  final IconData icon;
  final bool isUnlocked;
  final String? dateUnlocked;

  const GlassBadgeWidget({
    super.key,
    required this.badgeName,
    required this.icon,
    required this.isUnlocked,
    this.dateUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    return GlassBentoCard(
      onTap: () {
        // Optional: Show a detail dialog for the badge
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // THE ICON SECTION
          _buildBadgeIcon(),
          const SizedBox(height: 12),

          // THE TEXT SECTION (ZERO OVERFLOW PROTECTION)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              badgeName,
              style: AppTypography.heading3.copyWith(
                fontSize: 13,
                color: isUnlocked
                    ? AppColors.textPrimary
                    : AppColors.textSecondary,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (isUnlocked && dateUnlocked != null) ...[
            const SizedBox(height: 4),
            Text(
              dateUnlocked!,
              style: TextStyle(
                fontSize: 9,
                color: AppColors.textSecondary.withValues(alpha:0.7),
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeIcon() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Background Glow for Unlocked Badges
        if (isUnlocked)
          Container(
            width: 45,
            height: 45,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.warning.withValues(alpha:0.4),
                  blurRadius: 15,
                  spreadRadius: 2,
                ),
              ],
            ),
          ),

        // The Badge Icon
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.warning.withValues(alpha:0.2)
                : Colors.white.withValues(alpha:0.05),
            shape: BoxShape.circle,
            border: Border.all(
              color: isUnlocked
                  ? AppColors.warning
                  : Colors.white.withValues(alpha:0.1),
              width: 1.5,
            ),
          ),
          child: Icon(
            icon,
            color: isUnlocked
                ? AppColors.warning
                : AppColors.textSecondary.withValues(alpha:0.4),
            size: 28,
          ),
        ),

        // Lock Overlay for Locked Badges
        if (!isUnlocked)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: const BoxDecoration(
                color: Colors.black54,
                shape: BoxShape.circle,
              ),
              child: const Icon(
                CupertinoIcons.lock_fill,
                size: 10,
                color: Colors.white70,
              ),
            ),
          ),
      ],
    );
  }
}
