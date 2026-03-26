import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:fm_dictionary/utils/constants.dart'; // Đừng quên cái này để dùng .tr()

// XÓA dấu gạch dưới ở đây -> class WelcomeHeader
class WelcomeHeader extends StatelessWidget {
  final bool isDark;

  const WelcomeHeader({
    super.key,
    required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'welcome.title'.tr(),
          style: AppConstants.headingStyle.copyWith(
            fontSize: 40,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 12),
        Text(
          'welcome.subtitle'.tr(),
          style: AppConstants.bodyStyle.copyWith(
            color: isDark ? Colors.white70 : AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }
}
