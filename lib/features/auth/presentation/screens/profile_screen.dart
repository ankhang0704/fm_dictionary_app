// Đường dẫn: lib/features/auth/presentation/screens/profile_screen.dart
import 'package:flutter/material.dart';
import 'package:fm_dictionary/features/auth/presentation/widgets/delete_account_section.dart';
import 'package:fm_dictionary/features/auth/presentation/widgets/profile_header.dart';
import 'package:fm_dictionary/features/auth/presentation/widgets/profile_settings_list.dart';
import 'package:fm_dictionary/features/gamification/presentation/widgets/badges_bento.dart';
import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../../../../core/constants/constants.dart';
import '../widgets/statistics_bento.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // context.watch sẽ tự động lắng nghe. Bất cứ khi nào AuthProvider gọi notifyListeners()
    // (như lúc đổi ảnh xong), màn hình này sẽ tự vẽ lại mà không cần setState!
    final authProvider = context.watch<AuthProvider>();
    final user = authProvider.currentUser;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(title: const Text('Hồ sơ cá nhân'), centerTitle: true),
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverPadding(
              padding: const EdgeInsets.all(16.0),
              sliver: SliverList(
                delegate: SliverChildListDelegate([
                  // Box 1: Avatar, Name & Email
                  buildProfileHeaderBento(context, user, authProvider, isDark),
                  const SizedBox(height: 16),

                  // Box 2: Thống kê
                  const StatisticsSectionBento(),
                  const SizedBox(height: 16),
                  // BOX MỚI: BỘ SƯU TẬP HUY HIỆU (Thêm vào đây)
                  const BadgesBento(),
                  const SizedBox(height: 16),

                  // Box 3: Cài đặt tài khoản
                  buildSettingsBento(context, user),
                  const SizedBox(height: 24),

                  // Box 4: Nút Xóa tài khoản
                  buildDangerZoneBento(context, authProvider, isDark),
                ]),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
