import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/utils/constants.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLang;

  const LanguageSelector({
    super.key,
    required this.currentLang
    });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _LangTab(
            code: 'en',
            label: 'ENG',
            flag: '🇬🇧',
            isSelected: currentLang == 'en',
          ),
          _LangTab(
            code: 'vi',
            label: 'VIE',
            flag: '🇻🇳',
            isSelected: currentLang == 'vi',
          ),
        ],
      ),
    );
  }
}

class _LangTab extends StatelessWidget {
  final String code;
  final String label;
  final String flag;
  final bool isSelected;

  const _LangTab({
    required this.code,
    required this.label,
    required this.flag,
    required this.isSelected,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.setLocale(Locale(code)),
      behavior: HitTestBehavior.opaque,
      child: AnimatedContainer(
        duration: AppConstants.defaultAnimationDuration,
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected ? AppConstants.accentColor : Colors.transparent,
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius - 4),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 6),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.white : AppConstants.textSecondary,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w600,
                fontSize: 13,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
