import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';

// --- CORE UI & THEME ---
import 'package:fm_dictionary/core/theme/app_colors.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';

class BentoBadgeWidget extends StatelessWidget {
  final String badgeName;
  final IconData icon;
  final bool isUnlocked;
  final String? dateUnlocked;

  const BentoBadgeWidget({
    super.key,
    required this.badgeName,
    required this.icon,
    required this.isUnlocked,
    this.dateUnlocked,
  });

  @override
  Widget build(BuildContext context) {
    // Dynamic theme text colors mapping
    final primaryTextColor = Theme.of(context).textTheme.displayLarge?.color;
    final secondaryTextColor = Theme.of(context).textTheme.bodyMedium?.color;

    return BentoCard(
      padding: const EdgeInsets.all(12.0),
      onTap: () {
        // Optional: Show a detail dialog for the badge
      },
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // THE ICON SECTION
          _buildBadgeIcon(context, secondaryTextColor),
          const SizedBox(height: 12),

          // THE TEXT SECTION (ZERO OVERFLOW PROTECTION)
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              badgeName,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 13,
                color: isUnlocked ? primaryTextColor : secondaryTextColor,
              ),
              textAlign: TextAlign.center,
            ),
          ),

          if (isUnlocked && dateUnlocked != null) ...[
            const SizedBox(height: 4),
            Text(
              dateUnlocked!,
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 9,
                color: secondaryTextColor,
                fontWeight: FontWeight.bold,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildBadgeIcon(BuildContext context, Color? secondaryTextColor) {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Flat Bento Badge Icon Wrapper
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: isUnlocked
                ? AppColors.warning.withValues(alpha: 0.15) // Flat tint
                : Theme.of(context).dividerColor.withValues(alpha: 0.05),
            shape: BoxShape.circle,
          ),
          child: Icon(
            icon,
            color: isUnlocked
                ? AppColors.warning
                : secondaryTextColor?.withValues(alpha: 0.4),
            size: 28,
          ),
        ),

        // Solid Lock Overlay for Locked Badges
        if (!isUnlocked)
          Positioned(
            right: 0,
            bottom: 0,
            child: Container(
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Theme.of(
                  context,
                ).colorScheme.surface, // Cut-out effect against card
                shape: BoxShape.circle,
              ),
              child: Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  CupertinoIcons.lock_fill,
                  size: 10,
                  color: secondaryTextColor,
                ),
              ),
            ),
          ),
      ],
    );
  }
}
