import 'package:flutter/material.dart';
import 'package:fm_dictionary/services/tts_service.dart';

class SpeakerButton extends StatelessWidget {
  const SpeakerButton({
    super.key,
    required TtsService ttsService,
    required this.context,
    required this.text,
    required this.accent,
    required this.label,
  }) : _ttsService = ttsService;

  final TtsService _ttsService;
  final BuildContext context;
  final String text;
  final String accent;
  final String label;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => _ttsService.speak(text, accent: accent),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          children: [
            const Icon(Icons.volume_up_rounded, size: 16),
            const SizedBox(width: 4),
            Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}
