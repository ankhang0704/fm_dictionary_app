// lib/core/utils/status_navigator.dart

import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/generic_status_screen.dart';
// import 'package:your_app/core/widgets/generic_status_screen.dart';

class StatusNavigator {
  StatusNavigator._();

  static Future<void> showSuccess({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Continue',
    VoidCallback? onAction,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GenericStatusScreen(
          statusType: StatusType.success,
          title: title,
          description: message,
          buttonText: buttonText,
          onAction: onAction,
        ),
      ),
    );
  }

  static Future<void> showError({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Go Back',
    VoidCallback? onAction,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GenericStatusScreen(
          statusType: StatusType.error,
          title: title,
          description: message,
          buttonText: buttonText,
          onAction: onAction,
        ),
      ),
    );
  }

  static Future<void> showInfo({
    required BuildContext context,
    required String title,
    required String message,
    String buttonText = 'Got it',
    VoidCallback? onAction,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute(
        builder: (_) => GenericStatusScreen(
          statusType: StatusType.info,
          title: title,
          description: message,
          buttonText: buttonText,
          onAction: onAction,
        ),
      ),
    );
  }
}