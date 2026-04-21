import 'package:flutter/material.dart';

class AppColors {
  AppColors._(); // Prevent instantiation

  // Mesh Gradient
  // static const Color meshBlue = Color(0xFF4A90E2);
  // static const Color meshPurple = Color(0xFF9013FE);
  // static const Color meshMint = Color(0xFF50E3C2);
  static const Color meshBlue = Color.fromARGB(255, 255, 255, 255);
  static const Color meshPurple = Color.fromARGB(255, 255, 255, 255);
  static const Color meshMint = Color.fromARGB(255, 255, 255, 255);
  // Glassmorphism
  // static final Color glassBackground = const Color.fromARGB(255, 141, 141, 141).withValues(alpha: 0.25);
  // static final Color glassBorder = const Color.fromARGB(255, 140, 140, 140).withValues(alpha: 0.50);
  static final Color glassBackground = const Color.fromARGB(255, 30, 30, 30).withValues(alpha: 0.25);
  static final Color glassBorder = const Color.fromARGB(255, 37, 37, 37).withValues(alpha: 0.50);
  // Text
  static const Color textPrimary = Color.fromARGB(255, 7, 10, 14);
  static const Color textSecondary = Color.fromARGB(255, 39, 39, 39);
  

  // Semantic & Background
  static const Color success = Color(0xFF10B981);
  static const Color warning = Color(0xFFF59E0B);
  static const Color error = Color(0xFFFF4757);
  static const Color background = Color(0xFFF8FAFC);
}
