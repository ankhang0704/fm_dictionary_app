// lib/core/widgets/common/glass_bottom_sheet.dart

import 'dart:ui';
import 'package:flutter/material.dart';

// Assuming these are imported
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_layout.dart';

Future<T?> showGlassBottomSheet<T>({
  required BuildContext context,
  required Widget child,
  bool isScrollControlled = true,
}) {
  return showModalBottomSheet<T>(
    context: context,
    backgroundColor: Colors.transparent,
    elevation: 0,
    isScrollControlled: isScrollControlled,
    builder: (BuildContext context) {
      return ClipRRect(
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(24.0), // AppLayout.bentoRadius
        ),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.25),
              border: Border(
                top: BorderSide(
                  color: Colors.white.withValues(alpha:0.5),
                  width: 1.0,
                ),
              ),
            ),
            child: SafeArea(
              child: Padding(
                padding: EdgeInsets.only(
                  bottom: MediaQuery.of(context).viewInsets.bottom,
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const SizedBox(height: 12),
                    // Drag Handle
                    Container(
                      width: 48,
                      height: 5,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha:0.5),
                        borderRadius: BorderRadius.circular(10.0),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Prevent overflow for dynamic child content
                    Flexible(
                      child: SingleChildScrollView(
                        child: child,
                      ),
                    ),
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