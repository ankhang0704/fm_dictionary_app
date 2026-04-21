// lib/core/widgets/common/sync_data_dialog.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';

// --- CORE UI & THEME ---
import 'package:fm_dictionary/core/theme/app_colors.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';

// import 'package:fm_dictionary/data/services/auth_sync/auth_sync_service.dart';

class SyncDataDialog extends StatefulWidget {
  const SyncDataDialog({super.key});

  /// Main handler to show the modern UI and execute the sync logic
  static Future<void> handleSync(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(
        alpha: 0.4,
      ), // Standard dim for focus
      builder: (dialogContext) => const SyncDataDialog(),
    );

    try {
      // Assuming AuthSyncService is globally available as in your old code
      // await AuthSyncService.instance.syncDataWithMerge();

      // Simulate sync for UI testing if the service is not yet fully implemented
      await Future.delayed(const Duration(seconds: 2));

      if (!context.mounted) return;

      // Dismiss the dialog
      Navigator.of(context, rootNavigator: true).pop();
      // Pop the underlying screen/sheet if applicable
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showSnackBar(context, 'sidebar.sync_success'.tr(), AppColors.success);
    } catch (e) {
      if (!context.mounted) return;

      // Dismiss the dialog
      Navigator.of(context, rootNavigator: true).pop();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }

      _showSnackBar(context, _getFriendlyErrorMessage(e), AppColors.error);
    }
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0),
        ),
        elevation: 0,
      ),
    );
  }

  static String _getFriendlyErrorMessage(dynamic error) {
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

  @override
  State<SyncDataDialog> createState() => _SyncDataDialogState();
}

class _SyncDataDialogState extends State<SyncDataDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(); // Continuously spin
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false, // Prevent dismissing by back button while syncing
      child: Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 40.0),
          child: BentoCard(
            padding: const EdgeInsets.all(32.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                // Vibrant Bento Icon Wrapper
                Container(
                  padding: const EdgeInsets.all(16.0),
                  decoration: BoxDecoration(
                    color: AppColors.bentoMint.withValues(alpha: 0.15),
                    shape: BoxShape.circle,
                  ),
                  child: RotationTransition(
                    turns: _animationController,
                    child: const Icon(
                      Icons.cloud_sync_rounded,
                      size: 48.0,
                      color: AppColors.bentoMint,
                    ),
                  ),
                ),
                const SizedBox(height: 24.0),

                // Zero Pixel Overflow Strategy + Adaptive Theme Text
                Flexible(
                  child: Text(
                    "Đang đồng bộ dữ liệu...",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.displaySmall,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 24.0),

                // Rounded Custom Linear Progress Indicator (Playful Flat Style)
                ClipRRect(
                  borderRadius: BorderRadius.circular(8.0),
                  child: SizedBox(
                    height: 10.0,
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      backgroundColor: AppColors.bentoMint.withValues(
                        alpha: 0.2,
                      ),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.bentoMint,
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),

                // Subtext
                Flexible(
                  child: Text(
                    "Vui lòng không đóng ứng dụng",
                    textAlign: TextAlign.center,
                    style: Theme.of(context).textTheme.bodyMedium,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
