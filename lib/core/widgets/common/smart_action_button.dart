import 'package:flutter/material.dart';

class SmartActionButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool
  isGlass; // Giữ lại để không vỡ logic cũ, nhưng render theo Flat Secondary Bento
  final Color? color;
  final Color?
  textColor; // Thêm tùy chọn màu chữ để linh hoạt với các màu nền Vibrant
  final IconData? icon;

  const SmartActionButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.isLoading = false,
    this.isGlass = false,
    this.color,
    this.textColor,
    this.icon,
  });

  @override
  Widget build(BuildContext context) {
    // Bento Style Colors
    final Color solidBgColor =
        color ??
        (isGlass
            ? const Color(0xFFF1F5F9) // Slate 100 - Soft Flat Pastel
            : const Color(0xFF1E293B)); // Dark Primary default

    final Color contentColor =
        textColor ??
        (isGlass
            ? const Color(0xFF0F172A) // Slate 900
            : Colors.white);

    // Premium Circular Icon Wrapper (Bento UI standard)
    Widget? iconWidget;
    if (icon != null) {
      iconWidget = Container(
        padding: const EdgeInsets.all(6),
        decoration: BoxDecoration(
          color: contentColor.withValues(
           alpha:  0.15,
          ), // Nền mờ nhẹ tương phản với icon
          shape: BoxShape.circle,
        ),
        child: Icon(icon, color: contentColor, size: 18),
      );
    }

    // Reusable inner content
    final Widget innerContent = isLoading
        ? SizedBox(
            width: 24.0,
            height: 24.0,
            child: CircularProgressIndicator(
              strokeWidth: 2.5,
              valueColor: AlwaysStoppedAnimation<Color>(contentColor),
            ),
          )
        : Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              if (iconWidget != null) ...[
                iconWidget,
                const SizedBox(width: 10),
              ],
              Text(
                text,
                style: TextStyle(
                  fontFamily: 'Quicksand',
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: contentColor,
                  letterSpacing: 0.3,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          );

    const double buttonHeight = 56.0;
    final BorderRadius buttonRadius = BorderRadius.circular(
      20.0,
    ); // Playful rounded corners

    return SizedBox(
      height: buttonHeight,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: isLoading ? null : onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: solidBgColor,
          foregroundColor: contentColor,
          elevation: 0, // Tuyệt đối phẳng (Flat Bento)
          shape: RoundedRectangleBorder(
            borderRadius: buttonRadius,
            side: isGlass
                ? const BorderSide(color: Color(0xFFE2E8F0), width: 2)
                : BorderSide.none,
          ),
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
        ),
        child: FittedBox(fit: BoxFit.scaleDown, child: innerContent),
      ),
    );
  }
}
