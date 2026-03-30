import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../services/ai_speech/text_to_speech/speech_service.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final TtsService ttsService = TtsService();
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(word.topic, style: const TextStyle(fontSize: 16)),
        centerTitle: true,
      ),
      body: SingleChildScrollView( // Thêm SingleChildScrollView chống overflow trục dọc
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            // Từ vựng
            Text(word.word, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            
            // Phiên âm (IPA)
            Text(
              word.phoneticUS.isNotEmpty ? word.phoneticUS : word.phoneticUK,
              style: TextStyle(fontSize: 20, color: theme.colorScheme.primary, fontFamily: 'sans-serif'),
            ),
            const SizedBox(height: 20),

            // Nút phát âm US và UK (Nằm dưới IPA)
            Row(
              children:[
                _buildSpeakerButton(context, ttsService, word.word, 'en-US', 'US'),
                const SizedBox(width: 16),
                _buildSpeakerButton(context, ttsService, word.word, 'en-GB', 'UK'),
              ],
            ),
            const Divider(height: 40),

            // Meaning
             Text('word.meaning'.tr(), style: TextStyle(color: Colors.grey, letterSpacing: 1.5, fontSize: 12)),
            const SizedBox(height: 8),
            Text(word.meaning, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w600)),
            
            const SizedBox(height: 32),

            // Example
             Text('word.example'.tr(), style: TextStyle(color: Colors.grey, letterSpacing: 1.5, fontSize: 12)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity, // Đảm bảo full chiều ngang
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: theme.colorScheme.primary.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.1)),
              ),
              child: Text(
                word.example,
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget vẽ nút loa
  Widget _buildSpeakerButton(BuildContext context, TtsService tts, String text, String accent, String label) {
    final theme = Theme.of(context);
    return InkWell(
      onTap: () => tts.speak(text, accent: accent),
      borderRadius: BorderRadius.circular(20),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          color: theme.cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children:[
            Icon(Icons.volume_up_rounded, size: 20, color: theme.colorScheme.primary),
            const SizedBox(width: 8),
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}