// Đường dẫn: lib/features/home/presentation/widgets/left_sidebar.dart

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/features/info/presentation/screens/static_content_screen.dart';
import 'package:fm_dictionary/features/settings/settings_screen.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
import '../../../auth/presentation/screens/login_screen.dart';
import '../../../../core/utils/status_navigator.dart';

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  // --- XỬ LÝ LOGIC ĐỒNG BỘ (SYNC) ---
  Future<void> _handleSync(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();
    // Hiển thị Loading Dialog
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
    );

    try {
      await authProvider.syncData();
      if (!context.mounted) return;

      // 1. CHỈ đóng Loading Dialog
      Navigator.of(context, rootNavigator: true).pop();

      // 2. Mở màn hình Thành công (Nó sẽ đè lên Sidebar)
      StatusNavigator.showSuccess(
        context,
        title: "Sync Successful",
        message:
            "Your learning progress has been successfully synced with the cloud.",
        // Mặc định onPrimaryPressed đã là: Navigator.of(context).popUntil((route) => route.isFirst)
        // Nó sẽ tự động dọn sạch mọi thứ và quay về màn hình đầu tiên!
      );
    } catch (e) {
      if (!context.mounted) return;

      // Đóng Loading Dialog
      Navigator.of(context, rootNavigator: true).pop();

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getFriendlyErrorMessage(e)),
          backgroundColor: Colors.red,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  String _getFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') ||
        errorString.contains('socket') ||
        errorString.contains('unavailable')) {
      return "Network connection error. Will sync when internet is available.";
    } else if (errorString.contains('canceled')) {
      return "Operation cancelled.";
    } else if (errorString.contains('not_logged_in')) {
      return "Please login to sync data.";
    }
    return "System Error: ${error.toString()}";
  }

  // --- HÀM CHUYỂN TRANG TEXT ---
  void _navigateToStatic(
    BuildContext context,
    String titleKey,
    String contentKey,
  ) {
    Navigator.pop(context); // Đóng sidebar
    Navigator.push(
      context,
      CupertinoPageRoute(
        builder: (_) =>
            StaticContentScreen(title: titleKey, mdFileName: contentKey),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[100];
    final currentLocale = context.locale.languageCode;

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            _buildHeaderBento(context, user, isDark),

            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  _buildMenuGroup(context, [
                    _buildMenuItem(
                      CupertinoIcons.person_crop_circle,
                      'sidebar.profile'.tr(),
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const ProfileScreen(),
                          ),
                        );
                      },
                    ),
                    _buildMenuItem(
                      CupertinoIcons.arrow_2_circlepath,
                      'sidebar.sync'.tr(),
                      () => _handleSync(context),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _buildMenuGroup(context, [
                    _buildMenuItem(
                      CupertinoIcons.chat_bubble_text,
                      'sidebar.feedback'.tr(),
                      () => _navigateToStatic(
                        context,
                        'sidebar.feedback'.tr(),
                        'feedback_$currentLocale.md',
                      ),
                    ),
                    _buildMenuItem(
                      CupertinoIcons.share,
                      'sidebar.share'.tr(),
                      () => _navigateToStatic(
                        context,
                        'sidebar.share'.tr(),
                        'share_$currentLocale.md',
                      ),
                    ),
                    _buildMenuItem(
                      CupertinoIcons.shield_lefthalf_fill,
                      'sidebar.privacy'.tr(),
                      () => _navigateToStatic(
                        context,
                        'sidebar.privacy'.tr(),
                        'privacy_$currentLocale.md',
                      ),
                    ),
                    _buildMenuItem(
                      CupertinoIcons.doc_text,
                      'sidebar.terms'.tr(),
                      () => _navigateToStatic(
                        context,
                        'sidebar.terms'.tr(),
                        'terms_$currentLocale.md',
                      ),
                    ),
                    _buildMenuItem(
                      CupertinoIcons.info_circle,
                      'sidebar.about'.tr(),
                      () => _navigateToStatic(
                        context,
                        'sidebar.about'.tr(),
                        'about_$currentLocale.md',
                      ),
                    ),
                  ]),
                  const SizedBox(height: 16),

                  _buildMenuGroup(context, [
                    _buildMenuItem(
                      CupertinoIcons.gear_solid,
                      'sidebar.settings'.tr(),
                      () {
                        Navigator.pop(context);
                        Navigator.push(
                          context,
                          CupertinoPageRoute(
                            builder: (_) => const SettingsScreen(),
                          ),
                        );
                      },
                    ),
                  ]),
                ],
              ),
            ),

            _buildFooterBento(context, authProvider, user),
          ],
        ),
      ),
    );
  }

  // CÁC HÀM XÂY DỰNG GIAO DIỆN BENTO NỘI BỘ
  // (Giữ nguyên như mẻ code trước, chỉ sửa _buildFooterBento)

  Widget _buildHeaderBento(BuildContext context, user, bool isDark) {
    // 1. Lấy đường dẫn ảnh từ Hive thông qua DatabaseService
    final settings = DatabaseService.getSettings();
    final localAvatarPath = settings.userAvatarPath;

    // 2. Kiểm tra file local có thực sự tồn tại trên máy không
    final bool hasLocalPhoto =
        localAvatarPath != null && File(localAvatarPath).existsSync();

    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 32,
            backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
            // LOGIC HIỂN THỊ ẢNH THÔNG MINH:
            backgroundImage: hasLocalPhoto
                ? FileImage(File(localAvatarPath))
                      as ImageProvider // Ưu tiên 1: Ảnh vừa đổi (Local)
                : (user?.photoURL != null
                      ? NetworkImage(
                          user!.photoURL!,
                        ) // Ưu tiên 2: Ảnh từ Firebase
                      : null), // Mặc định: Không có ảnh
            child: (!hasLocalPhoto && user?.photoURL == null)
                ? const Icon(CupertinoIcons.person)
                : null,
          ),
          const SizedBox(height: 16),
          Text(
            user?.displayName ?? 'sidebar.guest'.tr(),
            style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          Text(
            user?.email ?? 'sidebar.login_desc'.tr(),
            style: const TextStyle(color: Colors.grey),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuGroup(BuildContext context, List<Widget> items) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(children: items),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(
        CupertinoIcons.chevron_right,
        size: 16,
        color: Colors.grey,
      ),
      onTap: onTap,
    );
  }

  Widget _buildFooterBento(
    BuildContext context,
    AuthProvider authProvider,
    user,
  ) {
    final isLoggedIn = user != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: isLoggedIn
                  ? Colors.red.withOpacity(0.1)
                  : Colors.blue.withOpacity(0.1),
              foregroundColor: isLoggedIn ? Colors.red : Colors.blue,
              elevation: 0,
            ),
            icon: Icon(
              isLoggedIn
                  ? CupertinoIcons.square_arrow_right
                  : CupertinoIcons.square_arrow_left,
            ),
            label: Text(
              isLoggedIn ? "sidebar.logout".tr() : "sidebar.login".tr(),
            ),
            onPressed: () {
              if (isLoggedIn) {
                authProvider.logout();
              } else {
                Navigator.pop(context);
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (_) => const LoginScreen()),
                );
              }
            },
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return Text(
                'v${snapshot.data?.version ?? '...'}',
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              );
            },
          ),
        ],
      ),
    );
  }
}
