// Đường dẫn: lib/features/home/presentation/widgets/left_sidebar.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/screens/profile_screen.dart';
// Các import khác...

class LeftSidebar extends StatelessWidget {
  const LeftSidebar({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final bgColor = isDark ? Colors.grey[900] : Colors.grey[100];

    return Drawer(
      backgroundColor: bgColor,
      child: SafeArea(
        child: Column(
          children: [
            // BENTO HEADER: User Info
            _buildHeaderBento(context, user, isDark),
            
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                physics: const BouncingScrollPhysics(),
                children: [
                  // BENTO BOX 1: Cá nhân & Đồng bộ
                  _buildMenuGroup(context, [
                    _buildMenuItem(CupertinoIcons.person, 'Hồ sơ cá nhân', () {
                      Navigator.pop(context);
                      Navigator.push(context, CupertinoPageRoute(builder: (_) => const ProfileScreen()));
                    }),
                    _buildMenuItem(CupertinoIcons.arrow_2_circlepath, 'Đồng bộ dữ liệu', () {}),
                  ]),
                  const SizedBox(height: 16),

                  // BENTO BOX 2: Thông tin & Trợ giúp
                  _buildMenuGroup(context, [
                    _buildMenuItem(CupertinoIcons.chat_bubble_text, 'Phản hồi', () {}),
                    _buildMenuItem(CupertinoIcons.share, 'Chia sẻ ứng dụng', () {}),
                    _buildMenuItem(CupertinoIcons.shield, 'Chính sách bảo mật', () {}),
                  ]),
                  const SizedBox(height: 16),

                  // BENTO BOX 3: Cài đặt
                  _buildMenuGroup(context, [
                    _buildMenuItem(CupertinoIcons.gear_solid, 'Cài đặt hệ thống', () {}),
                  ]),
                ],
              ),
            ),
            
            // BENTO FOOTER: Nút Đăng nhập/Đăng xuất
            _buildFooterBento(context, user),
          ],
        ),
      ),
    );
  }

  // --- CÁC HÀM XÂY DỰNG GIAO DIỆN BENTO NỘI BỘ ---

 Widget _buildHeaderBento(BuildContext context, user, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(24),
      width: double.infinity,
      color: Theme.of(context).cardColor,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children:[
          CircleAvatar(
            radius: 32,
            // Dùng dấu ? thay vì ! để an toàn tuyệt đối
            backgroundImage: user?.photoURL != null ? NetworkImage(user?.photoURL) : null,
            child: user?.photoURL == null ? const Icon(CupertinoIcons.person) : null,
          ),
          const SizedBox(height: 16),
          Text(user?.displayName ?? 'Khách', style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
          Text(user?.email ?? 'Vui lòng đăng nhập', style: const TextStyle(color: Colors.grey)),
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
      trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: Colors.grey),
      onTap: onTap,
    );
  }

  Widget _buildFooterBento(BuildContext context, user) {
    final isLoggedIn = user != null;
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        children: [
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              minimumSize: const Size(double.infinity, 50),
              backgroundColor: isLoggedIn ? Colors.red.withOpacity(0.1) : Colors.blue.withOpacity(0.1),
              foregroundColor: isLoggedIn ? Colors.red : Colors.blue,
              elevation: 0,
            ),
            icon: Icon(isLoggedIn ? CupertinoIcons.square_arrow_right : CupertinoIcons.square_arrow_left),
            label: Text(isLoggedIn ? "Đăng xuất" : "Đăng nhập"),
            onPressed: () {
               // Gọi provider.logout() hoặc điều hướng sang LoginScreen
            },
          ),
          const SizedBox(height: 8),
          FutureBuilder<PackageInfo>(
            future: PackageInfo.fromPlatform(),
            builder: (context, snapshot) {
              return Text('Phiên bản ${snapshot.data?.version ?? '...'}', style: const TextStyle(color: Colors.grey, fontSize: 12));
            },
          ),
        ],
      ),
    );
  }
}