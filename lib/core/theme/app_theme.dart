import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      primaryColor: const Color.fromARGB(255, 255, 255, 255),
      scaffoldBackgroundColor: AppColors.background,
      
      // Map custom typography to standard Material TextTheme
      textTheme: TextTheme(
        displayLarge: AppTypography.heading1,
        displayMedium: AppTypography.heading2,
        displaySmall: AppTypography.heading3,
        bodyLarge: AppTypography.bodyLarge,
        bodyMedium: AppTypography.bodyMedium,
      ),
      
      // Setup a modern color scheme referencing the design system
      colorScheme: ColorScheme.light(
        primary: AppColors.meshBlue,
        secondary: AppColors.meshPurple,
        tertiary: AppColors.meshMint,
        background: AppColors.background,
        error: AppColors.error,
      ),
      
      useMaterial3: true,
    );
  }
}