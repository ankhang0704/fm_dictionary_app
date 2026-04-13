import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/data/services/auth/auth_sync_service.dart';

Future<void> handleSync(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) =>
          const Center(child: CircularProgressIndicator.adaptive()),
    );

    try {
      await AuthSyncService.instance.syncDataWithMerge();
      if (!context.mounted) return;
      Navigator.of(context, rootNavigator: true).pop();
      Navigator.pop(context);
      _showSnackBar(
        context,
        'sidebar.sync_success'.tr(),
        AppConstants.successColor,
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context);
      Navigator.of(context, rootNavigator: true).pop();
      _showSnackBar(
        context,
        _getFriendlyErrorMessage(e),
        AppConstants.errorColor,
      );
    }
  }

  void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.inputRadius),
        ),
      ),
    );
  }

  String _getFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('unavailable')) {
      return "Lỗi kết nối mạng. Ứng dụng sẽ đồng bộ khi có Internet.";
    } else if (errorString.contains('canceled') ||
        errorString.contains('cancelled')) {
      return "Đã hủy thao tác.";
    } else if (errorString.contains('not_logged_in')) {
      return "Bạn cần đăng nhập để đồng bộ dữ liệu.";
    }
     return "Lỗi hệ thống (${error.toString()})";
  }