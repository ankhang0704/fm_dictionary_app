// lib/features/home/presentation/screens/menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:provider/provider.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:package_info_plus/package_info_plus.dart';

import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/utils/status_navigator.dart';
import '../../../../core/widgets/common/app_avatar.dart';

class MenuScreen extends StatelessWidget {
  const MenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.currentUser;
    final settings = DatabaseService.getSettings();
    final currentLocale = context.locale.languageCode;

    return Scaffold(
      appBar: AppBar(title: Text("sidebar.settings".tr()), centerTitle: true),
      body: ListView(
        padding: const EdgeInsets.all(16),
        physics: const BouncingScrollPhysics(),
        children: [
          // 1. ACCOUNT BENTO BOX
          _buildMenuBox(context, [
            ListTile(
              leading: AppAvatar(
                localPath: settings.userAvatarPath,
                networkUrl: user?.photoURL,
                radius: 20,
              ),
              title: Text(
                user?.displayName ?? 'sidebar.guest'.tr(),
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(user?.email ?? 'sidebar.login_desc'.tr()),
              trailing: const Icon(Icons.chevron_right),
              onTap: () => Navigator.pushNamed(context, AppRoutes.profile),
            ),
            const Divider(indent: 70),
            _menuItem(
              CupertinoIcons.arrow_2_circlepath,
              'sidebar.sync'.tr(),
              () => _handleSync(context),
            ),
          ]),

          const SizedBox(height: 16),

          // 2. APP INFO & CONTENT BENTO BOX (Kế thừa từ LeftSidebar)
          _buildMenuBox(context, [
            _menuItem(
              CupertinoIcons.chat_bubble_text,
              'sidebar.feedback'.tr(),
              () => _navigateToStatic(
                context,
                'sidebar.feedback'.tr(),
                'feedback_$currentLocale.md',
              ),
            ),
            _menuItem(
              CupertinoIcons.share,
              'sidebar.share'.tr(),
              () => _navigateToStatic(
                context,
                'sidebar.share'.tr(),
                'share_$currentLocale.md',
              ),
            ),
            _menuItem(
              CupertinoIcons.shield_lefthalf_fill,
              'sidebar.privacy'.tr(),
              () => _navigateToStatic(
                context,
                'sidebar.privacy'.tr(),
                'privacy_$currentLocale.md',
              ),
            ),
            _menuItem(
              CupertinoIcons.doc_text,
              'sidebar.terms'.tr(),
              () => _navigateToStatic(
                context,
                'sidebar.terms'.tr(),
                'terms_$currentLocale.md',
              ),
            ),
            _menuItem(
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

          // 3. SETTINGS BENTO BOX
          _buildMenuBox(context, [
            _menuItem(
              CupertinoIcons.gear_solid,
              'sidebar.settings'.tr(),
              () => Navigator.pushNamed(context, AppRoutes.settings),
            ),
          ]),

          const SizedBox(height: 32),

          // 4. FOOTER: LOGOUT & VERSION
          Column(
            children: [
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  minimumSize: const Size(double.infinity, 50),
                  backgroundColor: Colors.red.withOpacity(0.1),
                  foregroundColor: Colors.red,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                icon: const Icon(CupertinoIcons.square_arrow_right),
                label: Text(
                  user != null ? "sidebar.logout".tr() : "sidebar.login".tr(),
                ),
                onPressed: () => user != null
                    ? auth.logout()
                    : Navigator.pushNamed(context, AppRoutes.login),
              ),
              const SizedBox(height: 16),
              FutureBuilder<PackageInfo>(
                future: PackageInfo.fromPlatform(),
                builder: (context, snapshot) {
                  return Text(
                    'Version ${snapshot.data?.version ?? '1.0.0'}',
                    style: const TextStyle(color: Colors.grey, fontSize: 13),
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        ],
      ),
    );
  }

  // --- HELPER WIDGETS ---

  Widget _buildMenuBox(BuildContext context, List<Widget> children) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.withOpacity(0.1)),
      ),
      child: Column(children: children),
    );
  }

  Widget _menuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 15)),
      trailing: const Icon(Icons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  // --- LOGIC HANDLING (Kế thừa từ Sidebar cũ) ---

  void _navigateToStatic(BuildContext context, String title, String fileName) {
    Navigator.pushNamed(
      context,
      AppRoutes.staticContent,
      arguments: {'title': title, 'mdFileName': fileName},
    );
  }

   Future<void> _handleSync(BuildContext context) async {
    final authProvider = context.read<AuthProvider>();

    // BƯỚC 1: KIỂM TRA TRƯỚC KHI CHẠY (PRE-CHECK)
    if (authProvider.currentUser == null) {
      _showLoginRequiredDialog(context);
      return;
    }

    // BƯỚC 2: HIỂN THỊ LOADING NẾU ĐÃ ĐĂNG NHẬP
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator.adaptive()),
    );

    try {
      await authProvider.syncData();
      
      if (!context.mounted) return;
      // Đóng Loading Dialog
      Navigator.of(context, rootNavigator: true).pop();

      // Hiện thông báo thành công dùng chung
      StatusNavigator.showSuccess(
        context,
        title: "Sync Successful",
        message: "Your learning progress has been successfully synced with the cloud.",
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

  // Hàm bổ sung: Hiện Dialog yêu cầu đăng nhập thay vì Snackbar đơn điệu
  void _showLoginRequiredDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Yêu cầu đăng nhập"),
        content: const Text("Bạn cần đăng nhập để sử dụng tính năng đồng bộ đám mây và bảo vệ tiến trình học tập."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Để sau", style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.primaryColor,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              Navigator.pop(ctx); // Đóng dialog
              Navigator.pushNamed(context, AppRoutes.login); // Nhảy sang trang Login
            },
            child: const Text("Đăng nhập ngay", style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  String _getFriendlyErrorMessage(dynamic error) {
    final errorString = error.toString().toLowerCase();
    if (errorString.contains('network') || errorString.contains('socket')) {
      return "Network connection error. Check your internet.";
    } else if (errorString.contains('not_logged_in')) {
      return "Please login to sync data.";
    }
    return "System Error: ${error.toString()}";
  }
}
