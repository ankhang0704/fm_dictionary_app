import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:provider/provider.dart';

import 'package:fm_dictionary/features/settings/logic/reset_progress.dart';
import 'package:fm_dictionary/features/settings/logic/show_langague.dart';
import 'package:fm_dictionary/features/settings/widgets/section_settings.dart';
// Import Provider vừa tạo
import 'package:fm_dictionary/features/settings/presentation/providers/settings_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  void _showNameDialog(BuildContext context) {
    final provider = context.read<SettingsProvider>();
    final controller = TextEditingController(text: provider.settings.userName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: isDark
            ? AppConstants.darkCardColor
            : AppConstants.cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.cardRadius / 2),
        ),
        title: Text(
          'settings.edit_name'.tr(),
          style: TextStyle(
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        content: TextField(
          controller: controller,
          autofocus: true,
          style: TextStyle(
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          decoration: InputDecoration(
            hintText: 'settings.name_hint'.tr(),
            hintStyle: TextStyle(color: AppConstants.textSecondary),
            focusedBorder: const UnderlineInputBorder(
              borderSide: BorderSide(color: AppConstants.accentColor),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: Text(
              'settings.cancel'.tr(),
              style: TextStyle(color: AppConstants.textSecondary),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppConstants.accentColor,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(
                  AppConstants.buttonRadius / 2,
                ),
              ),
            ),
            onPressed: () {
              provider.updateName(controller.text.trim());
              Navigator.pop(dialogContext);
            },
            child: Text('settings.save'.tr()),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final provider = context.watch<SettingsProvider>();

    if (provider.isLoading) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final settings = provider.settings;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          'settings.title'.tr(),
          style: AppConstants.headingStyle.copyWith(
            fontSize: 24,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      body: ListView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // 1. PROFILE SECTION
          SectionHeader(title: 'settings.profile'.tr()),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: CupertinoIcons.person,
                title: 'settings.profile_name'.tr(),
                trailing: Text(
                  settings.userName,
                  style: const TextStyle(
                    color: AppConstants.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                onTap: () => _showNameDialog(context),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 2. DAILY GOAL SECTION (TÍNH NĂNG MỚI)
          SectionHeader(
            title: 'Mục tiêu học tập',
          ), // Bạn có thể sửa thành .tr()
          SettingsGroup(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 16,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.flame_fill,
                          size: 22,
                          color: Colors.deepOrange,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'Mục tiêu hàng ngày', // Bạn có thể sửa thành .tr()
                          style: AppConstants.bodyStyle.copyWith(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : AppConstants.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.accentColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${settings.dailyGoal} từ',
                            style: const TextStyle(
                              color: AppConstants.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider.adaptive(
                      value: settings.dailyGoal.toDouble(),
                      min: 5,
                      max: 100,
                      divisions: 19, // Bước nhảy 5 từ (5, 10, 15... 100)
                      activeColor: AppConstants.accentColor,
                      inactiveColor: Colors.grey.withValues(alpha: 0.2),
                      onChanged: (val) {
                        provider.updateDailyGoal(val.toInt());
                        context.read<HomeProvider>().refreshDailyGoal();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 3. APPEARANCE & LANGUAGE SECTION
          SectionHeader(title: 'settings.appearance'.tr()),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: CupertinoIcons.globe,
                iconColor: Colors.blueAccent,
                title: 'settings.language'.tr(),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      context.locale.languageCode == 'en'
                          ? 'English'
                          : 'Tiếng Việt',
                      style: TextStyle(
                        color: AppConstants.textSecondary,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Icon(
                      CupertinoIcons.chevron_up_chevron_down,
                      size: 16,
                      color: AppConstants.textSecondary,
                    ),
                  ],
                ),
                onTap: () => ShowLanguageLogic.showLanguagePicker(context),
              ),
              SettingsTile(
                icon: settings.themeMode == 'dark'
                    ? CupertinoIcons.moon_stars_fill
                    : CupertinoIcons.sun_max_fill,
                iconColor: settings.themeMode == 'dark'
                    ? Colors.amber
                    : AppConstants.accentColor,
                title: 'settings.dark_mode'.tr(),
                trailing: Switch.adaptive(
                  value: settings.themeMode == 'dark',
                  activeColor: AppConstants.accentColor,
                  onChanged: (bool value) => provider.toggleTheme(value),
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 4. AUDIO & AI SECTION
          SectionHeader(title: 'settings.audio'.tr()),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: CupertinoIcons.mic_fill,
                iconColor: Colors.deepPurple,
                title: 'settings.hard_mode'.tr(),
                subtitle: 'settings.hard_mode_desc'.tr(),
                trailing: Switch.adaptive(
                  value: settings.isHardMode,
                  activeColor: AppConstants.accentColor,
                  onChanged: (bool value) => provider.toggleHardMode(value),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 12,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(
                          CupertinoIcons.speedometer,
                          size: 22,
                          color: Colors.teal,
                        ),
                        const SizedBox(width: 16),
                        Text(
                          'settings.tts_speed'.tr(),
                          style: AppConstants.bodyStyle.copyWith(
                            fontSize: 16,
                            color: isDark
                                ? Colors.white
                                : AppConstants.textPrimary,
                          ),
                        ),
                        const Spacer(),
                        Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 12,
                            vertical: 4,
                          ),
                          decoration: BoxDecoration(
                            color: AppConstants.accentColor.withValues(
                              alpha: 0.1,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            '${settings.ttsSpeed.toStringAsFixed(1)}x',
                            style: const TextStyle(
                              color: AppConstants.accentColor,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Slider.adaptive(
                      value: settings.ttsSpeed,
                      min: 0.1,
                      max: 1.5,
                      divisions: 10,
                      activeColor: AppConstants.accentColor,
                      inactiveColor: Colors.grey.withValues(alpha: 0.2),
                      onChanged: (val) => provider.updateTtsSpeed(val),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          // 5. DANGER ZONE
          SettingsGroup(
            children: [
              SettingsTile(
                icon: CupertinoIcons.trash,
                iconColor: AppConstants.errorColor,
                title: 'settings.reset_btn'.tr(),
                titleColor: AppConstants.errorColor,
                subtitle: 'settings.reset_desc'.tr(),
                onTap: () => ResetProgressLogic.resetProgress(context),
              ),
            ],
          ),
          const SizedBox(height: 40),
        ],
      ),
    );
  }
}
