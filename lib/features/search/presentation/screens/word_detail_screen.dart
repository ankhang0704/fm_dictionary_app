import 'dart:ui';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/glass_bento_card.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';

// --- CORE / THEMES ---
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_typography.dart';
import '../../../../core/theme/app_layout.dart';

// --- MODELS / SERVICES ---
import '../../../../data/models/word_model.dart';
import '../../../../data/services/ai_speech/text_to_speech/speech_service.dart';

class WordDetailScreen extends StatefulWidget {
  final Word word;
  const WordDetailScreen({super.key, required this.word});

  @override
  State<WordDetailScreen> createState() => _WordDetailScreenState();
}

class _WordDetailScreenState extends State<WordDetailScreen> {
  // Legacy TTS Service
  final TtsService _ttsService = TtsService();
  final WordService _wordService = WordService();
  bool _isSaved = false;

  @override
  void initState() {
    super.initState();
    _isSaved = _wordService.isWordSaved(widget.word.id);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      // GLOBAL DESIGN SYSTEM: Mesh Gradient Background
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [
            AppColors.meshBlue,
            AppColors.meshPurple,
            AppColors.meshMint,
          ],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Scaffold(
        backgroundColor: Colors.transparent,
        appBar: _buildGlassHeader(context),
        body: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: EdgeInsets.all(AppLayout.defaultPadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // BENTO 1: HERO CARD (Word & Meaning)
              _buildHeroCard(),
              const SizedBox(height: 16),

              // BENTO 2: PRONUNCIATION ROW (US & UK)
              _buildPronunciationRow(),
              const SizedBox(height: 16),

              // BENTO 3: EXPLANATION / CONTEXT
              if (widget.word.example.isNotEmpty) ...[
                _buildContextCard(),
                const SizedBox(height: 32),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ===========================================================================
  // WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildGlassHeader(BuildContext context) {
    return PreferredSize(
      preferredSize: const Size.fromHeight(kToolbarHeight),
      child: ClipRRect(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: AppBar(
            backgroundColor: Colors.white.withValues(alpha:0.1),
            elevation: 0,
            centerTitle: true,
            leading: IconButton(
              icon: const Icon(
                CupertinoIcons.back,
                color: AppColors.textPrimary,
              ),
              onPressed: () => Navigator.pop(context),
            ),
            title: Text(
              "Chi tiết từ",
              style: AppTypography.heading2.copyWith(
                color: AppColors.textPrimary,
              ),
            ),
            actions: [
              // Saved Word (Bookmark) Toggle
              IconButton(
                icon: Icon(
                  _isSaved
                      ? CupertinoIcons.bookmark_solid
                      : CupertinoIcons.bookmark,
                  color: _isSaved ? AppColors.meshMint : AppColors.textPrimary,
                ),
                onPressed: () async {
                  await _wordService.toggleSaveWord(widget.word.id);
                  setState(() => _isSaved = !_isSaved);
                },
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(1),
              child: Container(color: Colors.white.withValues(alpha:0.2), height: 1),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return GlassBentoCard(
      onTap: null,
      child: Stack(
        alignment: Alignment.topCenter,
        children: [
          // TOP RIGHT: Topic Badge
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha:0.15),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.white.withValues(alpha:0.2)),
              ),
              child: Text(
                widget.word.topic.toUpperCase(),
                style: AppTypography.bodyMedium.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 11,
                ),
              ),
            ),
          ),

          // CENTER CONTENT: Word & Meaning
          Padding(
            padding: const EdgeInsets.only(
              top: 28.0,
              bottom: 8.0,
              left: 8.0,
              right: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ZERO OVERFLOW: Dynamically scale down extremely long words
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.word.word,
                    style: AppTypography.heading1.copyWith(
                      fontSize: 42,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.word.meaning,
                  style: AppTypography.heading3.copyWith(
                    color: AppColors.success,
                    fontSize: 22,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 3,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPronunciationRow() {
    final hasUS = widget.word.phoneticUS.isNotEmpty;
    final hasUK = widget.word.phoneticUK.isNotEmpty;

    if (!hasUS && !hasUK) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasUS)
          Expanded(
            child: _buildPronunciationCard(
              title: "🇺🇸 US",
              ipa: widget.word.phoneticUS,
              onSpeak: () =>
                  _ttsService.speak(widget.word.word, accent: 'en-US'),
            ),
          ),

        if (hasUS && hasUK) const SizedBox(width: 16),

        if (hasUK)
          Expanded(
            child: _buildPronunciationCard(
              title: "🇬🇧 UK",
              ipa: widget.word.phoneticUK,
              onSpeak: () =>
                  _ttsService.speak(widget.word.word, accent: 'en-GB'),
            ),
          ),
      ],
    );
  }

  Widget _buildPronunciationCard({
    required String title,
    required String ipa,
    required VoidCallback onSpeak,
  }) {
    return GlassBentoCard(
      onTap: onSpeak, // Entire card is tappable for quick access
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: AppTypography.bodyMedium.copyWith(
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),

          // ZERO OVERFLOW: IPA Transcriptions can sometimes be long
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ipa,
              style: AppTypography.ipaText.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
          ),
          const SizedBox(height: 16),

          // Prominent Glass Speaker Button
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.meshBlue.withValues(alpha:0.2),
              shape: BoxShape.circle,
              border: Border.all(color: AppColors.meshBlue.withValues(alpha:0.4)),
            ),
            child: const Icon(
              CupertinoIcons.speaker_2_fill,
              color: AppColors.textPrimary,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard() {
    return GlassBentoCard(
      onTap: null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Icon(
                CupertinoIcons.lightbulb_fill,
                color: AppColors.warning,
                size: 20,
              ),
              const SizedBox(width: 8),
              Text(
                "Giải thích & Ngữ cảnh",
                style: AppTypography.heading3.copyWith(
                  color: AppColors.textPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),

          // Example Text block
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:0.1),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.white.withValues(alpha:0.2)),
            ),
            child: Text(
              "\"${widget.word.example}\"",
              style: AppTypography.bodyLarge.copyWith(
                fontStyle: FontStyle.italic,
                height: 1.5,
              ),
              softWrap: true,
            ),
          ),
        ],
      ),
    );
  }
}
