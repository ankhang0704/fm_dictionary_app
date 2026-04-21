// lib/core/theme/app_theme.dart

import 'package:flutter/material.dart';
import 'app_colors.dart';
import 'app_typography.dart';

class AppTheme {
  AppTheme._();

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primaryColor: AppColors.bentoBlue,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      cardColor: AppColors.bentoCardLight,
      textTheme: TextTheme(
        displayLarge: AppTypography.heading1.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displayMedium: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        displaySmall: AppTypography.heading3.copyWith(
          color: AppColors.textPrimaryLight,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textSecondaryLight,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryLight,
        ),
      ),
      colorScheme: const ColorScheme.light(
        primary: AppColors.bentoBlue,
        secondary: AppColors.bentoPurple,
        tertiary: AppColors.bentoMint,
        surface: AppColors.bentoCardLight,
        error: AppColors.error,
      ),
      useMaterial3: true,
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primaryColor: AppColors.bentoBlue,
      scaffoldBackgroundColor: AppColors.backgroundDark,
      cardColor: AppColors.bentoCardDark,
      textTheme: TextTheme(
        displayLarge: AppTypography.heading1.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displayMedium: AppTypography.heading2.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        displaySmall: AppTypography.heading3.copyWith(
          color: AppColors.textPrimaryDark,
        ),
        bodyLarge: AppTypography.bodyLarge.copyWith(
          color: AppColors.textSecondaryDark,
        ),
        bodyMedium: AppTypography.bodyMedium.copyWith(
          color: AppColors.textSecondaryDark,
        ),
      ),
      colorScheme: const ColorScheme.dark(
        primary: AppColors.bentoBlue,
        secondary: AppColors.bentoPurple,
        tertiary: AppColors.bentoMint,
        surface: AppColors.bentoCardDark,
        error: AppColors.error,
      ),
      useMaterial3: true,
    );
  }
}
