import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE UI & THEME ---
import 'package:fm_dictionary/core/theme/app_colors.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/core/widgets/common/smart_action_button.dart';

class StreakCelebrationDialog {
  /// Static method to trigger the celebration from any screen or provider.
  static void show(BuildContext context, {required int streakDays}) {
    showGeneralDialog(
      context: context,
      barrierDismissible: true,
      barrierLabel: "StreakCelebration",
      barrierColor: Colors.black.withValues(alpha: 0.5),
      transitionDuration: const Duration(milliseconds: 600),
      // Scale + Fade "Pop" animation (LOGIC PRESERVED)
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
        final primaryTextColor = Theme.of(
          context,
        ).textTheme.displayLarge?.color;
        final secondaryTextColor = Theme.of(
          context,
        ).textTheme.bodyMedium?.color;

        return Center(
          child: SingleChildScrollView(
            child: Material(
              color: Colors.transparent,
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 340),
                  child: BentoCard(
                    // Replaced GlassBentoCard
                    padding: const EdgeInsets.all(24.0),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(height: 16),

                        // --- HERO GRAPHIC: VIBRANT BENTO FIRE ---
                        _buildBentoFire(),

                        const SizedBox(height: 24),

                        // --- TITLE ---
                        Text(
                          "streak_celebration.title".tr(), // INJECTED
                          style: Theme.of(
                            context,
                          ).textTheme.displayLarge?.copyWith(fontSize: 32),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 16),

                        // --- STREAK DESCRIPTION ---
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0),
                          child: RichText(
                            textAlign: TextAlign.center,
                            text: TextSpan(
                              style: Theme.of(context).textTheme.displaySmall
                                  ?.copyWith(
                                    fontWeight: FontWeight.normal,
                                    color: primaryTextColor,
                                  ),
                              children: [
                                TextSpan(
                                  text: "streak_celebration.reached_prefix"
                                      .tr(),
                                ), // INJECTED
                                TextSpan(
                                  text: "streak_celebration.day_count".tr(
                                    args: [streakDays.toString()],
                                  ), // INJECTED
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors
                                        .warning, // Vibrant Bento Warning
                                  ),
                                ),
                                TextSpan(
                                  text: "streak_celebration.reached_suffix"
                                      .tr(),
                                ), // INJECTED
                              ],
                            ),
                          ),
                        ),

                        const SizedBox(height: 12),

                        // --- SUBTITLE ---
                        Text(
                          "streak_celebration.subtitle".tr(), // INJECTED
                          style: Theme.of(context).textTheme.bodyMedium
                              ?.copyWith(color: secondaryTextColor),
                          textAlign: TextAlign.center,
                        ),

                        const SizedBox(height: 32),

                        // --- ACTION BUTTON ---
                        SmartActionButton(
                          text: "common.continue".tr(), // INJECTED
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

  static Widget _buildBentoFire() {
    return Stack(
      alignment: Alignment.center,
      children: [
        // Vibrant Flat Background Wrapper (Replacing Glow)
        Container(
          width: 140,
          height: 140,
          decoration: BoxDecoration(
            color: AppColors.warning.withValues(alpha: 0.15),
            shape: BoxShape.circle,
          ),
        ),

        // Inner Fire Icon with Preserved Pulse Animation
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0.9, end: 1.1),
          duration: const Duration(seconds: 1),
          curve: Curves.easeInOutSine,
          builder: (context, scale, child) {
            return Transform.scale(
              scale: scale, // Subtly "pulses" the fire (Logic Preserved)
              child: ShaderMask(
                shaderCallback: (bounds) => const LinearGradient(
                  colors: [
                    AppColors.bentoYellow,
                    AppColors.warning,
                    AppColors.error,
                  ],
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
