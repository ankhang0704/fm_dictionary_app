import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';

class SidebarHeader extends StatelessWidget {
  final User? user;
  final bool isDark;

  const SidebarHeader({super.key, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final isLoggedIn = user != null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _Avatar(user: user, isDark: isDark),
          const SizedBox(height: 16),
          Text(
            isLoggedIn
                ? (user!.displayName ?? 'sidebar.no_name'.tr())
                : 'sidebar.guest'.tr(),
            style: AppConstants.headingStyle.copyWith(
              fontSize: 22,
              fontStyle: FontStyle.normal,
              color: isDark ? Colors.white : AppConstants.textPrimary,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            isLoggedIn ? (user!.email ?? '') : 'sidebar.login_desc'.tr(),
            style: AppConstants.bodyStyle.copyWith(
              fontSize: 14,
              color: AppConstants.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _Avatar extends StatelessWidget {
  final User? user;
  final bool isDark;

  const _Avatar({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final hasPhoto = user?.photoURL != null && user!.photoURL!.isNotEmpty;

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        border: Border.all(
          color: AppConstants.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: CircleAvatar(
        radius: 32,
        backgroundColor: isDark
            ? AppConstants.darkCardColor
            : Colors.grey.withValues(alpha: 0.1),
        backgroundImage: hasPhoto ? NetworkImage(user!.photoURL!) : null,
        onBackgroundImageError: hasPhoto ? (_, _) {} : null,
        child: !hasPhoto
            ? Text(
                user?.displayName?.isNotEmpty == true
                    ? user!.displayName![0].toUpperCase()
                    : 'U',
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 24,
                  fontStyle: FontStyle.normal,
                  color: AppConstants.accentColor,
                ),
              )
            : null,
      ),
    );
  }
}
