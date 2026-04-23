import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/smart_action_button.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/features/auth/presentation/providers/auth_provider.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:hive/hive.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/app_avatar.dart';

// --- PROVIDERS & LOGIC ---
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();
    final authProvider = context.watch<AuthProvider>();
    if (provider.isLoading) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    final settings = provider.settings;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // SECTION 1: PROFILE SUMMARY (BENTO HERO)
            _buildProfileHero(context, settings.userName),
            const SizedBox(height: 24),

            // SECTION 2: DAILY GOAL
            _buildSectionTitle(
              context,
              'settings.daily_goal_label'.tr(), // SIMPLIFIED
            ),
            const SizedBox(height: 12),
            _buildDailyGoalCard(context, provider),
            const SizedBox(height: 24),

            // SECTION 3: PREFERENCES
            _buildSectionTitle(context, 'settings.appearance'.tr()),
            const SizedBox(height: 12),
            _buildPreferencesCard(context, provider),
            const SizedBox(height: 24),

            // SECTION 4: AUDIO & AI
            _buildSectionTitle(context, 'settings.audio'.tr()),
            const SizedBox(height: 12),
            _buildAudioCard(context, provider),
            const SizedBox(height: 24),

            // SECTION 5: DANGER ZONE
            _buildSectionTitle(
              context,
              'settings.danger_zone'.tr(),
            ), // INJECTED
            const SizedBox(height: 12),
            _buildDangerZoneCard(context, authProvider),
            const SizedBox(height: 40),

            // FOOTER: VERSION INFO
            _buildFooter(context),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildBentoHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        'settings.title'.tr(),
        style: Theme.of(context).textTheme.displaySmall,
      ),
    );
  }

  Widget _buildSectionTitle(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: Theme.of(context).textTheme.bodySmall?.copyWith(
          fontSize: 12,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.2,
          color: Theme.of(
            context,
          ).textTheme.bodySmall?.color?.withValues(alpha: 0.6),
        ),
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, String name) {
    return BentoCard(
      child: Row(
        children: [
          const AppAvatar(radius: 35),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    name,
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                ),
                Text(
                  'settings.profile_desc'.tr(), // SIMPLIFIED
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bentoBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(
                CupertinoIcons.pencil,
                color: AppColors.bentoBlue,
                size: 24,
              ),
              onPressed: () => _showEditNameDialog(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, SettingsProvider provider) {
    return BentoCard(
      child: Column(
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: const BoxDecoration(
                  color: AppColors.warning,
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.flame_fill,
                  color: Colors.white,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'settings.daily_goal'.tr(), // INJECTED
                  style: Theme.of(
                    context,
                  ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
                ),
              ),
              Text(
                'settings.words_unit'.tr(
                  args: [provider.settings.dailyGoal.toString()],
                ), // ARGS HANDLING
                style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w900,
                  color: AppColors.bentoBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              trackHeight: 8,
              thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 10),
            ),
            child: Slider(
              value: provider.settings.dailyGoal.toDouble(),
              min: 5,
              max: 100,
              divisions: 19,
              activeColor: AppColors.bentoBlue,
              inactiveColor: AppColors.bentoBlue.withValues(alpha: 0.1),
              onChanged: (val) {
                provider.updateDailyGoal(val.toInt());
                context.read<HomeProvider>().refreshDailyGoal();
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.globe,
            iconColor: AppColors.bentoMint,
            title: 'settings.language'.tr(),
            trailing: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  context.locale.languageCode == 'en'
                      ? 'English'
                      : 'Tiếng Việt',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(width: 8),
                const Icon(CupertinoIcons.chevron_right, size: 14),
              ],
            ),
            onTap: () => ShowLanguageLogic.showLanguagePicker(context),
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            context,
            icon: provider.settings.themeMode == 'dark'
                ? CupertinoIcons.moon_stars_fill
                : CupertinoIcons.sun_max_fill,
            iconColor: AppColors.bentoPurple,
            title: 'settings.dark_mode'.tr(),
            trailing: CupertinoSwitch(
              value: provider.settings.themeMode == 'dark',
              activeTrackColor: AppColors.bentoPurple,
              onChanged: (bool value) => provider.toggleTheme(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context, SettingsProvider provider) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.mic_fill,
            iconColor: AppColors.bentoPink,
            title: 'settings.hard_mode'.tr(),
            trailing: CupertinoSwitch(
              value: provider.settings.isHardMode,
              activeTrackColor: AppColors.bentoPink,
              onChanged: (bool value) => provider.toggleHardMode(value),
            ),
          ),
          const Divider(height: 1, indent: 56),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: AppColors.bentoBlue.withValues(alpha: 0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        CupertinoIcons.speedometer,
                        size: 20,
                        color: AppColors.bentoBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        'settings.tts_speed'.tr(),
                        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    Text(
                      '${provider.settings.ttsSpeed.toStringAsFixed(1)}x',
                      style: const TextStyle(fontWeight: FontWeight.w900),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Slider(
                  value: provider.settings.ttsSpeed.clamp(0.1, 1.5),
                  min: 0.1,
                  max: 1.5,
                  divisions: 15,
                  activeColor: AppColors.bentoBlue,
                  onChanged: (val) => provider.updateTtsSpeed(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context, AuthProvider provider) {
    return BentoCard(
      padding: EdgeInsets.zero,
      child: Column(
        children: [
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.trash,
            iconColor: AppColors.error,
            title: 'settings.reset_btn'.tr(),
            titleColor: AppColors.error,
            onTap: () => _handleResetProgress(context), // Logic preserved
          ),
          const Divider(height: 1, indent: 56),
          _buildSettingsTile(
            context,
            icon: CupertinoIcons.square_arrow_right,
            iconColor: AppColors.error,
            title: "profile.logout".tr(), // INJECTED FROM PROFILE KEYS
            titleColor: AppColors.error,
           onTap: () => handleLogout(context,
              provider,
            ),  // Logout confirmation logic
          ),
        ],
      ),
    );
  }
 void _handleResetProgress(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32.0)),
      ),
      builder: (ctx) {
        return SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Padding(
              padding: const EdgeInsets.fromLTRB(24.0, 12.0, 24.0, 24.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Drag Indicator
                  Container(
                    width: 40,
                    height: 5,
                    decoration: BoxDecoration(
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  const SizedBox(height: 32),

                  // VIBRANT DANGER ICON: Cảnh báo xóa vĩnh viễn
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: const Color(
                        0xFFFF4757,
                      ).withValues(alpha: 0.12), // Vibrant Red tint
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.delete_forever_rounded,
                      color: Color(0xFFFF4757),
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 24),

                  // TIÊU ĐỀ (Localization Preserved)
                  Text(
                    'settings.reset_btn'.tr(),
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: const Color(
                        0xFFFF4757,
                      ), // Nhấn mạnh màu đỏ nguy hiểm
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 12),

                  // MÔ TẢ CẢNH BÁO (Localization Preserved/Converted)
                  Text(
                    "settings.reset_warning_desc".tr(), // INJECTED
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      color: Theme.of(context).hintColor,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 40),

                  // ACTION BUTTONS (Column for better thumb reach)
                  Column(
                    children: [
                      // NÚT XÁC NHẬN XÓA (Vibrant Red)
                      SmartActionButton(
                        text: 'settings.reset_confirm_btn'.tr(), // INJECTED
                        icon: Icons.check_circle_rounded,
                        color: const Color(0xFFFF4757),
                        textColor: Colors.white,
                        onPressed: () async {
                          // 🚨 [LOGIC PRESERVED 100%]
                          Navigator.pop(ctx); // Đóng Sheet

                          // 1. Xóa Database Local
                          final progressBox = Hive.box(
                            DatabaseService.progressBoxName,
                          );
                          await progressBox.clear();

                          if (!context.mounted) return;

                          // 2. Refresh lại Lộ trình
                          context.read<RoadmapProvider>().refresh();

                          // 3. Báo thành công (Localization Preserved)
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(
                                'settings.reset_success_msg'.tr(),
                              ), // INJECTED
                              backgroundColor: const Color(
                                0xFF10B981,
                              ), // Vibrant Emerald
                              behavior: SnackBarBehavior.floating,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                            ),
                          );
                        },
                      ),
                      const SizedBox(height: 12),

                      // NÚT HỦY (Flat Bento)
                      SmartActionButton(
                        text: 'common.cancel'.tr(), // RE-ROUTED TO COMMON
                        isGlass: true, // Phong cách nhạt màu Bento
                        textColor: Theme.of(context).textTheme.bodyLarge?.color,
                        onPressed: () => Navigator.pop(ctx),
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
  // --- LOGIC 2: ĐĂNG XUẤT ---
    void handleLogout(BuildContext context, AuthProvider auth) {
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
                    color: Theme.of(context).dividerColor.withValues(
                      alpha: 0.2,
                    ), // Màu mờ tự động theo Theme
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                const SizedBox(height: 24),
                // Bento Alert Icon (Vibrant Red)
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF4757).withValues(alpha: 0.15),
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
  Widget _buildFooter(BuildContext context) {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        final version = snapshot.data?.version ?? '1.0.0';
        return Text(
          'settings.version'.tr(args: [version]), // ARGS HANDLING
          textAlign: TextAlign.center,
          style: Theme.of(context).textTheme.bodySmall?.copyWith(fontSize: 12),
        );
      },
    );
  }

  Widget _buildSettingsTile(
    BuildContext context, {
    required IconData icon,
    required Color iconColor,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: iconColor.withValues(alpha: 0.1),
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: iconColor, size: 20),
      ),
      title: Text(
        title,
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          color: titleColor,
          fontWeight: FontWeight.w600,
        ),
      ),
      trailing: trailing,
      onTap: onTap,
    );
  }

  // ===========================================================================
  // ABSOLUTE ZERO-TOUCH LOGIC: NAME DIALOG
  // ===========================================================================

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
                      color: Theme.of(
                        context,
                      ).dividerColor.withValues(alpha: 0.2),
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
                      ).withValues(alpha: 0.15), // Vibrant Emerald Mờ
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
                      color: Theme.of(context).dividerColor.withValues(
                        alpha: 0.05,
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
}

class ShowLanguageLogic {
  static void showLanguagePicker(BuildContext context) {
    final currentLang = context.locale.languageCode;

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).scaffoldBackgroundColor,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppLayout.bentoBorderRadius),
            ),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
              ),
              const SizedBox(height: 24),
              Text(
                'settings.language'.tr(),
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 24),
              _buildLangOption(
                context,
                title: 'English',
                icon: CupertinoIcons.flag_fill,
                isSelected: currentLang == 'en',
                onTap: () {
                  context.setLocale(const Locale('en'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 12),
              _buildLangOption(
                context,
                title: 'Tiếng Việt',
                icon: CupertinoIcons.flag_circle_fill,
                isSelected: currentLang == 'vi',
                onTap: () {
                  context.setLocale(const Locale('vi'));
                  Navigator.pop(context);
                },
              ),
              const SizedBox(height: 24),
            ],
          ),
        );
      },
    );
  }

  static Widget _buildLangOption(
    BuildContext context, {
    required String title,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return BentoCard(
      onTap: onTap,
      bentoColor: isSelected
          ? Theme.of(context).primaryColor.withValues(alpha: 0.1)
          : null,
      child: Row(
        children: [
          Icon(icon, color: isSelected ? Theme.of(context).primaryColor : null),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              title,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                fontWeight: isSelected ? FontWeight.bold : null,
              ),
            ),
          ),
          if (isSelected)
            Icon(
              CupertinoIcons.checkmark_alt,
              color: Theme.of(context).primaryColor,
            ),
        ],
      ),
    );
  }
}
