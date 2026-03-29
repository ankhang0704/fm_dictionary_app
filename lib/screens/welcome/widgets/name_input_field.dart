import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';

class NameInputField extends StatelessWidget {
  final TextEditingController controller;
  final bool isDark;

  const NameInputField({
    super.key,
    required this.controller, 
    required this.isDark});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      style: TextStyle(color: isDark ? Colors.white : AppConstants.textPrimary),
      decoration: InputDecoration(
        labelText: 'welcome.name_hint'.tr(),
        labelStyle: TextStyle(color: AppConstants.textSecondary),
        filled: true,
        fillColor: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        prefixIcon: Icon(
          CupertinoIcons.person_crop_circle,
          color: isDark ? Colors.white70 : AppConstants.textSecondary,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: BorderSide(
            color: isDark
                ? Colors.transparent
                : Colors.grey.withValues(alpha: 0.1),
          ),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          borderSide: const BorderSide(
            color: AppConstants.accentColor,
            width: 2,
          ),
        ),
      ),
    );
  }
}
