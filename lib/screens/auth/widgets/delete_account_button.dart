import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/auth/auth_sync_service.dart';

class DeleteAccountButton extends StatelessWidget {
  final User user;

  const DeleteAccountButton({super.key, required this.user});

  Future<void> _handleDeleteAccount(BuildContext context) async {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark
            ? AppConstants.darkCardColor
            : AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius / 2),
        ),
        title: Text(
          'profile.delete_confirm_title'.tr(),
          style: AppConstants.bodyStyle.copyWith(
            fontWeight: FontWeight.bold,
            color: AppConstants.errorColor,
          ),
        ),
        content: Text(
          'profile.delete_confirm_desc'.tr(),
          style: AppConstants.bodyStyle.copyWith(
            color: isDark ? Colors.white70 : AppConstants.textPrimary,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(
              'profile.cancel'.tr(),
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
            onPressed: () => Navigator.pop(ctx, true),
            child: Text('profile.delete'.tr()),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await user.delete();
      await AuthSyncService.instance.signOut();
      if (!context.mounted) return;
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('profile.delete_error'.tr()),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        icon: const Icon(CupertinoIcons.trash),
        label: Text(
          'profile.delete_account'.tr(),
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        style: OutlinedButton.styleFrom(
          foregroundColor: AppConstants.errorColor,
          side: const BorderSide(color: AppConstants.errorColor, width: 1.5),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          ),
        ),
        onPressed: () => _handleDeleteAccount(context),
      ),
    );
  }
}
