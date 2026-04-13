import 'package:flutter/material.dart';
import '../../constants/constants.dart'; // Import hằng số của bạn

class StreakCelebrationScreen extends StatelessWidget {
  final int streakCount;

  const StreakCelebrationScreen({super.key, required this.streakCount});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Hiệu ứng phình to ngọn lửa đơn giản
            TweenAnimationBuilder(
              tween: Tween<double>(begin: 0.5, end: 1.0),
              duration: const Duration(milliseconds: 800),
              curve: Curves.elasticOut,
              builder: (context, scale, child) {
                return Transform.scale(
                  scale: scale,
                  child: const Text('🔥', style: TextStyle(fontSize: 120)),
                );
              },
            ),
            const SizedBox(height: 24),
            Text(
              'Tuyệt vời!',
              style: AppConstants.headingStyle.copyWith(
                fontSize: 28,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              'Bạn đã giữ chuỗi học tập được',
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 16,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(height: 10),
            Text(
              '$streakCount Ngày',
              style: AppConstants.headingStyle.copyWith(
                fontSize: 40,
                color: AppConstants.accentColor,
              ),
            ),
            const SizedBox(height: 40),
            
            // Nút tiếp tục học
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: SizedBox(
                width: double.infinity,
                height: 56,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppConstants.accentColor,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
                    ),
                    elevation: 5,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Đóng màn hình chúc mừng, quay lại học tiếp
                  },
                  child: const Text(
                    'Tiếp tục học',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.white),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}