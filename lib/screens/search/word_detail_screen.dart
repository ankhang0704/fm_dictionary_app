// file: lib/screens/search/word_detail_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../models/word_model.dart';
import '../../services/ai_speech/text_to_speech/speech_service.dart';
import '../../core/constants/constants.dart';

class WordDetailScreen extends StatelessWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  Widget build(BuildContext context) {
    final TtsService ttsService = TtsService();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          word.topic.toUpperCase(),
          style: AppConstants.subHeadingStyle.copyWith(
            fontSize: 12,
            letterSpacing: 2,
            color: isDark ? Colors.white70 : AppConstants.textSecondary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                word.word,
                style: AppConstants.headingStyle.copyWith(
                  fontSize: 40,
                  fontStyle: FontStyle.normal,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
              ),
              const SizedBox(height: 16),

              if (word.phoneticUS.isNotEmpty || word.phoneticUK.isNotEmpty)
                _IPASection(word: word, isDark: isDark),

              const SizedBox(height: 24),
              Row(
                children: [
                  Expanded(
                    child: _SpeakerButton(
                      tts: ttsService,
                      text: word.word,
                      accent: 'en-US',
                      label: 'US',
                      isDark: isDark,
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: _SpeakerButton(
                      tts: ttsService,
                      text: word.word,
                      accent: 'en-GB',
                      label: 'UK',
                      isDark: isDark,
                    ),
                  ),
                ],
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 32),
                child: Divider(color: Colors.grey.withValues(alpha: 0.2)),
              ),

              Text('word_detail.meaning'.tr(), style: AppConstants.subHeadingStyle),
              const SizedBox(height: 12),
              Text(
                word.meaning,
                style: AppConstants.bodyStyle.copyWith(
                  fontSize: 22,
                  fontWeight: FontWeight.w600,
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
              ),

              const SizedBox(height: 32),

              Text('word_detail.example'.tr(), style: AppConstants.subHeadingStyle),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: isDark
                      ? AppConstants.darkCardColor
                      : AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(
                    AppConstants.cardRadius / 1.5,
                  ),
                  border: Border.all(
                    color: isDark
                        ? Colors.transparent
                        : Colors.grey.withValues(alpha: 0.1),
                  ),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.03),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                ),
                child: Text(
                  word.example,
                  style: AppConstants.bodyStyle.copyWith(
                    fontSize: 18,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: isDark ? Colors.white70 : AppConstants.textSecondary,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _IPASection extends StatelessWidget {
  final Word word;
  final bool isDark;

  const _IPASection({required this.word, required this.isDark});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (word.phoneticUS.isNotEmpty)
          Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: RichText(
              text: TextSpan(
                children: [
                  TextSpan(
                    text: 'US ',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppConstants.textSecondary,
                    ),
                  ),
                  TextSpan(
                    text: word.phoneticUS,
                    style: TextStyle(
                      fontSize: 18,
                      fontFamily: 'sans-serif',
                      color: AppConstants.accentColor,
                    ),
                  ),
                ],
              ),
            ),
          ),
        if (word.phoneticUK.isNotEmpty)
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: 'UK ',
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.bold,
                    color: AppConstants.textSecondary,
                  ),
                ),
                TextSpan(
                  text: word.phoneticUK,
                  style: TextStyle(
                    fontSize: 18,
                    fontFamily: 'sans-serif',
                    color: AppConstants.accentColor,
                  ),
                ),
              ],
            ),
          ),
      ],
    );
  }
}

class _SpeakerButton extends StatelessWidget {
  final TtsService tts;
  final String text;
  final String accent;
  final String label;
  final bool isDark;

  const _SpeakerButton({
    required this.tts,
    required this.text,
    required this.accent,
    required this.label,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => tts.speak(text, accent: accent),
      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              CupertinoIcons.speaker_2_fill,
              size: 20,
              color: AppConstants.accentColor,
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: AppConstants.bodyStyle.copyWith(
                fontWeight: FontWeight.bold,
                fontSize: 14,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
