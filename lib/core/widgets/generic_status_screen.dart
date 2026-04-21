// lib/core/widgets/generic_status_screen.dart

import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/smart_action_button.dart';

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
    Color iconBgColor;

    switch (statusType) {
      case StatusType.success:
        iconData = Icons.check_circle_rounded;
        iconColor = const Color(0xFF10B981); // AppColors.success
        iconBgColor = const Color(
          0xFF10B981,
        ).withValues(alpha: 0.15); // Flat tint
        break;
      case StatusType.error:
        iconData = Icons.error_rounded;
        iconColor = const Color(0xFFFF4757); // AppColors.error
        iconBgColor = const Color(
          0xFFFF4757,
        ).withValues(alpha: 0.15); // Flat tint
        break;
      case StatusType.info:
        iconData = Icons.info_rounded;
        iconColor = const Color(0xFFF59E0B); // AppColors.warning
        iconBgColor = const Color(
          0xFFF59E0B,
        ).withValues(alpha: 0.15); // Flat tint
        break;
    }

    return Scaffold(
      backgroundColor: Theme.of(
        context,
      ).scaffoldBackgroundColor, // Replaces heavy mesh gradient
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24.0),
            child: BentoCard(
              // Replaced GlassBentoCard
              padding: const EdgeInsets.symmetric(
                horizontal: 24.0,
                vertical: 40.0,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min, // Hugs content vertically
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(24.0),
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      shape: BoxShape.circle,
                    ),
                    child: Icon(iconData, size: 64.0, color: iconColor),
                  ),
                  const SizedBox(height: 32.0),
                  Text(
                    title,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.displayMedium, // Using AppTheme
                  ),
                  const SizedBox(height: 16.0),
                  Text(
                    description,
                    textAlign: TextAlign.center,
                    style: Theme.of(
                      context,
                    ).textTheme.bodyLarge, // Using AppTheme
                  ),
                  const SizedBox(height: 40.0),
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
    );
  }
}
