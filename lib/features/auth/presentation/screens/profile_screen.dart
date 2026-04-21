import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fm_dictionary/features/gamification/presentation/widgets/glass_badge_widget.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/constants/app_routes.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/widgets/common/app_avatar.dart';

// --- PROVIDERS & SERVICES ---
import '../providers/auth_provider.dart';
import '../../../../data/services/database/database_service.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final gamification = context.watch<GamificationProvider>();
    final user = authProvider.currentUser;
    final settings = DatabaseService.getSettings();

    if (user == null) {
      return const Scaffold(body: Center(child: Text("Vui lòng đăng nhập")));
    }

    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.meshBlue, AppColors.meshPurple, AppColors.meshMint],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildGlassHeader(context),
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppLayout.defaultPadding),
            child: Column(
              children: [
                // SECTION 1: USER IDENTITY HERO
                _buildIdentityHero(context, authProvider, gamification, settings),
                const SizedBox(height: 16),

                // SECTION 2: MINI STATS GRID
                _buildStatsGrid(gamification),
                const SizedBox(height: 16),

                // SECTION 3: BADGES COLLECTION
                _buildBadgesSection(gamification),
                const SizedBox(height: 16),

                // SECTION 4: MENU OPTIONS
                _buildMenuOptions(context),
                const SizedBox(height: 32),

                // BOTTOM ACTION: LOGOUT
                SmartActionButton(
                  text: "Đăng xuất",
                  color: AppColors.error,
                  isGlass: true,
                  onPressed: () => _handleLogout(context, authProvider),
                ),
                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:  0.1),
            elevation: 0,
            centerTitle: true,
            title: Text("Cá nhân", style: AppTypography.heading2),
          ),
        ),
      ),
    );
  }

  Widget _buildIdentityHero(BuildContext context, AuthProvider auth, GamificationProvider gami, dynamic settings) {
    final user = auth.currentUser!;
    // final levelName = _calculateLevelName(gami);
    // final expProgress = (gami.masteredWordsCount % 50) / 50.0; // Assume level every 50 words
    final levelName = "Kim";
    double expProgress = 10;
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          Row(
            children: [
              // Avatar with Glow
              Stack(
                alignment: Alignment.center,
                children: [
                  Container(
                    width: 86, height: 86,
                    decoration: const BoxDecoration(color: Colors.white24, shape: BoxShape.circle),
                  ),
                  AppAvatar(
                    localPath: settings.userAvatarPath,
                    networkUrl: user.photoURL,
                    radius: 40,
                  ),
                  Positioned(
                    bottom: 0, right: 0,
                    child: GestureDetector(
                      onTap: () => _showAvatarPicker(context, auth),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: const BoxDecoration(color: AppColors.meshBlue, shape: BoxShape.circle),
                        child: const Icon(CupertinoIcons.camera_fill, size: 14, color: Colors.white),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              // Name & Level
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Text(user.displayName ?? settings.userName, style: AppTypography.heading2),
                    ),
                    const SizedBox(height: 4),
                    Text("Hạng: $levelName", style: AppTypography.bodyMedium.copyWith(color: AppColors.warning, fontWeight: FontWeight.bold)),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // EXP Progress
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Tiến trình cấp độ", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
                  Text("${(expProgress * 100).toInt()}%", style: AppTypography.bodyMedium.copyWith(fontWeight: FontWeight.bold)),
                ],
              ),
              const SizedBox(height: 8),
              ClipRRect(
                borderRadius: BorderRadius.circular(10),
                child: LinearProgressIndicator(
                  value: expProgress,
                  minHeight: 10,
                  backgroundColor: Colors.white.withValues(alpha:0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(AppColors.meshMint),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(GamificationProvider gami) {
    return Row(
      children: [
        Expanded(
          child: GlassBentoCard(
            onTap: null,
            child: Column(
              children: [
                const Icon(CupertinoIcons.flame_fill, color: AppColors.warning, size: 30),
                const SizedBox(height: 8),
                Text("${gami.recentlyUnlocked} Ngày", style: AppTypography.heading2),
                Text("Chuỗi Streak", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: GlassBentoCard(
            onTap: null,
            child: Column(
              children: [
                const Icon(CupertinoIcons.book_fill, color: AppColors.meshBlue, size: 30),
                const SizedBox(height: 8),
                Text("${gami.badges}", style: AppTypography.heading2),
                Text("Từ vựng", style: AppTypography.bodyMedium.copyWith(color: AppColors.textSecondary)),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(GamificationProvider gami) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Huy hiệu đạt được", style: AppTypography.heading3),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              physics: const BouncingScrollPhysics(),
              itemCount: gami.badges.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (context, index) {
                final badge = gami.badges[index];
                return SizedBox(
                  width: 90,
                  child: GlassBadgeWidget(
                    badgeName: badge.title,
                    icon: badge.icon,
                    isUnlocked: badge.isUnlocked,
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          _buildMenuTile(context, CupertinoIcons.person_fill, "Chỉnh sửa thông tin", () {}),
          const Divider(color: Colors.white10, height: 1),
          _buildMenuTile(context, CupertinoIcons.bell_fill, "Cài đặt thông báo", () => Navigator.pushNamed(context, AppRoutes.settings)),
          const Divider(color: Colors.white10, height: 1),
          _buildMenuTile(context, CupertinoIcons.lock_fill, "Đổi mật khẩu", () => Navigator.pushNamed(context, AppRoutes.changePassword)),
        ],
      ),
    );
  }

  Widget _buildMenuTile(BuildContext context, IconData icon, String title, VoidCallback onTap) {
    return ListTile(
      leading: Icon(icon, color: AppColors.textPrimary, size: 22),
      title: Text(title, style: AppTypography.bodyLarge),
      trailing: const Icon(CupertinoIcons.chevron_right, size: 16, color: AppColors.textSecondary),
      onTap: onTap,
    );
  }

  // ===========================================================================
  // LOGIC HELPERS
  // ===========================================================================

  void _showAvatarPicker(BuildContext context, AuthProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        title: const Text("Ảnh đại diện"),
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final image = await ImagePicker().pickImage(source: ImageSource.gallery);
              if (image != null) await provider.updateAvatar(image.path);
            },
            child: const Text("Chọn từ thư viện"),
          ),
          CupertinoActionSheetAction(
            isDestructiveAction: true,
            onPressed: () async {
              Navigator.pop(ctx);
              await provider.removeAvatar();
            },
            child: const Text("Xóa ảnh hiện tại"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Hủy"),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  String _calculateLevelName(int count) {
    if (count >= 1000) return "Thần thoại";
    if (count >= 500) return "Kim cương";
    if (count >= 200) return "Vàng";
    return "Đồng";
  }

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Bạn có chắc chắn muốn đăng xuất khỏi tài khoản này?"),
        actions: [
          CupertinoDialogAction(child: const Text("Hủy"), onPressed: () => Navigator.pop(ctx)),
          CupertinoDialogAction(
            isDestructiveAction: true,
            child: const Text("Đăng xuất"),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(context, AppRoutes.login, (route) => false);
            },
          ),
        ],
      ),
    );
  }
}