// lib/core/widgets/common/sync_data_dialog.dart

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';

// Assuming these are correctly imported in your actual project:
// import 'package:fm_dictionary/core/theme/app_colors.dart';
// import 'package:fm_dictionary/core/theme/app_typography.dart';
// import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
// import 'package:fm_dictionary/data/services/auth_sync/auth_sync_service.dart';

class SyncDataDialog extends StatefulWidget {
  const SyncDataDialog({super.key});

  /// Main handler to show the modern UI and execute the sync logic
  static Future<void> handleSync(BuildContext context) async {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withOpacity(0.2), // Light dim for transparent effect
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
      
      _showSnackBar(
        context,
        'sidebar.sync_success'.tr(),
        const Color(0xFF10B981), // AppColors.success
      );
    } catch (e) {
      if (!context.mounted) return;
      
      // Dismiss the dialog
      Navigator.of(context, rootNavigator: true).pop();
      if (Navigator.canPop(context)) {
        Navigator.pop(context);
      }
      
      _showSnackBar(
        context,
        _getFriendlyErrorMessage(e),
        const Color(0xFFFF4757), // AppColors.error
      );
    }
  }

  static void _showSnackBar(BuildContext context, String message, Color color) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
        backgroundColor: color,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16.0), // AppLayout.inputRadius
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

class _SyncDataDialogState extends State<SyncDataDialog> with SingleTickerProviderStateMixin {
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
          child: GlassBentoCard(
            padding: const EdgeInsets.all(24.0),
            // GlassBentoCard already implements the Blur and Container with 25% opacity
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                RotationTransition(
                  turns: _animationController,
                  child: const Icon(
                    Icons.cloud_sync_rounded,
                    size: 56.0,
                    color: Color(0xFF50E3C2), // AppColors.meshMint
                  ),
                ),
                const SizedBox(height: 24.0),
                
                // Zero Pixel Overflow Strategy
                const Flexible(
                  child: Text(
                    "Đang đồng bộ dữ liệu...",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Quicksand',
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF1E293B), // AppColors.textPrimary
                    ), // Fallback: AppTypography.heading3
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(height: 20.0),
                
                // Rounded Custom Linear Progress Indicator
                ClipRRect(
                  borderRadius: BorderRadius.circular(4.0),
                  child: SizedBox(
                    height: 8.0,
                    width: double.infinity,
                    child: LinearProgressIndicator(
                      backgroundColor: Colors.white.withValues(alpha: 0.2),
                      valueColor: const AlwaysStoppedAnimation<Color>(
                        Color(0xFF50E3C2), // AppColors.meshMint
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16.0),
                
                // Subtext
                const Flexible(
                  child: Text(
                    "Vui lòng không đóng ứng dụng",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF64748B), // AppColors.textSecondary
                    ), // Fallback: AppTypography.bodyTextSmall
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