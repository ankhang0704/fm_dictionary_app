import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../../services/auth_sync_service.dart';

class CustomSideBar extends StatelessWidget {
  const CustomSideBar({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Drawer(
      backgroundColor: theme.scaffoldBackgroundColor,
      child: Column(
        children:[
          // HEADER: Lắng nghe trạng thái Auth
          ValueListenableBuilder<User?>(
            valueListenable: AuthSyncService.instance.currentUser,
            builder: (context, user, _) {
              final isLoggedIn = user != null;
              
              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: theme.colorScheme.primary),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: theme.colorScheme.onPrimary,
                  backgroundImage: isLoggedIn && user.photoURL != null
                      ? NetworkImage(user.photoURL!) // Có thể thay bằng CachedNetworkImageProvider
                      : null,
                  onBackgroundImageError: (_, __) {}, // Tránh crash nếu link ảnh hỏng
                  child: isLoggedIn && user.photoURL == null
                      ? Text(user.displayName?[0].toUpperCase() ?? 'U', style: const TextStyle(fontSize: 24))
                      : (!isLoggedIn ? const Icon(Icons.person, size: 40) : null),
                ),
                accountName: Text(
                  isLoggedIn ? (user.displayName ?? 'sidebar.no_name'.tr()) : 'sidebar.guest'.tr(),
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text(isLoggedIn ? (user.email ?? '') : 'sidebar.login_desc'.tr()),
              );
            },
          ),

          // LIST MENU
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children:[
                _buildMenuItem(Icons.person_outline, 'sidebar.profile'.tr(), () {}),
                _buildMenuItem(Icons.sync_rounded, 'sidebar.sync'.tr(), () async {
                  // Gọi Sync & Xử lý lỗi UI
                  try {
                    await AuthSyncService.instance.backupProgress();
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('sidebar.sync_success'.tr())));
                  } catch (e) {
                    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('sidebar.sync_fail'.tr()), backgroundColor: Colors.red));
                  }
                }),
                const Divider(),
                _buildMenuItem(Icons.feedback_outlined, 'sidebar.feedback'.tr(), () {}),
                _buildMenuItem(Icons.share_outlined, 'sidebar.share'.tr(), () {}),
                _buildMenuItem(Icons.privacy_tip_outlined, 'sidebar.privacy'.tr(), () {}),
                _buildMenuItem(Icons.description_outlined, 'sidebar.terms'.tr(), () {}),
              ],
            ),
          ),

          // FOOTER: Nút Login/Logout & Version
          ValueListenableBuilder<User?>(
            valueListenable: AuthSyncService.instance.currentUser,
            builder: (context, user, _) {
              return Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children:[
                    ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        minimumSize: const Size.infinity, 45),
                        backgroundColor: user != null ? Colors.red.shade100 : theme.colorScheme.primaryContainer,
                        foregroundColor: user != null ? Colors.red : theme.colorScheme.onPrimaryContainer,
                      ),
                      icon: Icon(user != null ? Icons.logout : Icons.login),
                      label: Text(user != null ? 'sidebar.logout'.tr() : 'sidebar.login'.tr()),
                      onPressed: () => user != null ? AuthSyncService.instance.signOut() : AuthSyncService.instance.signInWithGoogle(),
                    ),
                    const SizedBox(height: 12),
                    Text('v1.0.1', style: TextStyle(color: theme.textTheme.bodySmall?.color?.withOpacity(0.5), fontSize: 12)),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Widget _buildMenuItem(IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon),
      title: Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}