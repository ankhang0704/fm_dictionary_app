import 'dart:io'; // Bắt buộc phải có để dùng File
import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/services/database/database_service.dart'; // Thêm import này

class ProfileHeader extends StatelessWidget {
  final User user;
  final bool isDark;

  const ProfileHeader({super.key, required this.user, required this.isDark});

  @override
  Widget build(BuildContext context) {
    // 1. Lấy thông tin từ Hive Settings
    final settings = DatabaseService.getSettings();
    final localPath = settings.userAvatarPath;
   final displayName =
        (settings.userName as String?) ??
        'sidebar.no_name'.tr();
    // 2. Kiểm tra ảnh Local có tồn tại không
    final bool hasLocalPhoto =
        localPath != null && File(localPath).existsSync();

    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.accentColor.withValues(alpha: 0.3),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 56,
            backgroundColor: isDark
                ? AppConstants.darkCardColor
                : Colors.grey.withValues(alpha: 0.1),
            // ƯU TIÊN 1: Ảnh Local từ máy
            // ƯU TIÊN 2: Ảnh từ Firebase (nếu có)
            backgroundImage: hasLocalPhoto
                ? FileImage(File(localPath)) as ImageProvider
                : (user.photoURL != null ? NetworkImage(user.photoURL!) : null),
            child: (!hasLocalPhoto && user.photoURL == null)
                ? Text(
                    displayName.isNotEmpty ? displayName[0].toUpperCase() : "U",
                    style: AppConstants.headingStyle.copyWith(
                      fontSize: 40,
                      color: AppConstants.accentColor,
                    ),
                  )
                : null,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          displayName,
          textAlign: TextAlign.center,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        const SizedBox(height: 4),
        Text(
          user.email ?? '',
          textAlign: TextAlign.center,
          style: AppConstants.bodyStyle.copyWith(
            fontSize: 14,
            color: AppConstants.textSecondary,
          ),
        ),
      ],
    );
  }
}
