import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/models/app_settings.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../services/theme_manager.dart';
import '../../utils/constants.dart';

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
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('settings.edit_name'.tr()),
        content: TextField(
          controller: controller,
          decoration:  InputDecoration(hintText: 'settings.name_hint'.tr()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('settings.cancel'.tr()),
          ),
          TextButton(
            onPressed: () {
              _settings.userName = controller.text;
              _updateSettings();
              Navigator.pop(context);
            },
            child:  Text('settings.save'.tr()),
          ),
        ],
      ),
    );
  }

  void _resetProgress() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text('settings.reset_btn'.tr()),
        content:  Text('settings.reset_desc'.tr()),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child:  Text('settings.cancel'.tr()),
          ),
          TextButton(
            onPressed: () async {
              final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
              for (var word in wordBox.values) {
                word.isLearned = false;
                word.wrongCount = 0;
                word.repetitions = 0;
                word.interval = 0;
                await word.save();
              }
               if (!context.mounted) return; 
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('settings.reset_success'.tr())),
              );
            },
            child:  Text('settings.reset_btn'.tr(), style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title:  Text(
          'settings.title'.tr(),
          style: AppConstants.subHeadingStyle,
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
           Text(
            'settings.profile'.tr(),
            style: AppConstants.subHeadingStyle,
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const Icon(Icons.person_outline),
            title:  Text('settings.profile_name'.tr()),
            trailing: Text(
              _settings.userName,
              style: const TextStyle(
                color: AppConstants.accentColor,
                fontWeight: FontWeight.bold,
              ),
            ),
            onTap: _showNameDialog,
            contentPadding: EdgeInsets.zero,
          ),
          const Divider(height: 48),
           Text(
            'settings.language'.tr().toUpperCase(),
            style: AppConstants.subHeadingStyle,
          ),

          ListTile(
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.language, color: Colors.blue),
            title: Text(
              'settings.language'.tr(),
            ),
            trailing: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
              ),
              // Nút Dropdown chọn ngôn ngữ
              child: DropdownButtonHideUnderline(
                child: DropdownButton<String>(
                  value: currentLang,
                  icon: const Icon(Icons.arrow_drop_down),
                  items: const [
                    DropdownMenuItem(value: 'en', child: Text('English')),
                    DropdownMenuItem(
                      value: 'vi',
                      child: Text('Tiếng Việt'),
                    ),
                  ],
                  onChanged: (String? newLang) {
                    if (newLang != null) {
                      // GỌI HÀM NÀY LÀ TOÀN BỘ APP TỰ ĐỘNG ĐỔI NGÔN NGỮ
                      context.setLocale(Locale(newLang));
                    }
                  },
                ),
              ),
            ),
          ),
          const Divider(height: 48),
          // Appearance Section 
           Text(
            'settings.appearance'.tr(),
            style: AppConstants.subHeadingStyle,
          ),
          const SizedBox(height: 8),
          SwitchListTile(
            secondary: const Icon(Icons.dark_mode_outlined),
            title:  Text('settings.dark_mode'.tr()),
            value: _settings.themeMode == 'dark',
            activeThumbColor: AppConstants.accentColor,
            contentPadding: EdgeInsets.zero,
            onChanged: (bool value) {
              _settings.themeMode = value ? 'dark' : 'light';
              ThemeManager.updateTheme(_settings.themeMode);
              _updateSettings();
            },
          ),
          const Divider(height: 48),
           Text(
            'settings.audio'.tr(),
            style: AppConstants.subHeadingStyle,
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              const Icon(Icons.speed_rounded, size: 20),
              const SizedBox(width: 12),
              Text('settings.tts_speed'.tr()),
              const Spacer(),
              Text(
                '${_settings.ttsSpeed.toStringAsFixed(1)}x',
                style: const TextStyle(color: AppConstants.textSecondary),
              ),
            ],
          ),
          Slider(
            value: _settings.ttsSpeed,
            min: 0.5,
            max: 1.5,
            activeColor: AppConstants.primaryColor,
            onChanged: (val) {
              _settings.ttsSpeed = val;
              _updateSettings();
            },
          ),
          const Divider(height: 48),
          ListTile(
            leading: const Icon(
              Icons.delete_forever_rounded,
              color: AppConstants.errorColor,
            ),
            title:  Text(
              'settings.reset_btn'.tr(),
              style: TextStyle(color: AppConstants.errorColor),
            ),
            subtitle:  Text('settings.reset_desc'.tr()),
            onTap: _resetProgress,
            contentPadding: EdgeInsets.zero,
          ),
        ],
      ),
    );
  }
}
