// file: lib/screens/settings/settings_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/screens/settings/logic/reset_progress.dart';
import 'package:fm_dictionary/screens/settings/logic/show_langague.dart';
import 'package:fm_dictionary/screens/settings/widgets/section_settings.dart';
import '../../models/app_settings.dart';
import '../../services/database_service.dart';
import '../../services/theme_manager.dart';
import '../../core/constants/constants.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  late AppSettings _settings;

  @override
  void initState() {
    super.initState();
    _settings = DatabaseService.getSettings();
  }

  void _updateSettings() async {
    await DatabaseService.saveSettings(_settings);
    setState(() {});
  }

  void _showNameDialog() {
    final controller = TextEditingController(text: _settings.userName);
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
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
            onPressed: () => Navigator.pop(context),
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
              _settings.userName = controller.text.trim();
              _updateSettings();
              Navigator.pop(context);
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
            fontStyle: FontStyle.normal,
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
          SectionHeader(title: 'settings.profile'.tr()),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: CupertinoIcons.person,
                title: 'settings.profile_name'.tr(),
                trailing: Text(
                  _settings.userName,
                  style: const TextStyle(
                    color: AppConstants.accentColor,
                    fontWeight: FontWeight.w600,
                    fontSize: 16,
                  ),
                ),
                onTap: _showNameDialog,
              ),
            ],
          ),
          const SizedBox(height: 24),

          SectionHeader(title: 'settings.language'.tr().toUpperCase()),
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
            ],
          ),
          const SizedBox(height: 24),

          SectionHeader(title: 'settings.appearance'.tr()),
          SettingsGroup(
            children: [
              SettingsTile(
                icon: _settings.themeMode == 'dark'
                    ? CupertinoIcons.moon_stars_fill
                    : CupertinoIcons.sun_max_fill,
                iconColor: _settings.themeMode == 'dark'
                    ? Colors.amber
                    : AppConstants.accentColor,
                title: 'settings.dark_mode'.tr(),
                trailing: Switch.adaptive(
                  value: _settings.themeMode == 'dark',
                  // ignore: deprecated_member_use
                  activeColor: AppConstants.accentColor,
                  onChanged: (bool value) {
                    _settings.themeMode = value ? 'dark' : 'light';
                    ThemeManager.updateTheme(_settings.themeMode);
                    _updateSettings();
                  },
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

          SectionHeader(title: 'settings.audio'.tr()),
          SettingsGroup(
            children: [
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
                            '${_settings.ttsSpeed.toStringAsFixed(1)}x',
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
                      value: _settings.ttsSpeed,
                      min: 0.5,
                      max: 1.5,
                      divisions: 10,
                      activeColor: AppConstants.accentColor,
                      inactiveColor: Colors.grey.withValues(alpha: 0.2),
                      onChanged: (val) {
                        _settings.ttsSpeed = val;
                        _updateSettings();
                      },
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 24),

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



