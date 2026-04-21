// lib/core/theme/app_typography.dart

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTypography {
  AppTypography._();

  // Headings (Quicksand, Bold)
  static final TextStyle heading1 = GoogleFonts.quicksand(
    fontSize: 32,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heading2 = GoogleFonts.quicksand(
    fontSize: 24,
    fontWeight: FontWeight.bold,
  );

  static final TextStyle heading3 = GoogleFonts.quicksand(
    fontSize: 20,
    fontWeight: FontWeight.bold,
  );

  // Body (Inter)
  static final TextStyle bodyLarge = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
  );

  static final TextStyle bodyMedium = GoogleFonts.inter(
    fontSize: 14,
    fontWeight: FontWeight.normal,
  );

  // Specialized (IPA Phonetics)
  static final TextStyle ipaText = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.w500,
    letterSpacing: 0.5,
  );
}
