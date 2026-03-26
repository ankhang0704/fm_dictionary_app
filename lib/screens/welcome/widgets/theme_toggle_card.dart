import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/utils/constants.dart';

class ThemeToggleCard extends StatelessWidget {
  final bool isDarkMode;
  final bool isDarkThemeActive;
  final ValueChanged<bool> onChanged;

  const ThemeToggleCard({
    super.key,
    required this.isDarkMode,
    required this.isDarkThemeActive,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => onChanged(!isDarkMode),
      borderRadius: BorderRadius.circular(AppConstants.inputRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          color: isDarkThemeActive
              ? AppConstants.darkCardColor
              : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          border: Border.all(
            color: isDarkThemeActive
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        child: Row(
          children: [
            AnimatedSwitcher(
              duration: AppConstants.defaultAnimationDuration,
              child: Icon(
                isDarkMode
                    ? CupertinoIcons.moon_stars_fill
                    : CupertinoIcons.sun_max_fill,
                key: ValueKey(isDarkMode),
                color: isDarkMode ? Colors.amber : AppConstants.accentColor,
                size: 26,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Text(
                isDarkMode
                    ? 'welcome.dark_mode'.tr()
                    : 'welcome.light_mode'.tr(),
                style: AppConstants.bodyStyle.copyWith(
                  fontWeight: FontWeight.w600,
                  color: isDarkThemeActive
                      ? Colors.white
                      : AppConstants.textPrimary,
                ),
              ),
            ),
            Switch.adaptive(
              value: isDarkMode,
              // ignore: deprecated_member_use
              activeColor: AppConstants.accentColor,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
