// lib/features/home/presentation/screens/app_menu_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:provider/provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../../core/utils/status_navigator.dart';

class AppMenuScreen extends StatelessWidget {
  const AppMenuScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();

    return Scaffold(
      appBar: AppBar(title: const Text("Cài đặt & Tài khoản")),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _buildMenuSection(context, [
            _menuItem(context, CupertinoIcons.person, "Hồ sơ cá nhân", () => Navigator.pushNamed(context, '/profile')),
            _menuItem(context, CupertinoIcons.cloud_upload, "Đồng bộ đám mây", () => _sync(context, auth)),
          ]),
          const SizedBox(height: 16),
          _buildMenuSection(context, [
            _menuItem(context, CupertinoIcons.gear, "Cài đặt ứng dụng", () {}),
            _menuItem(context, CupertinoIcons.info, "Về ứng dụng", () {}),
          ]),
          const SizedBox(height: 32),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red.withOpacity(0.1), foregroundColor: Colors.red, elevation: 0),
            onPressed: () => auth.logout(),
            child: const Text("Đăng xuất"),
          )
        ],
      ),
    );
  }

  Widget _buildMenuSection(BuildContext context, List<Widget> children) {
    return Container(decoration: BoxDecoration(color: Theme.of(context).cardColor, borderRadius: BorderRadius.circular(24)), child: Column(children: children));
  }

  Widget _menuItem(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(leading: Icon(icon), title: Text(title), trailing: const Icon(Icons.chevron_right, size: 16), onTap: onTap);
  }

  void _sync(BuildContext context, AuthProvider auth) async {
    // Logic gọi auth.syncData() giống Sidebar cũ nhưng dùng context mới
  }
}