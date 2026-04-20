// lib/core/utils/loading.dart

import 'dart:ui';
import 'package:flutter/material.dart';

// Assuming these are correctly imported in your actual project:
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_layout.dart';
// import 'package:your_app/core/theme/app_typography.dart';

class AppLoading {
  // Private constructor to prevent instantiation
  AppLoading._();

  static void show(BuildContext context, {String? message}) {
    showDialog(
      context: context,
      barrierDismissible: false,
      barrierColor: Colors.black.withValues(alpha: 0.2),
      builder: (BuildContext dialogContext) {
        return PopScope(
          canPop: false, // Prevents dismissal via the Android back button
          child: Center(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(24.0), // AppLayout.bentoRadius
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
                child: Container(
                  constraints: const BoxConstraints(
                    minWidth: 120.0,
                    minHeight: 120.0,
                    maxWidth: 240.0, // Prevents container from stretching too wide
                  ),
                  padding: const EdgeInsets.all(24.0),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha:0.25),
                    borderRadius: BorderRadius.circular(24.0),
                    border: Border.all(
                      color: Colors.white.withValues(alpha:0.5),
                      width: 1.0,
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min, // Hugs content vertically
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      const CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(
                          Color(0xFF4A90E2), // AppColors.meshSoftBlue
                        ),
                      ),
                      if (message != null) ...[
                        const SizedBox(height: 16.0),
                        // Flexible + Text constraints to support Zero Pixel Overflow Policy
                        Flexible(
                          child: Text(
                            message,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Color(0xFF1E293B), // AppColors.textPrimary
                            ), // Fallback: replace with AppTypography.bodyTextSmall
                            maxLines: 2,
                            overflow: TextOverflow.ellipsis,
                            softWrap: true,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static void hide(BuildContext context) {
    Navigator.of(context, rootNavigator: true).pop();
  }
}