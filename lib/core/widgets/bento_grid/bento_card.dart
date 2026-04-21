import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/theme/app_layout.dart';

class BentoCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry? padding;
  final double? width;
  final double? height;
  final VoidCallback? onTap;
  final Color? bentoColor;

  const BentoCard({
    super.key,
    required this.child,
    this.padding,
    this.width,
    this.height,
    this.onTap,
    this.bentoColor,
  });

  @override
  Widget build(BuildContext context) {
    final Widget content = Padding(
      padding: padding ?? const EdgeInsets.all(AppLayout.defaultPadding),
      child: child,
    );

    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: bentoColor ?? Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).shadowColor.withValues(alpha: 0.04),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppLayout.bentoBorderRadius),
        clipBehavior: Clip.antiAlias,
        child: onTap != null
            ? InkWell(
                onTap: onTap,
                splashColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.1),
                highlightColor: Theme.of(
                  context,
                ).primaryColor.withValues(alpha: 0.05),
                child: content,
              )
            : content,
      ),
    );
  }
}
