// lib/core/widgets/common/smart_action_button.dart

import 'dart:ui';
import 'package:flutter/material.dart';

// Assuming these are correctly imported in your actual project:
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_layout.dart';
// import 'package:your_app/core/theme/app_typography.dart';

class SmartActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isGlass;
  final Color? color;

  const SmartActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isGlass = false,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    // Determine text and spinner color based on glass state
    // Glass: Slate 800, Solid: White
    final Color contentColor = isGlass 
        ? const Color(0xFF1E293B) // AppColors.textPrimary 
        : Colors.white;

    // Default solid background color if not provided
    final Color solidBgColor = color ?? const Color(0xFF1E293B); // AppColors.textPrimary

    // Reusable inner content (Text or Spinner)
    final Widget innerContent = isLoading
        ? SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          )
        : Text(
            text,
            style: const TextStyle(
              fontFamily: 'Quicksand',
              fontWeight: FontWeight.bold,
              fontSize: 20, // Fallback for AppTypography.heading3
            ).copyWith(color: contentColor),
            maxLines: 1,
            overflow: TextOverflow.ellipsis, // Zero Pixel Overflow Policy
          );

    final double buttonHeight = 56.0;
    final BorderRadius buttonRadius = BorderRadius.circular(16.0); // AppLayout.buttonRadius

    if (isGlass) {
      return ClipRRect(
        borderRadius: buttonRadius,
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            height: buttonHeight,
            width: double.infinity,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              borderRadius: buttonRadius,
              border: Border.all(
                color: Colors.white.withValues(alpha:0.5),
                width: 1.0,
              ),
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: isLoading ? null : onPressed,
                borderRadius: buttonRadius,
                child: Center(
                  // FittedBox ensures text shrinks instead of overflowing if translated text is too long
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: innerContent,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ),
      );
    }

    // Solid Button
    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: solidBgColor,
          foregroundColor: contentColor,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: buttonRadius,
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