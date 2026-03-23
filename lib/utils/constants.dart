import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'FM Dictionary';
  
  // Colors
  static const Color primaryColor = Color(0xFF1A1A1A);
  static const Color accentColor = Color(0xFFF27D26);
  static const Color backgroundColor = Color(0xFFFDFCF9);
  static const Color darkBgColor = Color(0xFF121212);
  static const Color darkCardColor = Color(0xFF1E1E1E);
  static const Color cardColor = Colors.white;
  static const Color textPrimary = Color(0xFF1A1A1A);
  static const Color textSecondary = Colors.grey;
  static const Color textLight = Color(0xFF9E9E9E);
  static const Color successColor = Color(0xFF4CAF50);
  static const Color errorColor = Color(0xFFF44336);

  // Fonts
  static final String bodyFont = 'Inter';
  static final String displayFont = 'PlayfairDisplay';

  // Text Styles
  static const TextStyle headingStyle = TextStyle(
    fontSize: 28,
    fontWeight: FontWeight.bold,
    fontFamily: 'Playfair Display', // We'll use the font family name directly
    fontStyle: FontStyle.italic,
  );

  static const TextStyle subHeadingStyle = TextStyle(
    fontSize: 12,
    letterSpacing: 2,
    color: Colors.grey,
    fontWeight: FontWeight.bold,
  );

  static const TextStyle wordStyle = TextStyle(
    fontSize: 36,
    fontWeight: FontWeight.bold,
    fontFamily: 'Playfair Display',
    letterSpacing: -0.5,
  );

  // Layout
  static const double defaultPadding = 24.0;
  static const double cardRadius = 32.0;
  static const double buttonRadius = 20.0;
  
  // Animations
  static const Duration flipDuration = Duration(milliseconds: 400);

  // Topic Icons Mapping
  static const Map<String, IconData> topicIcons = {
    'General Facilities Management': Icons.business_rounded,
    'Hard Services': Icons.build_rounded,
    'Soft Services': Icons.cleaning_services_rounded,
    'Finance': Icons.payments_rounded,
    'Procurement': Icons.shopping_cart_rounded,
    'Workplace Experience': Icons.sentiment_satisfied_alt_rounded,
    'ESS': Icons.badge_rounded,
    'HSSE': Icons.security_rounded,
    'Technology': Icons.memory_rounded,
    'Human Resources': Icons.groups_rounded,
    'Laws, Ethics & BCP': Icons.gavel_rounded,
  };
}
