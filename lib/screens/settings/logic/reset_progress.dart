import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/utils/loading.dart';
import 'package:fm_dictionary/services/database_service.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:hive/hive.dart';

class ResetProgressLogic {
  static void resetProgress(BuildContext context)  async  {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark
            ? AppConstants.darkCardColor
            : AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius / 2),
        ),
        title: Text(
          'settings.reset_btn'.tr(),
          style: const TextStyle(color: AppConstants.errorColor),
        ),
        content: Text(
          'settings.reset_desc'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white70 : AppConstants.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'settings.cancel'.tr(),
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.buttonRadius / 2,
                ),
              ),
            ),
            onPressed: () async {
              LoadingManager.show();

              // TỐI ƯU: Chỉ cần xóa toàn bộ dữ liệu trong progress box (Siêu tốc - O(1))
              final progressBox = Hive.box(DatabaseService.progressBoxName);
              await progressBox.clear();

              if (!context.mounted) return;
              LoadingManager.hide();
              Navigator.pop(context);

              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('settings.reset_success'.tr()),
                  backgroundColor: AppConstants.successColor,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(
                      AppConstants.inputRadius,
                    ),
                  ),
                ),
              );
            },
            child: Text('settings.reset_btn'.tr()),
          ),
        ],
      ),
    );
  }
}
