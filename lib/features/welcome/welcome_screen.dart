import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/features/home/presentation/screens/main_navigation.dart';

// --- CORE UI & THEME ---
import '../../../../core/theme/app_colors.dart';
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

  // --- ABSOLUTE ZERO-TOUCH BUSINESS LOGIC ---
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppLayout.defaultPadding),
          child: Column(
            children: [
              const SizedBox(height: 60),

              // HEADER SECTION
              _buildHeader(context),

              const SizedBox(height: 48),

              // VIBRANT BENTO SETUP GRID
              _buildNameInputCard(context),
              const SizedBox(height: 16),

              Row(
                children: [
                  Expanded(child: _buildLanguageCard(context)),
                  const SizedBox(width: 16),
                  Expanded(child: _buildThemeToggleCard(context)),
                ],
              ),

              const SizedBox(height: 60),

              // PRIMARY ACTION
              SmartActionButton(
                text: "Bắt đầu hành trình 🚀",
                onPressed: _handleStart,
              ),

              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  Widget _buildHeader(BuildContext context) {
    return Column(
      children: [
        Text(
          "Chào mừng bạn! 👋",
          style: Theme.of(
            context,
          ).textTheme.displayLarge?.copyWith(fontSize: 32),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 12),
        Text(
          "Hãy thiết lập không gian học tập\ncủa riêng bạn.",
          style: Theme.of(context).textTheme.bodyLarge,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildNameInputCard(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            "Tên của bạn",
            style: Theme.of(
              context,
            ).textTheme.bodySmall?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _nameController,
            style: Theme.of(context).textTheme.displaySmall,
            decoration: InputDecoration(
              hintText: "Nhập tên tại đây...",
              hintStyle: Theme.of(context).textTheme.displaySmall?.copyWith(
                color: Theme.of(
                  context,
                ).textTheme.displaySmall?.color?.withValues(alpha: 0.3),
              ),
              border: InputBorder.none,
              contentPadding: EdgeInsets.zero,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLanguageCard(BuildContext context) {
    final currentLang = context.locale.languageCode;
    final isVi = currentLang == 'vi';

    return BentoCard(
      onTap: () => _showLanguagePicker(),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bentoMint.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              CupertinoIcons.globe,
              color: AppColors.bentoMint,
              size: 24,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Ngôn ngữ",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            isVi ? "Tiếng Việt 🇻🇳" : "English 🇬🇧",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeToggleCard(BuildContext context) {
    return BentoCard(
      onTap: () {
        setState(() => _isDarkMode = !_isDarkMode);
        ThemeManager.updateTheme(_isDarkMode ? 'dark' : 'light');
      },
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: AppColors.bentoBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: AnimatedSwitcher(
              duration: const Duration(milliseconds: 300),
              child: Icon(
                _isDarkMode
                    ? CupertinoIcons.moon_stars_fill
                    : CupertinoIcons.sun_max_fill,
                key: ValueKey(_isDarkMode),
                color: _isDarkMode ? Colors.amber : AppColors.bentoBlue,
                size: 24,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            "Giao diện",
            style: Theme.of(
              context,
            ).textTheme.bodyLarge?.copyWith(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            _isDarkMode ? "Tối" : "Sáng",
            style: Theme.of(context).textTheme.bodySmall,
          ),
        ],
      ),
    );
  }

  // --- LANGUAGE PICKER (BENTO BOTTOM SHEET) ---
  void _showLanguagePicker() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (context) => Container(
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppLayout.bentoBorderRadius),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              margin: const EdgeInsets.only(bottom: 24),
              decoration: BoxDecoration(
                color: Theme.of(context).dividerColor.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(10),
              ),
            ),
            _buildLangTile("Tiếng Việt", "🇻🇳", "vi"),
            const Divider(height: 1, indent: 56),
            _buildLangTile("English", "🇬🇧", "en"),
            const SizedBox(height: 40),
          ],
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
        style: Theme.of(context).textTheme.bodyLarge?.copyWith(
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
          color: isSelected ? AppColors.bentoMint : null,
        ),
      ),
      trailing: isSelected
          ? const Icon(CupertinoIcons.checkmark_alt, color: AppColors.bentoMint)
          : null,
      onTap: () {
        context.setLocale(Locale(code));
        Navigator.pop(context);
        setState(() {}); // Refresh local UI state
      },
    );
  }
}
