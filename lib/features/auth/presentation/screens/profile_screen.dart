import 'package:easy_localization/easy_localization.dart';
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
              text: "profile.logout"
                  .tr(), // Tuân thủ chặt chẽ việc không hardcode string
              icon: Icons.logout_rounded,
              color: const Color(0xFFFF4757), // Vibrant Coral Red (Danger)
              textColor: Colors.white,
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
    // final masteredCount = gami.badges.where((b) => b.isUnlocked).length * 100;
    // final levelName = _calculateLevelName(masteredCount);
    // final double expProgress = ((masteredCount % 50) / 50.0).clamp(0.0, 1.0);

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
                    // Text(
                    //   "Hạng: $levelName",
                    //   style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    //     color: AppColors.warning,
                    //     fontWeight: FontWeight.bold,
                    //   ),
                    // ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),
          // LinearProgressIndicator(
          //   value: expProgress,
          //   minHeight: 10,
          //   backgroundColor: Colors.grey.withValues(alpha: 0.1),
          //   valueColor: AlwaysStoppedAnimation(AppColors.bentoMint),
          // ),
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
          // LOCALIZATION PRESERVED & PREVENT TEXT OVERFLOW
          Text(
            'profile.badges'
                .tr(), // Đã thay thế "Huy hiệu" bằng chuỗi Đa ngôn ngữ
            style: Theme.of(context).textTheme.displaySmall?.copyWith(
              fontWeight: FontWeight.bold,
              fontSize:
                  20, // Ép size chuẩn Bento tránh chữ quá to gây vỡ layout
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
          const SizedBox(height: 16),

          // ANTI-OVERFLOW WRAPPER
          SizedBox(
            height:
                140, // Tăng từ 110 lên 140 để triệt tiêu hoàn toàn lỗi vỡ layout dọc
            child: ListView.separated(
              clipBehavior: Clip
                  .none, // Cho phép hiển thị mượt mà không cắt xén viền/bóng
              scrollDirection: Axis.horizontal,
              physics:
                  const BouncingScrollPhysics(), // Hiệu ứng kéo mượt mà của Bento
              itemCount: gami.badges.length,
              separatorBuilder: (_, _) => const SizedBox(
                width: 16,
              ), // Tăng khoảng cách ra một chút cho thoáng
              itemBuilder: (ctx, i) {
                final badge = gami.badges[i]; // Gọn gàng và tối ưu

                return SizedBox(
                  width:
                      100, // Tăng từ 90 lên 100 để text của huy hiệu có không gian
                  child: BentoBadgeWidget(
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
    return BentoCard(
      // Thêm padding cho nội dung bên trong Card để các phần tử có không gian "thở"
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 4.0),
        child: Column(
          children: [
            // Menu Item 1: Chỉnh sửa thông tin (Vibrant Blue)
            _buildBentoMenuItem(
              context: context,
              icon: Icons.person_rounded,
              iconColor: const Color(0xFF3B82F6), // Vibrant Blue
              title: 'profile.edit_info'
                  .tr(), // Cần thêm "Chỉnh sửa thông tin" vào file lang
              onTap: () => _showEditNameDialog(context),
            ),

            // Đường phân cách mờ tinh tế
            Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              height: 16,
            ),

            // Menu Item 2: Cài đặt (Vibrant Purple - Đã đổi tên và icon theo yêu cầu)
            _buildBentoMenuItem(
              context: context,
              icon: Icons.settings_rounded, // Đổi từ cái chuông sang bánh răng
              iconColor: const Color(0xFF8B5CF6), // Vibrant Purple
              title: 'profile.settings'.tr(), // Thay cho "Cài đặt"
              onTap: () => Navigator.pushNamed(context, AppRoutes.settings),
            ),

            Divider(
              color: Theme.of(context).dividerColor.withOpacity(0.1),
              height: 16,
            ),

            // Menu Item 3: Đổi mật khẩu (Vibrant Amber/Orange)
            _buildBentoMenuItem(
              context: context,
              icon: Icons.lock_rounded,
              iconColor: const Color(0xFFF59E0B), // Vibrant Amber
              title: 'profile.change_password'.tr(), // Thay cho "Đổi mật khẩu"
              onTap: () =>
                  Navigator.pushNamed(context, AppRoutes.changePassword),
            ),
          ],
        ),
      ),
    );
  }

  void _showAvatarPicker(BuildContext context, AuthProvider provider) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.0),
        ), // Chuẩn bo góc Bento
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Drag Indicator
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                Text(
                  'profile.update_avatar'
                      .tr(), // Thay cho text tĩnh (Cập nhật ảnh đại diện)
                  style: Theme.of(
                    context,
                  ).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // Nút chọn từ thư viện (Vibrant Blue)
                SmartActionButton(
                  text: 'profile.choose_gallery'
                      .tr(), // Thay cho "Chọn từ thư viện"
                  icon: Icons.photo_library_rounded,
                  color: const Color(0xFF3B82F6),
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    // LOGIC GIỮ NGUYÊN 100%
                    final image = await ImagePicker().pickImage(
                      source: ImageSource.gallery,
                    );
                    if (image != null) await provider.updateAvatar(image.path);
                  },
                ),
                const SizedBox(height: 12),

                // Nút xóa ảnh (Vibrant Danger)
                SmartActionButton(
                  text: 'profile.remove_avatar'.tr(), // Thay cho "Xóa ảnh"
                  icon: Icons.delete_rounded,
                  color: const Color(0xFFFF4757),
                  textColor: Colors.white,
                  onPressed: () async {
                    Navigator.pop(ctx);
                    // LOGIC GIỮ NGUYÊN 100%
                    await provider.removeAvatar();
                  },
                ),
                const SizedBox(height: 12),

                // Nút Hủy (Bento Secondary/Glass)
                SmartActionButton(
                  text: 'common.cancel'.tr(), // Thay cho "Hủy"
                  isGlass: true,
                  textColor: Theme.of(context).textTheme.bodyLarge?.color,
                  onPressed: () => Navigator.pop(ctx),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showEditNameDialog(BuildContext context) {
    final controller = TextEditingController(
      text: DatabaseService.getSettings().userName, // LOGIC GIỮ NGUYÊN 100%
    );

    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Cho phép đẩy lên khi hiện bàn phím
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(28.0)),
      ),
      builder: (ctx) {
        return Padding(
          // Padding viewInsets để không bị bàn phím che mất
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(context).viewInsets.bottom,
          ),
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Indicator
                  Container(
                    width: 48,
                    height: 6,
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bento Header Icon
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFF10B981,
                      ).withOpacity(0.15), // Vibrant Emerald Mờ
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.badge_rounded,
                      color: Color(0xFF10B981),
                      size: 32,
                    ),
                  ),
                  const SizedBox(height: 16),

                  Text(
                    'profile.edit_name'.tr(), // Thay cho "Chỉnh sửa tên"
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // Bento Style TextField (Flat, no border, solid background)
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).dividerColor.withOpacity(
                        0.05,
                      ), // Tự ứng biến theo Theme (Sáng/Tối)
                      borderRadius: BorderRadius.circular(16.0),
                    ),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16.0,
                      vertical: 4.0,
                    ),
                    child: TextField(
                      controller: controller,
                      autofocus: true, // Tự động mở bàn phím
                      style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                        fontWeight: FontWeight.w600,
                        fontSize: 18,
                      ),
                      decoration: InputDecoration(
                        border: InputBorder.none,
                        hintText: 'profile.enter_name_hint'
                            .tr(), // Cần có trong file lang
                        hintStyle: Theme.of(context).textTheme.bodyMedium
                            ?.copyWith(color: Theme.of(context).hintColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // Action Buttons
                  Row(
                    children: [
                      // Nút Hủy
                      Expanded(
                        child: SmartActionButton(
                          text: 'common.cancel'.tr(), // Thay cho "Hủy"
                          isGlass: true,
                          textColor: Theme.of(
                            context,
                          ).textTheme.bodyLarge?.color,
                          onPressed: () => Navigator.pop(ctx),
                        ),
                      ),
                      const SizedBox(width: 16),
                      // Nút Lưu
                      Expanded(
                        child: SmartActionButton(
                          text: 'common.save'.tr(), // Thay cho "Lưu"
                          icon: Icons.check_rounded,
                          color: const Color(0xFF10B981), // Vibrant Emerald
                          textColor: Colors.white,
                          onPressed: () async {
                            // LOGIC GIỮ NGUYÊN 100%
                            await context.read<SettingsProvider>().updateName(
                              controller.text.trim(),
                            );
                            if (ctx.mounted) Navigator.pop(ctx);
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // String _calculateLevelName(int count) => count >= 1000
  //     ? "Thần thoại"
  //     : count >= 500
  //     ? "Kim cương"
  //     : count >= 200
  //     ? "Vàng"
  //     : "Đồng";

  void _handleLogout(BuildContext context, AuthProvider auth) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Tự động thích ứng Light/Dark Mode
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(28.0),
        ), // Bo góc to chuẩn Bento
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
            child: Column(
              mainAxisSize:
                  MainAxisSize.min, // Thu gọn kích thước theo nội dung
              children: [
                // Drag Indicator (Thanh kéo ngang)
                Container(
                  width: 48,
                  height: 6,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor.withOpacity(
                      0.2,
                    ), // Màu mờ tự động theo Theme
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),

                // Bento Alert Icon (Vibrant Red)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: Color(0xFFFF4757),
                    size: 32,
                  ),
                ),
                const SizedBox(height: 16),

                // Tiêu đề (Localization Protected)
                Text(
                  'profile.logout'.tr(),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),

                // Nội dung xác nhận (Localization Protected)
                Text(
                  'profile.logout_confirm'.tr(),
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(
                      context,
                    ).textTheme.bodySmall?.color, // Màu Secondary nhẹ nhàng
                    fontSize: 16,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 32),

                // Bento Action Buttons
                Row(
                  children: [
                    // Nút Hủy (Secondary Flat Button)
                    Expanded(
                      child: SmartActionButton(
                        text: 'common.cancel'.tr(),
                        isGlass:
                            true, // Tận dụng thiết kế nền nhạt của SmartActionButton mới
                        textColor: Theme.of(
                          context,
                        ).textTheme.bodyLarge?.color, // Chữ tự đổi theo Theme
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ),
                    const SizedBox(width: 16),

                    // Nút Đăng xuất (Vibrant Danger)
                    Expanded(
                      child: SmartActionButton(
                        text: 'profile.logout'.tr(),
                        color: const Color(
                          0xFFFF4757,
                        ), // Màu Đỏ Cảnh báo (Danger)
                        textColor: Colors.white,
                        onPressed: () {
                          // LOGIC PRESERVED 100%
                          auth.logout();
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            AppRoutes.login,
                            (r) => false,
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      },
    );
  }
   Widget _buildBentoMenuItem({
    required BuildContext context,
    required IconData icon,
    required Color iconColor,
    required String title,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent, // Trong suốt để ăn theo nền của BentoCard
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(16.0), // Bo góc hiệu ứng bấm
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 8.0),
          child: Row(
            children: [
              // Premium Icon Container
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: iconColor.withOpacity(
                    0.15,
                  ), // Nền mờ cùng tông màu icon
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: iconColor, size: 22),
              ),
              const SizedBox(width: 16),

              // Tiêu đề
              Expanded(
                child: Text(
                  title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    fontWeight: FontWeight.w600, // Chữ đậm rõ nét chuẩn Bento
                    letterSpacing: 0.2,
                  ),
                ),
              ),

              // Mũi tên điều hướng
              Icon(
                Icons.chevron_right_rounded,
                color: Theme.of(
                  context,
                ).dividerColor.withOpacity(0.5), // Tự động thích ứng Sáng/Tối
                size: 24,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
