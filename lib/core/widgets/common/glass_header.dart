// lib/core/widgets/common/glass_header.dart
import 'dart:ui';
import 'package:flutter/material.dart';

// Assuming these are imported
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_layout.dart';
// import 'package:your_app/core/theme/app_typography.dart';

class GlassHeader extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final Widget? trailing;
  final VoidCallback? onBackPressed;

  const GlassHeader({
    super.key,
    required this.title,
    this.trailing,
    this.onBackPressed,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      automaticallyImplyLeading: false,
      leading: Padding(
        padding: const EdgeInsets.only(left: 16.0, top: 8.0, bottom: 8.0),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24.0), // AppLayout.bentoRadius
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15.0, sigmaY: 15.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.25),
                borderRadius: BorderRadius.circular(24.0),
                border: Border.all(
                  color: Colors.white.withOpacity(0.5),
                  width: 1.0,
                ),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.arrow_back_rounded,
                  color: Color(0xFF1E293B), // AppColors.textPrimary
                  size: 20,
                ),
                onPressed: onBackPressed ?? () => Navigator.of(context).pop(),
              ),
            ),
          ),
        ),
      ),
      title: Text(
        title,
        style: const TextStyle(
          fontFamily: 'Quicksand',
          fontWeight: FontWeight.bold,
          fontSize: 20,
          color: Color(0xFF1E293B), // AppColors.textPrimary
        ), // Fallback: Replace with AppTypography.heading3
        maxLines: 1,
        overflow: TextOverflow.ellipsis, // Zero pixel overflow policy
      ),
      actions: [
        if (trailing != null)
          Padding(
            padding: const EdgeInsets.only(right: 16.0),
            child: Center(child: trailing!),
          ),
      ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(60.0);
}