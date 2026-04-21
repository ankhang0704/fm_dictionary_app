import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';
import 'package:fm_dictionary/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fm_dictionary/features/gamification/presentation/widgets/bento_badge_widget.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:fm_dictionary/features/settings/presentation/providers/settings_provider.dart';
import 'package:provider/provider.dart';
import 'package:image_picker/image_picker.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
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
      return Scaffold(
        body: Center(
          child: Text(
            "Vui lòng đăng nhập",
            style: Theme.of(context).textTheme.bodyLarge,
          ),
        ),
      );
    }

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text("Cá nhân", style: Theme.of(context).textTheme.displaySmall),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        child: Column(
          children: [
            _buildIdentityHero(context, authProvider, gamification, settings),
            const SizedBox(height: 16),
            _buildStatsGrid(context),
            const SizedBox(height: 16),
            _buildBadgesSection(context, gamification),
            const SizedBox(height: 16),
            _buildMenuOptions(context),
            const SizedBox(height: 32),
            SmartActionButton(
              text: "Đăng xuất",
              onPressed: () => _handleLogout(context, authProvider),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildIdentityHero(
    BuildContext context,
    AuthProvider auth,
    GamificationProvider gami,
    dynamic settings,
  ) {
    final user = auth.currentUser!;
    final masteredCount = gami.badges.where((b) => b.isUnlocked).length * 100;
    final levelName = _calculateLevelName(masteredCount);
    final double expProgress = ((masteredCount % 50) / 50.0).clamp(0.0, 1.0);

    return BentoCard(
      child: Column(
        children: [
          Row(
            children: [
              Stack(
                alignment: Alignment.center,
                children: [
                  AppAvatar(
                    localPath: settings.userAvatarPath,
                    networkUrl: user.photoURL,
                    radius: 40,
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: GestureDetector(
                      onTap: () => _showAvatarPicker(context, auth),
                      child: Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Theme.of(context).primaryColor,
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(
                          CupertinoIcons.camera_fill,
                          size: 14,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(width: 20),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.displayName ?? settings.userName,
                      style: Theme.of(context).textTheme.displaySmall,
                    ),
                    Text(
                      "Hạng: $levelName",
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.warning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          LinearProgressIndicator(
            value: expProgress,
            minHeight: 10,
            backgroundColor: Colors.grey.withValues(alpha: 0.1),
            valueColor: AlwaysStoppedAnimation(AppColors.bentoMint),
          ),
        ],
      ),
    );
  }

  Widget _buildStatsGrid(BuildContext context) {
    final learning = context.watch<LearningProvider>();
    final savedCount = WordService().getSavedWords().length;
    return Row(
      children: [
        Expanded(
          child: BentoCard(
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.flame_fill,
                  color: AppColors.warning,
                  size: 30,
                ),
                Text(
                  "${learning.currentStreak}",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text("Chuỗi Streak"),
              ],
            ),
          ),
        ),
        const SizedBox(width: 16),
        Expanded(
          child: BentoCard(
            child: Column(
              children: [
                const Icon(
                  CupertinoIcons.book_fill,
                  color: AppColors.bentoBlue,
                  size: 30,
                ),
                Text(
                  "$savedCount",
                  style: Theme.of(context).textTheme.displaySmall,
                ),
                Text("Từ đã lưu"),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildBadgesSection(BuildContext context, GamificationProvider gami) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text("Huy hiệu", style: Theme.of(context).textTheme.displaySmall),
          const SizedBox(height: 16),
          SizedBox(
            height: 110,
            child: ListView.separated(
              scrollDirection: Axis.horizontal,
              itemCount: gami.badges.length,
              separatorBuilder: (_, _) => const SizedBox(width: 12),
              itemBuilder: (ctx, i) => SizedBox(
                width: 90,
                child: BentoBadgeWidget(
                  badgeName: gami.badges[i].title,
                  icon: gami.badges[i].icon,
                  isUnlocked: gami.badges[i].isUnlocked,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMenuOptions(BuildContext context) {
    return BentoCard(
      child: Column(
        children: [
          ListTile(
            leading: const Icon(CupertinoIcons.person_fill),
            title: const Text("Chỉnh sửa thông tin"),
            onTap: () => _showEditNameDialog(context),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.bell_fill),
            title: const Text("Cài đặt thông báo"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
          ),
          ListTile(
            leading: const Icon(CupertinoIcons.lock_fill),
            title: const Text("Đổi mật khẩu"),
            onTap: () => Navigator.pushNamed(context, AppRoutes.changePassword),
          ),
        ],
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, AuthProvider provider) {
    showCupertinoModalPopup(
      context: context,
      builder: (ctx) => CupertinoActionSheet(
        actions: [
          CupertinoActionSheetAction(
            onPressed: () async {
              Navigator.pop(ctx);
              final image = await ImagePicker().pickImage(
                source: ImageSource.gallery,
              );
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
            child: const Text("Xóa ảnh"),
          ),
        ],
        cancelButton: CupertinoActionSheetAction(
          child: const Text("Hủy"),
          onPressed: () => Navigator.pop(ctx),
        ),
      ),
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: DatabaseService.getSettings().userName,
    );
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Chỉnh sửa tên"),
        content: CupertinoTextField(controller: controller),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          CupertinoDialogAction(
            isDefaultAction: true,
            onPressed: () async {
              await context.read<SettingsProvider>().updateName(
                controller.text.trim(),
              );
              if (ctx.mounted) Navigator.pop(ctx);
            },
            child: const Text("Lưu"),
          ),
        ],
      ),
    );
  }

  String _calculateLevelName(int count) => count >= 1000
      ? "Thần thoại"
      : count >= 500
      ? "Kim cương"
      : count >= 200
      ? "Vàng"
      : "Đồng";

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showCupertinoDialog(
      context: context,
      builder: (ctx) => CupertinoAlertDialog(
        title: const Text("Đăng xuất"),
        content: const Text("Chắc chắn muốn thoát?"),
        actions: [
          CupertinoDialogAction(
            onPressed: () => Navigator.pop(ctx),
            child: const Text("Hủy"),
          ),
          CupertinoDialogAction(
            isDestructiveAction: true,
            onPressed: () {
              auth.logout();
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.login,
                (r) => false,
              );
            },
            child: const Text("Đăng xuất"),
          ),
        ],
      ),
    );
  }
}
