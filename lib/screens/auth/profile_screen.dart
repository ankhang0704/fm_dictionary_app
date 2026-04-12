// file: lib/screens/profile/profile_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fm_dictionary/screens/auth/change_password_screen.dart';
import 'package:fm_dictionary/screens/auth/widgets/delete_account_button.dart';
import 'package:fm_dictionary/screens/auth/widgets/infotile_widget.dart';
import 'package:fm_dictionary/screens/auth/widgets/profile_header_widget.dart';
import 'package:fm_dictionary/screens/auth/widgets/statistics_widget.dart';
import 'package:fm_dictionary/services/database/database_service.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/auth/auth_sync_service.dart';
import '../../core/constants/constants.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'profile.title'.tr(),
          style: AppConstants.headingStyle.copyWith(
            fontSize: 24,
            fontStyle: FontStyle.normal,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      body: ValueListenableBuilder<User?>(
        valueListenable: AuthSyncService.instance.currentUser,
        builder: (context, user, _) {
          if (user == null) {
            return Center(
              child: Text(
                'profile.not_logged_in'.tr(),
                style: AppConstants.bodyStyle.copyWith(color: AppConstants.textSecondary),
              ),
            );
          }

          final joinDate = user.metadata.creationTime != null
              ? DateFormat('dd/MM/yyyy').format(user.metadata.creationTime!)
              : '--';

          return SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                ProfileHeader(user: user, isDark: isDark),
                const SizedBox(height: 32),
                const SizedBox(height: 16),
                InfoTile(
                  icon: CupertinoIcons.lock_shield,
                  title: 'profile.change_password'.tr(),
                  value: '••••••••',
                  isDark: isDark,
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const ChangePasswordScreen(),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                InfoTile(
                  icon: CupertinoIcons.photo_camera,
                  title: 'Thay đổi ảnh đại diện',
                  value: 'Chọn ảnh',
                  isDark: isDark,
                  onTap: () => _showAvatarPicker(context),
                ),
                const StatisticsSection(),
                const SizedBox(height: 24),
                InfoTile(
                  icon: CupertinoIcons.calendar,
                  title: 'profile.join_date'.tr(),
                  value: joinDate,
                  isDark: isDark,
                  onTap: () {},
                ),
                const SizedBox(height: 48),
                DeleteAccountButton(user: user),
              ],
            ),
          );
        },
      ),
    );
  }
}



void _showAvatarPicker(BuildContext context) {
  showModalBottomSheet(
    context: context,
    builder: (context) => SafeArea(
      child: Wrap(
        children: [
          ListTile(
            leading: const Icon(Icons.photo_library),
            title: const Text('Chọn từ thư viện'),
            onTap: () async {
              final ImagePicker picker = ImagePicker();
              final XFile? image = await picker.pickImage(
                source: ImageSource.gallery,
              );

              if (image != null) {
                // LƯU PATH VÀO HIVE
                var settings = DatabaseService.getSettings();
                settings.userAvatarPath =
                    image.path; // Giả sử model Settings có trường này
                await DatabaseService.saveSettings(settings);

                if (context.mounted) Navigator.pop(context);
              }
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: Colors.red),
            title: const Text('Xóa ảnh đại diện'),
            onTap: () async {
              var settings = DatabaseService.getSettings();
              settings.userAvatarPath = null; // Xóa path
              await DatabaseService.saveSettings(settings);
              if (context.mounted) Navigator.pop(context);
            },
          ),
        ],
      ),
    ),
  );
}





