import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';

class GreetingSection extends StatelessWidget {
  final String userName;
  final bool isDark;

  const GreetingSection({
    super.key,
    required this.userName,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '${'dashboard.hello'.tr()} $userName',
          style: AppConstants.bodyStyle.copyWith(
            color: isDark ? Colors.white54 : AppConstants.textSecondary,
            fontSize: 16,
            fontWeight: FontWeight.w500,
          ),
        ),
        
      ],
    );
  }
}
