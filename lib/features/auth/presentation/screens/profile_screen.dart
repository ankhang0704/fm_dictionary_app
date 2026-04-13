// Đường dẫn: lib/features/auth/presentation/screens/profile_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';
import '../../../../core/constants/constants.dart';
import 'change_password_screen.dart';
import '../widgets/statistics_bento.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // UI sẽ tự động vẽ lại nếu Avatar đổi, hoặc User đăng xuất
    final authProvider = context.watch<AuthProvider>(); 
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Hồ sơ cá nhân'), centerTitle: true),
      body: SafeArea(
        // CẤU TRÚC BENTO GRID SKELETON
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Box 1: Avatar & Info (Trải dài)
                  _buildProfileHeaderBento(context, user, authProvider),
                  const SizedBox(height: 16),
                  
                  // Box 2: Thống kê (Grid ngang)
                  const StatisticsSectionBento(), // Widget cũ của bạn được chỉnh lại UI
                  const SizedBox(height: 16),
                  
                  // Box 3: Cài đặt tài khoản (List)
                  _buildSettingsBento(context, isDark),
                  const SizedBox(height: 24),
                  
                  // Box 4: Nút Xóa tài khoản (Khu vực Danger)
                  _buildDangerZoneBento(context, authProvider),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- CÁC WIDGET BENTO CON ---
  Widget _buildProfileHeaderBento(BuildContext context, user, AuthProvider provider) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          CircleAvatar(radius: 50, backgroundImage: NetworkImage(user.photoURL ?? '')), // Thay thế logic lấy ảnh
          TextButton.icon(
            icon: const Icon(CupertinoIcons.camera),
            label: const Text("Đổi ảnh"),
            onPressed: () {
               // Chỗ này gọi ImagePicker, sau đó gọi provider.updateAvatar(path)
            },
          ),
          Text(user.email ?? '', style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildSettingsBento(BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(24),
      ),
      child: Column(
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.lock),
            title: const Text("Đổi mật khẩu"),
            trailing: const Icon(CupertinoIcons.chevron_right),
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ChangePasswordScreen())),
          ),
          const Divider(height: 1),
          ListTile(
            leading: const Icon(CupertinoIcons.calendar),
            title: const Text("Ngày tham gia"),
            trailing: const Text("12/10/2023"), // Format joinDate
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneBento(BuildContext context, AuthProvider provider) {
    return OutlinedButton.icon(
      style: OutlinedButton.styleFrom(
        foregroundColor: Colors.red,
        padding: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(24)),
      ),
      icon: const Icon(CupertinoIcons.trash),
      label: const Text("Xóa tài khoản"),
      onPressed: () async {
        // Logic show dialog xác nhận mật khẩu
        // Sau đó gọi: provider.deleteAccount(password);
        // Cuối cùng: StatusNavigator.showSuccess(context, title: "Đã xóa", message: "Tạm biệt bạn!");
      },
    );
  }
}
