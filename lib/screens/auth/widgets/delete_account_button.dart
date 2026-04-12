import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/auth/auth_sync_service.dart';

class DeleteAccountButton extends StatelessWidget {
  final User user;

  const DeleteAccountButton({super.key, required this.user});

   Future<String?> _showPasswordConfirmDialog(
    BuildContext context,
    bool isDark,
  ) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppConstants.darkCardColor : Colors.white,
        title: const Text("Xác nhận mật khẩu"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              "Vui lòng nhập mật khẩu của bạn để hoàn tất việc xóa tài khoản.",
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: "Mật khẩu",
                border: OutlineInputBorder(),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.errorColor,
            ),
            onPressed: () => Navigator.pop(ctx, controller.text),
            child: const Text(
              "Xác nhận xóa",
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
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
    if(!context.mounted) return;
    final password = await _showPasswordConfirmDialog(context, isDark);
    if (password == null || password.isEmpty) return;

    // BƯỚC 3: THỰC HIỆN XÓA
    try {
      // Hiện loading
      if (!context.mounted) return;
      showDialog(
        context: context,
        builder: (_) => const Center(child: CircularProgressIndicator()),
      );

      // Gọi hàm xóa đã viết ở AuthSyncService
      await AuthSyncService.instance.deleteAccount(password);

      if (!context.mounted) return;

      // Đóng loading và quay về màn hình đầu tiên (Welcome/Login)
      Navigator.of(context).popUntil((route) => route.isFirst);
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Đóng loading nếu lỗi
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: AppConstants.errorColor,
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
