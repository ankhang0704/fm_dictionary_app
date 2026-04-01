import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';

class InfoTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String value;
  final bool isDark;

  const InfoTile({
    super.key,
    required this.icon,
    required this.title,
    required this.value,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        boxShadow: isDark ? [] : [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        leading: Container(
          padding: const EdgeInsets.all(8),
          decoration: BoxDecoration(
            color: AppConstants.accentColor.withValues(alpha: 0.1),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: AppConstants.accentColor, size: 22),
        ),
        title: Text(
          title,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 15,
            color: AppConstants.textSecondary,
          ),
        ),
        trailing: Text(
          value,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 15,
            fontWeight: FontWeight.w600,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
      ),
    );
  }
}