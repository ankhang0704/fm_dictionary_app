import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../services/database_service.dart';
import '../home/main_navigation.dart';
import '../../core/utils/constants.dart';

class ChooseEngineScreen extends StatefulWidget {
  const ChooseEngineScreen({super.key});

  @override
  State<ChooseEngineScreen> createState() => _ChooseEngineScreenState();
}

class _ChooseEngineScreenState extends State<ChooseEngineScreen> {
  // Mặc định chọn Native (true) cho máy nhẹ
  bool _useNativeEngine = true;

  // Hàm xử lý hoàn tất Onboarding
  void _completeSetup() async {
    final settings = DatabaseService.getSettings();
    settings.useNativeEngine = _useNativeEngine;
    settings.isFirstRun = false; 
    await DatabaseService.saveSettings(settings);

    if (!mounted) return;
    
    // Chuyển thẳng vào màn hình chính của App
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const MainNavigation()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : AppConstants.textPrimary;

    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children:[
              const SizedBox(height: 60),
              Text(
                "Gần xong rồi!",
                style: TextStyle(fontSize: 36, fontWeight: FontWeight.bold, color: textColor),
              ),
              const SizedBox(height: 12),
              Text(
                "Chọn công cụ nhận diện giọng nói phù hợp với thiết bị của bạn. (Bạn có thể đổi lại sau trong Cài đặt)",
                style: TextStyle(fontSize: 16, color: AppConstants.textSecondary, height: 1.5),
              ),
              const SizedBox(height: 40),

              // Thẻ chọn Native Speech
              _buildOptionCard(
                title: "Native Speech (Khuyên dùng)",
                description: "Nhanh, siêu nhẹ, phản hồi tức thì. Cần kết nối Internet.",
                icon: CupertinoIcons.mic_fill,
                isSelected: _useNativeEngine == true,
                onTap: () => setState(() => _useNativeEngine = true),
                isDark: isDark,
              ),
              const SizedBox(height: 20),

              // Thẻ chọn Whisper AI
              _buildOptionCard(
                title: "Whisper AI (Nâng cao)",
                description: "Chính xác cao, hoạt động Offline. Nặng máy, yêu cầu cấu hình tốt.",
                icon: CupertinoIcons.mic_slash_fill,
                isSelected: _useNativeEngine == false,
                onTap: () => setState(() => _useNativeEngine = false),
                isDark: isDark,
              ),

              const Spacer(),

              // Nút Hoàn tất
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  ),
                  onPressed: _completeSetup,
                  child: const Text(
                    "HOÀN TẤT & BẮT ĐẦU", 
                    style: TextStyle(letterSpacing: 1.5, fontWeight: FontWeight.bold, fontSize: 16)
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

  // Widget vẽ cái thẻ để chọn
  Widget _buildOptionCard({
    required String title,
    required String description,
    required IconData icon,
    required bool isSelected,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isSelected 
              ? AppConstants.accentColor.withValues(alpha: 0.1) 
              : (isDark ? AppConstants.darkCardColor : Colors.white),
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? AppConstants.accentColor : Colors.grey.withValues(alpha: 0.2),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children:[
            Icon(icon, size: 40, color: isSelected ? AppConstants.accentColor : Colors.grey),
            const SizedBox(width: 20),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children:[
                  Text(title, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 6),
                  Text(description, style: TextStyle(fontSize: 13, color: AppConstants.textSecondary)),
                ],
              ),
            ),
            // Hình tròn tick chọn
            if (isSelected)
              const Icon(CupertinoIcons.checkmark_alt_circle_fill, color: AppConstants.accentColor, size: 28)
            else
              Icon(CupertinoIcons.circle, color: Colors.grey.withValues(alpha: 0.3), size: 28),
          ],
        ),
      ),
    );
  }
}