import 'dart:io';

import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/database/database_service.dart';

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

// lib/screens/sidebar/widgets/sidebar_header.dart

class _Avatar extends StatelessWidget {
  final User? user;
  final bool isDark;
  const _Avatar({required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // Lấy path từ Hive
    final settings = DatabaseService.getSettings();
    final localAvatarPath = settings.userAvatarPath;
    final String displayName = settings.userName.isNotEmpty ? settings.userName : (user?.displayName ?? '');

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
        // KIỂM TRA: Nếu có path local và file tồn tại
        backgroundImage:
            (localAvatarPath != null && File(localAvatarPath).existsSync())
            ? FileImage(File(localAvatarPath))
            : null,
        child: (localAvatarPath == null || !File(localAvatarPath).existsSync())
            ? Text(
                displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 24,
                  color: AppConstants.accentColor,
                ),
              )
            : null,
      ),
    );
  }
}
