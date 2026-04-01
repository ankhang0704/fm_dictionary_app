import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/auth/auth_sync_service.dart';

class SidebarItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const SidebarItem({
    super.key,
    required this.icon,
    required this.title,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ListTile(
      onTap: onTap,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      leading: Icon(
        icon,
        size: 24,
        color: isDark ? Colors.white70 : AppConstants.textSecondary,
      ),
      title: Text(
        title,
        style: AppConstants.bodyStyle.copyWith(
          fontSize: 15,
          fontWeight: FontWeight.w500,
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}

class SidebarFooter extends StatelessWidget {
  final User? user;
  final bool isDark;

  const SidebarFooter({super.key, required this.user, required this.isDark});

  Future<void> _handleAuth(BuildContext context, bool isLoggedIn) async {
    if (isLoggedIn) {
      await AuthSyncService.instance.signOut();
    } else {
      try {
        await AuthSyncService.instance.signInWithGoogle();
      } catch (e) {
        if (!context.mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text("Lỗi xác thực"),
            backgroundColor: AppConstants.errorColor,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;

    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        children: [
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton.icon(
              style: ElevatedButton.styleFrom(
                backgroundColor: isLoggedIn
                    ? AppConstants.errorColor.withValues(alpha: 0.1)
                    : AppConstants.accentColor.withValues(alpha: 0.1),
                foregroundColor: isLoggedIn
                    ? AppConstants.errorColor
                    : AppConstants.accentColor,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(
                    AppConstants.buttonRadius,
                  ),
                ),
              ),
              icon: Icon(
                isLoggedIn
                    ? CupertinoIcons.square_arrow_right
                    : CupertinoIcons.square_arrow_left,
              ),
              label: Text(
                isLoggedIn ? "sidebar.logout".tr() : "sidebar.login".tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              onPressed: () => _handleAuth(context, isLoggedIn),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'v1.0.1',
            style: AppConstants.bodyStyle.copyWith(
              fontSize: 12,
              color: AppConstants.textLight,
            ),
          ),
        ],
      ),
    );
  }
}
