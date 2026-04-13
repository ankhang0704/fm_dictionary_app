// file: lib/screens/welcome/welcome_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/features/welcome/widgets/language_selector.dart';
import 'package:fm_dictionary/features/welcome/widgets/name_input_field.dart';
import 'package:fm_dictionary/features/welcome/widgets/start_button.dart';
import 'package:fm_dictionary/features/welcome/widgets/theme_toggle_card.dart';
import 'package:fm_dictionary/features/welcome/widgets/welcome_header.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/ui_management/theme_manager.dart';
import '../home/main_navigation.dart';
import '../../core/constants/constants.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDarkMode = false;

  @override
  void initState() {
    super.initState();
    // Initialize with current system/app brightness
    WidgetsBinding.instance.addPostFrameCallback((_) {
      setState(() {
        _isDarkMode = Theme.of(context).brightness == Brightness.dark;
      });
    });
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  void _handleStart() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("welcome.name_required".tr()),
          backgroundColor: AppConstants.errorColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppConstants.inputRadius),
          ),
        ),
      );
      return;
    }

    final navigator = Navigator.of(context);
    var settings = DatabaseService.getSettings();
    settings.userName = name;
    settings.themeMode = _isDarkMode ? 'dark' : 'light';
    settings.isFirstRun = false;
    await DatabaseService.saveSettings(settings);

    navigator.pushReplacement(
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final currentLang = context.locale.languageCode;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            return SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding),
              child: ConstrainedBox(
                constraints: BoxConstraints(minHeight: constraints.maxHeight),
                child: IntrinsicHeight(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppConstants.defaultPadding),
                      Align(
                        alignment: Alignment.centerRight,
                        child: LanguageSelector(currentLang: currentLang),
                      ),
                      const SizedBox(height: 32),
                      WelcomeHeader(isDark: isDark),
                      const SizedBox(height: 40),
                      NameInputField(
                        controller: _nameController,
                        isDark: isDark,
                      ),
                      const SizedBox(height: 20),
                      ThemeToggleCard(
                        isDarkMode: _isDarkMode,
                        isDarkThemeActive: isDark,
                        onChanged: (value) {
                          setState(() => _isDarkMode = value);
                          ThemeManager.updateTheme(value ? 'dark' : 'light');
                        },
                      ),
                      const Spacer(),
                      const SizedBox(height: 40),
                      StartButton(onPressed: _handleStart),
                      const SizedBox(height: AppConstants.defaultPadding),
                    ],
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}








