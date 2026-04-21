import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // Mesh Gradient
  static const Color meshBlue = Color(0xFF4A90E2);
  static const Color meshPurple = Color(0xFF9013FE);
  static const Color meshMint = Color(0xFF50E3C2);

  // Glassmorphism
  static final Color glassBackground = Colors.white.withValues(alpha: 0.25);
  static final Color glassBorder = Colors.white.withValues(alpha: 0.50);

  // Text
  static const Color textPrimary = Color.fromARGB(255, 7, 10, 14);
  static const Color textSecondary = Color.fromARGB(255, 0, 0, 0);

  // Semantic & Background
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFF4757);
  static const Color background = Color(0xFFF8FAFC);
}