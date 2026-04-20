import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/theme/app_colors.dart';
import 'package:fm_dictionary/core/theme/app_typography.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/smart_action_button.dart';

// --- CORE UI & THEME ---


class StreakCelebrationDialog {
  /// Static method to trigger the celebration from any screen or provider.
  static void show(BuildContext context, {required int streakDays}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "StreakCelebration",
      barrierColor: Colors.black.withValues(alpha:0.5),
      transitionDuration: const Duration(milliseconds: 600),
      // Scale + Fade "Pop" animation
      transitionBuilder: (context, animation, secondaryAnimation, child) {
        final curve = CurvedAnimation(
          parent: animation,
          curve: Curves.elasticOut,
        );
        return ScaleTransition(
          scale: curve,
          child: FadeTransition(opacity: animation, child: child),
        );
      },
      pageBuilder: (context, animation, secondaryAnimation) {
        return Center(
          child: SingleChildScrollView(
            // ZERO OVERFLOW: Support small screens
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: GlassBentoCard(
                    onTap: null,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),

                        // --- HERO GRAPHIC: VIVID GLOWING FIRE ---
                        _buildGlowingFire(),

                        const SizedBox(height: 24),

                        // --- TITLE ---
                        Text(
                          "Tuyệt vời!",
                          style: AppTypography.heading1.copyWith(
                            color: AppColors.textPrimary,
                            fontSize: 32,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // --- STREAK DESCRIPTION ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: AppTypography.heading3.copyWith(
                                color: AppColors.textPrimary,
                                fontWeight: FontWeight.normal,
                              ),
                              children: [
                                const TextSpan(text: "Bạn đã đạt chuỗi "),
                                TextSpan(
                                  text: "$streakDays ngày",
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: Colors.orangeAccent,
                                  ),
                                ),
                                const TextSpan(text: " học liên tiếp!"),
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- SUBTITLE ---
                        Text(
                          "Giữ vững phong độ này nhé 🔥",
                          style: AppTypography.bodyMedium.copyWith(
                            color: AppColors.textSecondary,
                          ),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // --- ACTION BUTTON ---
                        SmartActionButton(
                          text: "Tiếp tục",
                          isGlass: false,
                          onPressed: () => Navigator.pop(context),
                        ),

                        const SizedBox(height: 8),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  static Widget _buildGlowingFire() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Outer Glow
        Container(
          width: 100,
          height: 100,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Colors.orange.withValues(alpha:0.4),
                blurRadius: 40,
                spreadRadius: 5,
              ),
            ],
          ),
        ),

        // Inner Fire Icon
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.8, end: 1.2),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOutSine,
          onEnd:
              () {}, // Optional: Add looping logic if using a stateful wrapper
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale, // Subtly "pulses" the fire
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [Colors.yellow, Colors.orange, Colors.redAccent],
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                ).createShader(bounds),
                child: const Icon(
                  CupertinoIcons.flame_fill,
                  size: 100,
                  color: Colors.white,
                ),
              ),
            );
          },
        ),
      ],
    );
  }
}
