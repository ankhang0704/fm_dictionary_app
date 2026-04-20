import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/theme/app_colors.dart';
import 'package:fm_dictionary/core/theme/app_layout.dart';

// Assuming these are correctly imported in your actual project
// import 'package:your_app/core/theme/app_colors.dart';
// import 'package:your_app/core/theme/app_layout.dart';

class GlassBentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;

  const GlassBentoCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(AppLayout.defaultPadding),
      child: child,
    );

    return ClipRRect(
      borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(
          sigmaX: AppLayout.glassBlur,
          sigmaY: AppLayout.glassBlur,
        ),
        child: Container(
          width: width,
          height: height,
          decoration: BoxDecoration(
            color: AppColors.glassBackground,
            borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
            border: Border.all(
              color: AppColors.glassBorder,
              width: AppLayout.glassBorderWidth,
            ),
          ),
          child: onTap != null
              ? Material(
                  color: Colors.transparent,
                  child: InkWell(
                    onTap: onTap,
                    borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
                    child: content,
                  ),
                )
              : content,
        ),
      ),
    );
  }
}