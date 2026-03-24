import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../services/database_service.dart';
import '../../services/theme_manager.dart';
import '../home/main_navigation.dart';

class WelcomeScreen extends StatefulWidget {
  const WelcomeScreen({super.key});

  @override
  State<WelcomeScreen> createState() => _WelcomeScreenState();
}

class _WelcomeScreenState extends State<WelcomeScreen> {
  final TextEditingController _nameController = TextEditingController();
  bool _isDarkMode = false;

  // Widget chọn ngôn ngữ dạng Tab hiện đại
  Widget _buildLanguageSelector(String currentLang) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _langTab('en', 'English 🇬🇧', currentLang == 'en'),
          _langTab('vi', 'Tiếng Việt 🇻🇳', currentLang == 'vi'),
        ],
      ),
    );
  }

  Widget _langTab(String code, String label, bool isSelected) {
    return GestureDetector(
      onTap: () => context.setLocale(Locale(code)),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        decoration: BoxDecoration(
          color: isSelected ? Colors.blue : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : Colors.grey,
            fontWeight: FontWeight.bold,
            fontSize: 14,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final currentLang = context.locale.languageCode;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 30),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 30),

              Text(
                'welcome.title'
                    .tr(), // Chú ý: .tr() chỉ chạy nếu JSON có key 'welcome' -> 'title'
                style: const TextStyle(
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  height: 1.1,
                ),
              ),             
              const SizedBox(height: 12),
              // Nút chọn ngôn ngữ đặt ở trên cùng bên phải
              Align(
                alignment: Alignment.centerRight,
                child: _buildLanguageSelector(currentLang),
              ),
              const SizedBox(height: 20),
              Text(
                'welcome.subtitle'.tr(),
                style: TextStyle(
                  fontSize: 16,
                  color: isDark ? Colors.white60 : Colors.black54,
                ),
              ),
              const SizedBox(height: 40),

              // Ô nhập tên thiết kế lại
              TextField(
                controller: _nameController,
                decoration: InputDecoration(
                  labelText: 'welcome.name_hint'.tr(),
                  filled: true,
                  fillColor: isDark
                      ? Colors.white.withValues(alpha: 0.05)
                      : Colors.grey.withValues(alpha: 0.05),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(15),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: const Icon(Icons.person_pin_rounded),
                ),
              ),
              const SizedBox(height: 20),

              // Widget chọn Theme thiết kế lại dạng Card
              InkWell(
                onTap: () {
                  setState(() => _isDarkMode = !_isDarkMode);
                  ThemeManager.updateTheme(_isDarkMode ? 'dark' : 'light');
                },
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 15,
                  ),
                  decoration: BoxDecoration(
                    color: isDark
                        ? Colors.white.withValues(alpha: 0.05)
                        : Colors.grey.withValues(alpha: 0.05),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        _isDarkMode
                            ? Icons.dark_mode_rounded
                            : Icons.light_mode_rounded,
                        color: Colors.blue,
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: Text(
                          _isDarkMode ? 'welcome.dark_mode'.tr() : 'welcome.light_mode'.tr(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ),
                      Switch(
                        value: _isDarkMode,
                        activeThumbColor: Colors.blue,
                        onChanged: (value) {
                          setState(() => _isDarkMode = value);
                          ThemeManager.updateTheme(value ? 'dark' : 'light');
                        },
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 80),

              // Nút bắt đầu thiết kế kiểu Modern
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: isDark
                        ? Colors.blue
                        : const Color(0xFF1A1A1A),
                    foregroundColor: Colors.white,
                    elevation: 0,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(18),
                    ),
                  ),
                  onPressed: () async {
                    final name = _nameController.text.trim();
                    if (name.isEmpty) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(
                          content: Text("Vui lòng nhập tên của bạn"),
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
                  },
                  child: Text(
                    'welcome.start_btn'.tr().toUpperCase(),
                    style: const TextStyle(
                      letterSpacing: 1.5,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 40),
            ],
          ),
        ),
      ),
    );
  }
}
