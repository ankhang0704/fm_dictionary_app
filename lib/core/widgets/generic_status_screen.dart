// lib/core/widgets/generic_status_screen.dart

import 'package:flutter/material.dart';

class GenericStatusScreen extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subTitle;
  final String primaryButtonLabel;
  final VoidCallback onPrimaryPressed;
  final Color themeColor;

  const GenericStatusScreen({
    super.key,
    required this.icon,
    required this.title,
    required this.subTitle,
    required this.primaryButtonLabel,
    required this.onPrimaryPressed,
    this.themeColor = Colors.blue,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 100, color: themeColor),
            const SizedBox(height: 24),
            Text(title, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 12),
            Text(subTitle, textAlign: TextAlign.center, style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 40),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: themeColor),
                onPressed: onPrimaryPressed,
                child: Text(primaryButtonLabel),
              ),
            ),
          ],
        ),
      ),
    );
  }
}