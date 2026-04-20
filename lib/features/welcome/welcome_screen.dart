import 'dart:ui';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/features/home/presentation/screens/main_navigation.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';
import '../../../../core/widgets/common/smart_action_button.dart';

// --- SERVICES & DATA ---
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/ui_management/theme_manager.dart';

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
    // Initialize theme state based on current system setting
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

  // --- LEGACY LOGIC: SAVE & START ---
  void _handleStart() async {
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text("welcome.name_required".tr()),
          backgroundColor: AppColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(
              AppLayout.bentoBorderRadius / 2,
            ),
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

    // Navigate to Main Hub
    navigator.pushReplacement(
      CupertinoPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background (Strict Rule)
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
        body: SafeArea(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.symmetric(
              horizontal: AppLayout.defaultPadding,
            ),
            child: Column(
              children: [
                const SizedBox(height: 60),

                // HEADER SECTION
                _buildHeader(),

                const SizedBox(height: 48),

                // BENTO SETUP GRID
                _buildNameInputCard(),
                const SizedBox(height: 16),

                Row(
                  children: [
                    Expanded(child: _buildLanguageCard()),
                    const SizedBox(width: 16),
                    Expanded(child: _buildThemeToggleCard()),
                  ],
                ),

                const SizedBox(height: 60),

                // PRIMARY ACTION
                SmartActionButton(
                  text: "Bắt đầu hành trình 🚀",
                  isGlass: false,
                  isLoading: false,
                  onPressed: _handleStart,
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

  Widget _buildHeader() {
    return Column(
      children: [
        Text(
          "Chào mừng bạn! 👋",
          style: AppTypography.heading1.copyWith(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Hãy thiết lập không gian học tập\ncủa riêng bạn.",
          style: AppTypography.bodyLarge.copyWith(
            color: AppColors.textPrimary.withValues(alpha: 0.8),
          ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameInputCard() {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tên của bạn",
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
              color: AppColors.textSecondary,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _nameController,
            style: AppTypography.heading2.copyWith(
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: "Nhập tên tại đây...",
              hintStyle: TextStyle(
                color: AppColors.textPrimary.withValues(alpha: 0.3),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard() {
    final currentLang = context.locale.languageCode;
    final isVi = currentLang == 'vi';

    return GlassBentoCard(
      onTap: () => _showLanguagePicker(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(CupertinoIcons.globe, color: AppColors.meshMint, size: 28),
          const SizedBox(height: 12),
          Text(
            "Ngôn ngữ",
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          FittedBox(
            child: Text(
              isVi ? "Tiếng Việt 🇻🇳" : "English 🇬🇧",
              style: AppTypography.bodyMedium.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleCard() {
    return GlassBentoCard(
      onTap: () {
        setState(() => _isDarkMode = !_isDarkMode);
        ThemeManager.updateTheme(_isDarkMode ? 'dark' : 'light');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AnimatedSwitcher(
            duration: const Duration(milliseconds: 300),
            child: Icon(
              _isDarkMode
                  ? CupertinoIcons.moon_stars_fill
                  : CupertinoIcons.sun_max_fill,
              key: ValueKey(_isDarkMode),
              color: _isDarkMode ? Colors.amber : AppColors.meshBlue,
              size: 28,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Giao diện",
            style: AppTypography.bodyLarge.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            _isDarkMode ? "Tối" : "Sáng",
            style: AppTypography.bodyMedium.copyWith(
              color: AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }

  // --- LANGUAGE PICKER SHEET ---
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppLayout.bentoBorderRadius),
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            padding: const EdgeInsets.all(AppLayout.defaultPadding),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.1),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.2)),
              ),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                _buildLangTile("Tiếng Việt", "🇻🇳", "vi"),
                const Divider(color: Colors.white10),
                _buildLangTile("English", "🇬🇧", "en"),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLangTile(String title, String flag, String code) {
    final isSelected = context.locale.languageCode == code;
    return ListTile(
      leading: Text(flag, style: const TextStyle(fontSize: 24)),
      title: Text(
        title,
        style: AppTypography.bodyLarge.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.meshMint : AppColors.textPrimary,
        ),
      ),
      trailing: isSelected
          ? const Icon(CupertinoIcons.checkmark_alt, color: AppColors.meshMint)
          : null,
      onTap: () {
        context.setLocale(Locale(code));
        Navigator.pop(context);
        setState(() {}); // Refresh language card
      },
    );
  }
}
