// file: lib/features/search/word_detail_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/data/models/word_model.dart';
import 'package:fm_dictionary/data/services/ai_speech/text_to_speech/speech_service.dart';


class WordDetailScreen extends StatelessWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final TtsService ttsService = TtsService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
          decoration: BoxDecoration(color: AppConstants.accentColor.withValues(alpha: 0.1), borderRadius: BorderRadius.circular(20)),
          child: Text(word.topic.toUpperCase(), style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppConstants.accentColor, letterSpacing: 1.5)),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // BENTO 1: TỪ VÀ PHÁT ÂM
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Column(
                children: [
                  Text(word.word, style: const TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (word.phoneticUS.isNotEmpty) _buildSpeakBtn('US', word.phoneticUS, () => ttsService.speak(word.word, accent: 'en-US'), isDark),
                      const SizedBox(width: 12),
                      if (word.phoneticUK.isNotEmpty) _buildSpeakBtn('UK', word.phoneticUK, () => ttsService.speak(word.word, accent: 'en-GB'), isDark),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),

            // BENTO 2: Ý NGHĨA
            const Text(' Ý nghĩa', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
              ),
              child: Text(word.meaning, style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 20),

            // BENTO 3: VÍ DỤ
            const Text(' Ví dụ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.grey)),
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.05),
                borderRadius: BorderRadius.circular(24),
                border: Border.all(color: AppConstants.accentColor.withValues(alpha: 0.2)),
              ),
              child: Text(
                "\"${word.example}\"",
                style: const TextStyle(fontSize: 18, fontStyle: FontStyle.italic, height: 1.5),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSpeakBtn(String label, String ipa, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(16),
        ),
        child: Row(
          children: [
            Text(label, style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.grey)),
            const SizedBox(width: 8),
            Text(ipa, style: const TextStyle(fontWeight: FontWeight.w500)),
            const SizedBox(width: 8),
            const Icon(CupertinoIcons.speaker_2_fill, size: 16, color: AppConstants.accentColor),
          ],
        ),
      ),
    );
  }
}