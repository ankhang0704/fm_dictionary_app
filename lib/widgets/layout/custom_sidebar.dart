import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fm_dictionary/screens/auth/profile_screen.dart';
import 'package:fm_dictionary/screens/info/static_content_screen.dart';
import '../../services/auth/auth_sync_service.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children: [
          // 1. HEADER (Lắng nghe Auth để cập nhật thông tin)
          ValueListenableBuilder<User?>(
            valueListenable: AuthSyncService.instance.currentUser,
            builder: (context, user, _) => _buildHeader(context, user, theme),
          ),

          // 2. LIST MENU (Các nút chức năng tĩnh)
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildMenuItem(
                  Icons.person_outline,
                  'sidebar.profile'.tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const ProfileScreen()),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.sync_rounded,
                  'sidebar.sync'.tr(),
                  () => _handleSync(context), // Tách logic ra hàm riêng
                ),
                const Divider(),
                _buildMenuItem(
                  Icons.feedback_outlined,
                  'sidebar.feedback'.tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaticContentScreen(
                          titleKey: 'sidebar.feedback',
                          contentKey: 'content.feedback_text',
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuItem(Icons.share_outlined, 'sidebar.share'.tr(), () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const StaticContentScreen(
                        titleKey: 'sidebar.share',
                        contentKey: 'content.share_text',
                      ),
                    ),
                  );
                }),
                _buildMenuItem(
                  Icons.privacy_tip_outlined,
                  'sidebar.privacy'.tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaticContentScreen(
                          titleKey: 'sidebar.privacy',
                          contentKey: 'content.privacy_text',
                        ),
                      ),
                    );
                  },
                ),
                _buildMenuItem(
                  Icons.description_outlined,
                  'sidebar.terms'.tr(),
                  () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const StaticContentScreen(
                          titleKey: 'sidebar.terms',
                          contentKey: 'content.terms_text',
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),

          // 3. FOOTER (Lắng nghe Auth để đổi trạng thái nút Login/Logout)
          ValueListenableBuilder<User?>(
            valueListenable: AuthSyncService.instance.currentUser,
            builder: (context, user, _) => _buildFooter(context, user, theme),
          ),
        ],
      ),
    );
  }

  // ==================== CÁC HÀM XÂY DỰNG GIAO DIỆN ====================

  Widget _buildHeader(BuildContext context, User? user, ThemeData theme) {
    final isLoggedIn = user != null;

    return UserAccountsDrawerHeader(
      decoration: BoxDecoration(color: theme.colorScheme.primary),
      currentAccountPicture: _buildAvatar(user, theme),
      accountName: Text(
        isLoggedIn
            ? (user.displayName ?? 'sidebar.no_name'.tr())
            : 'sidebar.guest'.tr(),
        style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
      ),
      accountEmail: Text(
        isLoggedIn ? (user.email ?? '') : 'sidebar.login_desc'.tr(),
      ),
    );
  }

  /// Khắc phục hoàn toàn lỗi Avatar: Chỉ dùng NetworkImage khi chắc chắn có link ảnh hợp lệ
  Widget _buildAvatar(User? user, ThemeData theme) {
    final isLoggedIn = user != null;
    final hasPhoto =
        isLoggedIn && user.photoURL != null && user.photoURL!.isNotEmpty;

    if (hasPhoto) {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.onPrimary,
        backgroundImage: NetworkImage(user.photoURL!),
        onBackgroundImageError: (_, _) {}, // Tránh crash UI nếu link lỗi
      );
    } else if (isLoggedIn) {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.onPrimary,
        child: Text(
          user.displayName?.isNotEmpty == true
              ? user.displayName![0].toUpperCase()
              : 'U',
          style: const TextStyle(fontSize: 24),
        ),
      );
    } else {
      return CircleAvatar(
        backgroundColor: theme.colorScheme.onPrimary,
        child: const Icon(Icons.person, size: 40),
      );
    }
  }

  Widget _buildMenuItem(
    IconData icon,
    String title,
    VoidCallback onTap, {
    String? subtitle,
  }) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      subtitle: subtitle != null
          ? Text(
              subtitle,
              style: const TextStyle(fontSize: 12, color: Colors.grey),
            )
          : null,
      onTap: onTap,
    );
  }

  Widget _buildFooter(BuildContext context, User? user, ThemeData theme) {
    final isLoggedIn = user != null;

    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 45),
              backgroundColor: isLoggedIn
                  ? Colors.red.shade100
                  : theme.colorScheme.primaryContainer,
              foregroundColor: isLoggedIn
                  ? Colors.red
                  : theme.colorScheme.onPrimaryContainer,
            ),
            icon: Icon(isLoggedIn ? Icons.logout : Icons.login),
            label: Text(
              isLoggedIn ? "sidebar.logout".tr() : "sidebar.login".tr(),
            ),
            onPressed: () => _handleAuth(context, isLoggedIn),
          ),
          const SizedBox(height: 12),
          Text(
            'v1.0.1',
            style: TextStyle(
              color: theme.textTheme.bodySmall?.color?.withValues(alpha: 0.5),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }

  // ==================== CÁC HÀM XỬ LÝ LOGIC CHUYÊN SÂU ====================

  /// Hàm xử lý Sync an toàn với context
  Future<void> _handleSync(BuildContext context) async {
    // Hiện Loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (_) => const Center(child: CircularProgressIndicator()),
    );

    try {
      await AuthSyncService.instance.syncDataWithMerge();

      if (!context.mounted) return;
      Navigator.pop(context); // Đóng Dialog Loading

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('sidebar.sync_success'.tr()),
          backgroundColor: Colors.green,
        ),
      );
    } catch (e) {
      if (!context.mounted) return;
      Navigator.pop(context); // Đóng Dialog Loading dù lỗi

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(_getFriendlyErrorMessage(e)),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  /// Hàm xử lý Đăng nhập/Đăng xuất an toàn với context
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
            content: Text(_getFriendlyErrorMessage(e)),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// Xử lý bóc tách thông báo lỗi thân thiện thay vì in ra `Exception...`
  String _getFriendlyErrorMessage(dynamic error) {
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
    return "Đã xảy ra lỗi hệ thống. Vui lòng thử lại sau.";
  }
}
