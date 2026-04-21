import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../../data/services/ai_speech/text_to_speech/speech_service.dart';
import '../../theme/app_colors.dart';

class GlassTtsButton extends StatelessWidget {
  final String text;
  final String accent;
  final double size;
  const GlassTtsButton({
    super.key,
    required this.text,
    this.accent = 'en-US',
    this.size = 20,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        shape: BoxShape.circle,
      ),
      child: IconButton(
        icon: Icon(CupertinoIcons.speaker_2_fill,
            color: AppColors.textPrimary, size: size),
        onPressed: () => TtsService().speak(text, accent: accent),
      ),
    );
  }
}