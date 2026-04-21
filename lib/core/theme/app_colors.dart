// lib/core/theme/app_colors.dart

import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // Vibrant Bento UI Colors (Playful, Solid, Flat)
  static const Color bentoBlue = Color(0xFF4A90E2);
  static const Color bentoPurple = Color(0xFF9013FE);
  static const Color bentoMint = Color(0xFF50E3C2);
  static const Color bentoYellow = Color(0xFFFDCB6E);
  static const Color bentoPink = Color(0xFFFF6B81);

  // Bento Card Surfaces
  static const Color bentoCardLight = Color(0xFFFFFFFF);
  static const Color bentoCardDark = Color(0xFF1E293B);

  // Text
  static const Color textPrimaryLight = Color(0xFF0F172A);
  static const Color textSecondaryLight = Color(0xFF64748B);
  static const Color textPrimaryDark = Color(0xFFF8FAFC);
  static const Color textSecondaryDark = Color(0xFF94A3B8);

  // Semantic & Background
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFF4757);
  static const Color backgroundLight = Color(0xFFF8FAFC);
  static const Color backgroundDark = Color.fromARGB(255, 49, 49, 49);
}
