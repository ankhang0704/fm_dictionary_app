import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/screens/settings/widgets/language_option.dart';
import 'package:fm_dictionary/utils/constants.dart';

class ShowLanguageLogic {
static void showLanguagePicker(BuildContext context) {
  final currentLang = context.locale.languageCode;

  showModalBottomSheet(
    context: context,
    backgroundColor: Colors.transparent,
    builder: (context) {
      final isDark = Theme.of(context).brightness == Brightness.dark;
      return Container(
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppConstants.cardRadius),
          ),
        ),
        padding: const EdgeInsets.symmetric(vertical: 24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.withValues(alpha: 0.3),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'settings.language'.tr(),
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 16),
            LanguageOption(
              title: 'English',
              flag: '🇬🇧',
              isSelected: currentLang == 'en',
              onTap: () {
                context.setLocale(const Locale('en'));
                Navigator.pop(context);
              },
            ),
            LanguageOption(
              title: 'Tiếng Việt',
              flag: '🇻🇳',
              isSelected: currentLang == 'vi',
              onTap: () {
                context.setLocale(const Locale('vi'));
                Navigator.pop(context);
              },
            ),
            const SizedBox(height: 24),
          ],
        ),
      );
    },
  );
}
}