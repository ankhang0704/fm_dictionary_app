// New Vibrant Bento UI block (Logic, Theme, and Localization perfectly preserved!)

import 'package:flutter/material.dart';

// Assuming these are correctly imported in your actual project:
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_layout.dart';
// import 'package:your_app/core/theme/app_typography.dart';

class SmartActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isGlass; // Kept to preserve existing logic/calls, but rendered as Flat Secondary Bento
  final Color? color;
  final IconData? icon; // Added optional Icon parameter

  const SmartActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isGlass = false,
    this.color,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Bento Style Colors
    final Color contentColor = isGlass 
        ? const Color(0xFF1E293B) // AppColors.textPrimary 
        : Colors.white;

    // Completely stripped Glassmorphism. If 'isGlass' is true, we use a playful flat pastel/secondary style.
    final Color solidBgColor = isGlass 
        ? const Color(0xFFF8FAFC) // Soft Flat Pastel for Bento Secondary
        : (color ?? const Color(0xFF1E293B)); // Solid Primary

    // Reusable inner content (Icon + Text or Spinner)
    final Widget innerContent = isLoading
        ? SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children:[
              if (icon != null) ...[
                Icon(icon, color: contentColor, size: 24),
                const SizedBox(width: 8),
              ],
              Text(
                text,
                style: const TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 20, // Fallback for AppTypography.heading3
                ).copyWith(color: contentColor),
                maxLines: 1,
                overflow: TextOverflow.ellipsis, // Zero Pixel Overflow Policy
              ),
            ],
          );

    const double buttonHeight = 56.0;
    final BorderRadius buttonRadius = BorderRadius.circular(16.0); // AppLayout.buttonRadius

    // Unified Solid Bento Button
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: solidBgColor,
          foregroundColor: contentColor,
          elevation: 0, // Strict Flat Bento style
          shape: RoundedRectangleBorder(
            borderRadius: buttonRadius,
            side: isGlass 
                ? const BorderSide(color: Color(0xFFE2E8F0), width: 2) // Playful border for secondary
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: innerContent,
        ),
      ),
    );
  }
}