// =======================================================================
// 1. BENTO HEADER (AVATAR, NAME, EMAIL) & LOGIC CHỌN ẢNH
// =======================================================================
import 'dart:io';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/features/auth/presentation/providers/auth_provider.dart';
import 'package:image_picker/image_picker.dart';

Widget buildProfileHeaderBento(
  BuildContext context,
  user,
  AuthProvider provider,
  bool isDark,
) {
  // Lấy thông tin từ Local Hive
  final settings = DatabaseService.getSettings();
  final localPath = settings.userAvatarPath;
  final displayName = user.displayName ?? settings.userName;
  final bool hasLocalPhoto = localPath != null && File(localPath).existsSync();

  return Container(
    padding: const EdgeInsets.all(20),
    decoration: BoxDecoration(
      color: Theme.of(context).cardColor,
      borderRadius: BorderRadius.circular(24),
    ),
    child: Column(
      children: [
        Container(
          padding: const EdgeInsets.all(4),
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(
              color: AppConstants.accentColor.withOpacity(0.3),
              width: 3,
            ),
          ),
          child: CircleAvatar(
            radius: 50,
            backgroundColor: isDark
                ? AppConstants.darkCardColor
                : Colors.grey.withOpacity(0.1),
            // Ưu tiên 1: Local Path | Ưu tiên 2: Firebase URL
            backgroundImage: hasLocalPhoto
                ? FileImage(File(localPath)) as ImageProvider
                : (user.photoURL != null ? NetworkImage(user.photoURL) : null),
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

        TextButton.icon(
          icon: const Icon(CupertinoIcons.camera),
          label: const Text("Đổi ảnh"),
          onPressed: () =>
              _showAvatarPicker(context, provider), // Gọi Bottom Sheet
        ),

        // Bổ sung Hiển thị Tên người dùng
        Text(
          displayName.isNotEmpty ? displayName : "Người dùng",
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
        ),
        Text(
          user.email ?? '',
          style: const TextStyle(color: Colors.grey, fontSize: 14),
        ),
      ],
    ),
  );
}

void _showAvatarPicker(BuildContext context, AuthProvider provider) {
  showModalBottomSheet(
    context: context,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (dialogContext) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.photo),
            title: const Text('Chọn từ thư viện'),
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );
              if (image != null) {
                // Thay vì setState, ta gọi Provider. Provider sẽ lưu Hive và notifyListeners()
                await provider.updateAvatar(image.path);
              }
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.trash, color: Colors.red),
            title: const Text(
              'Xóa ảnh đại diện',
              style: TextStyle(color: Colors.red),
            ),
            onTap: () async {
              await provider.removeAvatar();
              if (dialogContext.mounted) Navigator.pop(dialogContext);
            },
          ),
        ],
      ),
    ),
  );
}
