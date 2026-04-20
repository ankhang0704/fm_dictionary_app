// lib/core/widgets/generic_status_screen.dart

import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/smart_action_button.dart';

// Assuming these are imported in your actual project:
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_typography.dart';
// import 'package:your_app/core/widgets/bento_grid/glass_bento_card.dart';
// import 'package:your_app/core/widgets/common/smart_action_button.dart';

enum StatusType { success, error, info }

class GenericStatusScreen extends StatelessWidget {
  final StatusType statusType;
  final String title;
  final String description;
  final String buttonText;
  final VoidCallback? onAction;

  const GenericStatusScreen({
    super.key,
    required this.statusType,
    required this.title,
    required this.description,
    this.buttonText = 'Continue',
    this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    IconData iconData;
    Color iconColor;

    switch (statusType) {
      case StatusType.success:
        iconData = Icons.check_circle_rounded;
        iconColor = const Color(0xFF10B981); // AppColors.success
        break;
      case StatusType.error:
        iconData = Icons.error_rounded;
        iconColor = const Color(0xFFFF4757); // AppColors.error
        break;
      case StatusType.info:
        iconData = Icons.info_rounded;
        iconColor = const Color(0xFFF59E0B); // AppColors.warning
        break;
    }

    return Scaffold(
      extendBodyBehindAppBar: true,
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF4A90E2), // AppColors.meshSoftBlue
              Color(0xFF9013FE), // AppColors.meshVibrantPurple
              Color(0xFF50E3C2), // AppColors.meshMint
            ],
          ),
        ),
        child: SafeArea(
          child: Center(
            // SingleChildScrollView + Padding prevents rendering overflow on small screens
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24.0),
              child: GlassBentoCard(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 40.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min, // Hugs content vertically
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      iconData,
                      size: 80.0,
                      color: iconColor,
                    ),
                    const SizedBox(height: 24.0),
                    Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Quicksand',
                        fontWeight: FontWeight.bold,
                        fontSize: 24,
                        color: Color(0xFF1E293B), // AppColors.textPrimary
                      ), // Fallback for AppTypography.heading2
                    ),
                    const SizedBox(height: 16.0),
                    Text(
                      description,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 16,
                        fontWeight: FontWeight.normal,
                        color: Color(0xFF64748B), // AppColors.textSecondary
                        height: 1.5,
                      ), // Fallback for AppTypography.bodyText
                    ),
                    const SizedBox(height: 40.0),
                    // Assuming SmartActionButton is globally available as requested
                    SmartActionButton(
                      text: buttonText,
                      onPressed: () {
                        if (onAction != null) {
                          onAction!();
                        } else {
                          Navigator.of(context).pop();
                        }
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}