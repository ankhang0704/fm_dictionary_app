import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/auth/presentation/providers/auth_provider.dart';
import 'package:provider/provider.dart';
import 'package:package_info_plus/package_info_plus.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';
import '../../../../core/widgets/common/app_avatar.dart';

// --- PROVIDERS & LOGIC ---
import '../../../home/presentation/providers/home_provider.dart';
import '../providers/settings_provider.dart';


class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final provider = context.watch<SettingsProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = provider.settings;

    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.meshBlue,
            AppColors.meshPurple,
            AppColors.meshMint,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildGlassHeader(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(AppLayout.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // SECTION 1: PROFILE SUMMARY (HERO CARD)
              _buildProfileHero(context, settings.userName),
              const SizedBox(height: 24),

              // SECTION 2: DAILY GOAL (BENTO)
              _buildSectionTitle(
                'settings.daily_goal'.tr().isEmpty
                    ? "Mục tiêu học tập"
                    : 'settings.daily_goal'.tr(),
              ),
              const SizedBox(height: 12),
              _buildDailyGoalCard(context, provider),
              const SizedBox(height: 24),

              // SECTION 3: PREFERENCES (LANGUAGE & THEME)
              _buildSectionTitle('settings.appearance'.tr()),
              const SizedBox(height: 12),
              _buildPreferencesCard(context, provider),
              const SizedBox(height: 24),

              // SECTION 4: AUDIO & AI
              _buildSectionTitle('settings.audio'.tr()),
              const SizedBox(height: 12),
              _buildAudioCard(context, provider),
              const SizedBox(height: 24),

              // SECTION 5: DANGER ZONE
              _buildSectionTitle('DANGER ZONE'),
              const SizedBox(height: 12),
              _buildDangerZoneCard(context),
              const SizedBox(height: 40),

              // FOOTER: VERSION INFO
              _buildFooter(),
              const SizedBox(height: 20),
            ],
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
            backgroundColor: Colors.white.withValues(alpha: 0.1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              'settings.title'.tr(),
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8.0),
      child: Text(
        title.toUpperCase(),
        style: AppTypography.heading3.copyWith(
          fontSize: 13,
          letterSpacing: 1.5,
          color: AppColors.textPrimary.withValues(alpha: 0.7),
        ),
      ),
    );
  }

  Widget _buildProfileHero(BuildContext context, String name) {
    return GlassBentoCard(
      onTap: null,
      child: Row(
        children: [
          const AppAvatar(radius: 35), // Default avatar placeholder
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(name, style: AppTypography.heading2),
                ),
                Text(
                  'settings.profile_desc'.tr().isEmpty
                      ? "Học viên xuất sắc"
                      : 'settings.profile_desc'.tr(),
                  style: AppTypography.bodyMedium.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            icon: const Icon(
              CupertinoIcons.pencil_circle_fill,
              color: AppColors.meshBlue,
              size: 32,
            ),
            onPressed: () => _showNameDialog(context),
          ),
        ],
      ),
    );
  }

  Widget _buildDailyGoalCard(BuildContext context, SettingsProvider provider) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          Row(
            children: [
              const Icon(CupertinoIcons.flame_fill, color: Colors.deepOrange),
              const SizedBox(width: 12),
              Text('Mục tiêu hàng ngày', style: AppTypography.bodyLarge),
              const SizedBox(height: 32),
              Text(
                '${provider.settings.dailyGoal} từ',
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: AppColors.meshBlue,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Slider.adaptive(
            value: provider.settings.dailyGoal.toDouble(),
            min: 5,
            max: 100,
            divisions: 19,
            activeColor: AppColors.meshBlue,
            onChanged: (val) {
              provider.updateDailyGoal(val.toInt());
              context.read<HomeProvider>().refreshDailyGoal();
            },
          ),
        ],
      ),
    );
  }

  Widget _buildPreferencesCard(
    BuildContext context,
    SettingsProvider provider,
  ) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: CupertinoIcons.globe,
            title: 'settings.language'.tr(),
            trailing: Text(
              context.locale.languageCode == 'en' ? 'English' : 'Tiếng Việt',
              style: const TextStyle(color: AppColors.textSecondary),
            ),
            // onTap: () => ShowLanguageLogic.showLanguagePicker(context),
          ),
          const Divider(color: Colors.white10),
          _buildSettingsTile(
            icon: provider.settings.themeMode == 'dark'
                ? CupertinoIcons.moon_stars_fill
                : CupertinoIcons.sun_max_fill,
            title: 'settings.dark_mode'.tr(),
            trailing: Switch.adaptive(
              value: provider.settings.themeMode == 'dark',
              activeThumbColor: AppColors.meshMint,
              onChanged: (bool value) => provider.toggleTheme(value),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildAudioCard(BuildContext context, SettingsProvider provider) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: CupertinoIcons.mic_fill,
            title: 'settings.hard_mode'.tr(),
            trailing: Switch.adaptive(
              value: provider.settings.isHardMode,
              activeThumbColor: AppColors.meshMint,
              onChanged: (bool value) => provider.toggleHardMode(value),
            ),
          ),
          const Divider(color: Colors.white10),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 12),
            child: Column(
              children: [
                Row(
                  children: [
                    const Icon(
                      CupertinoIcons.speedometer,
                      size: 20,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      'settings.tts_speed'.tr(),
                      style: AppTypography.bodyLarge,
                    ),
                    const SizedBox(height: 32),
                    Text(
                      '${provider.settings.ttsSpeed.toStringAsFixed(1)}x',
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
                Slider.adaptive(
                  value: provider.settings.ttsSpeed,
                  min: 0.1,
                  max: 1.5,
                  divisions: 10,
                  activeColor: AppColors.meshPurple,
                  onChanged: (val) => provider.updateTtsSpeed(val),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDangerZoneCard(BuildContext context) {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        children: [
          _buildSettingsTile(
            icon: CupertinoIcons.trash,
            title: 'settings.reset_btn'.tr(),
            titleColor: AppColors.error,
            // onTap: () => ResetProgressLogic.resetProgress(context),
          ),
          const Divider(color: Colors.white10),
          _buildSettingsTile(
            icon: CupertinoIcons.square_arrow_right,
            title: "Đăng xuất",
            titleColor: AppColors.error,
            onTap: () {
              // TODO: Add logout confirmation and logic
            },
          ),
        ],
      ),
    );
  }

  Widget _buildFooter() {
    return FutureBuilder<PackageInfo>(
      future: PackageInfo.fromPlatform(),
      builder: (context, snapshot) {
        return Text(
          'Phiên bản ${snapshot.data?.version ?? '1.0.0'}',
          textAlign: TextAlign.center,
          style: AppTypography.bodyMedium.copyWith(
            color: AppColors.textSecondary,
            fontSize: 12,
          ),
        );
      },
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    Widget? trailing,
    VoidCallback? onTap,
    Color? titleColor,
  }) {
    return ListTile(
      leading: Icon(icon, color: titleColor ?? AppColors.textPrimary, size: 22),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(color: titleColor),
      ),
      trailing:
          trailing ??
          const Icon(
            CupertinoIcons.chevron_right,
            size: 16,
            color: AppColors.textSecondary,
          ),
      onTap: onTap,
    );
  }

  // ===========================================================================
  // LEGACY LOGIC: NAME DIALOG
  // ===========================================================================

  void _showNameDialog(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    final controller = TextEditingController(text: provider.settings.userName);

    showDialog(
      context: context,
      builder: (dialogContext) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: AppColors.meshBlue.withValues(alpha:0.2),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Colors.white24),
          ),
          title: Text(
            'settings.edit_name'.tr(),
            style: const TextStyle(color: Colors.white),
          ),
          content: TextField(
            controller: controller,
            autofocus: true,
            style: const TextStyle(color: Colors.white),
            decoration: InputDecoration(
              hintText: 'settings.name_hint'.tr(),
              hintStyle: const TextStyle(color: Colors.white54),
              enabledBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: Colors.white24),
              ),
              focusedBorder: const UnderlineInputBorder(
                borderSide: BorderSide(color: AppColors.meshMint),
              ),
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(dialogContext),
              child: Text(
                'settings.cancel'.tr(),
                style: const TextStyle(color: Colors.white70),
              ),
            ),
            SmartActionButton(
              text: 'settings.save'.tr(),
              isGlass: false,
              onPressed: () async {
                final newName = controller.text.trim();
                provider.updateName(newName);
                final auth = context.read<AuthProvider>();
                if (auth.currentUser != null) {
                  await auth.updateDisplayName(newName);
                }
                if (dialogContext.mounted) Navigator.pop(dialogContext);
              },
        )],
        ),
      ),
    );
  }
}
// class ShowLanguageLogic {
// static void showLanguagePicker(BuildContext context) {
//   final currentLang = context.locale.languageCode;

//   showModalBottomSheet(
//     context: context,
//     backgroundColor: Colors.transparent,
//     builder: (context) {
//       final isDark = Theme.of(context).brightness == Brightness.dark;
//       return Container(
//         decoration: BoxDecoration(
//           color: isDark ?  AppColors.glassBackground : AppColors.glassBackground,
//           borderRadius: const BorderRadius.vertical(
//             top: Radius.circular(AppLayout.buttonRadius),
//           ),
//         ),
//         padding: const EdgeInsets.symmetric(vertical: 24),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             Container(
//               width: 40,
//               height: 4,
//               decoration: BoxDecoration(
//                 color: Colors.grey.withValues(alpha: 0.3),
//                 borderRadius: BorderRadius.circular(2),
//               ),
//             ),
//             const SizedBox(height: 24),
//             Text(
//               'settings.language'.tr(),
//               style: AppConstants.bodyStyle.copyWith(
//                 fontSize: 18,
//                 fontWeight: FontWeight.bold,
//                 color: isDark ? Colors.white : AppConstants.textPrimary,
//               ),
//             ),
//             const SizedBox(height: 16),
//             LanguageOption(
//               title: 'English',
//               flag: '🇬🇧',
//               isSelected: currentLang == 'en',
//               onTap: () {
//                 context.setLocale(const Locale('en'));
//                 Navigator.pop(context);
//               },
//             ),
//             LanguageOption(
//               title: 'Tiếng Việt',
//               flag: '🇻🇳',
//               isSelected: currentLang == 'vi',
//               onTap: () {
//                 context.setLocale(const Locale('vi'));
//                 Navigator.pop(context);
//               },
//             ),
//             const SizedBox(height: 24),
//           ],
//         ),
//       );
//     },
//   );
// }
// }