import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/widgets/bento_grid/bento_card.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';
import 'package:easy_localization/easy_localization.dart'; // IMPORTED

// --- CORE / THEMES ---
import '../../../../core/theme/app_colors.dart';
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
  // --- STRICTLY PRESERVED BUSINESS LOGIC ---
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
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: _buildBentoHeader(context),
      body: SingleChildScrollView(
        physics: const BouncingScrollPhysics(),
        padding: const EdgeInsets.all(AppLayout.defaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // BENTO 1: HERO CARD (Word & Meaning)
            _buildHeroCard(context),
            const SizedBox(height: 16),

            // BENTO 2: PRONUNCIATION ROW (US & UK)
            _buildPronunciationRow(context),
            const SizedBox(height: 16),

            // BENTO 3: EXPLANATION / CONTEXT
            if (widget.word.example.isNotEmpty) ...[
              _buildContextCard(context),
              const SizedBox(height: 32),
            ],
          ],
        ),
      ),
    );
  }

  // ===========================================================================
  // VIBRANT BENTO WIDGET BUILDERS
  // ===========================================================================

  PreferredSizeWidget _buildBentoHeader(BuildContext context) {
    return AppBar(
      backgroundColor: Colors.transparent,
      elevation: 0,
      centerTitle: true,
      leading: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Container(
          decoration: BoxDecoration(
            color: Theme.of(context).colorScheme.surface,
            shape: BoxShape.circle,
          ),
          child: IconButton(
            icon: Icon(
              CupertinoIcons.back,
              color: Theme.of(context).textTheme.displayLarge?.color,
              size: 20,
            ),
            onPressed: () => Navigator.pop(context),
          ),
        ),
      ),
      title: Text(
        "word_detail.title".tr(), // INJECTED
        style: Theme.of(context).textTheme.displaySmall,
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.all(8.0),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surface,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: Icon(
                _isSaved
                    ? CupertinoIcons.bookmark_solid
                    : CupertinoIcons.bookmark,
                color: _isSaved
                    ? AppColors.bentoPink
                    : Theme.of(context).textTheme.displayLarge?.color,
                size: 20,
              ),
              onPressed: () async {
                // LOGIC PRESERVED
                await _wordService.toggleSaveWord(widget.word.id);
                setState(() => _isSaved = !_isSaved);
              },
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildHeroCard(BuildContext context) {
    return BentoCard(
      child: Stack(
        children: [
          // TOP RIGHT: Topic Badge (Vibrant Design)
          Align(
            alignment: Alignment.topRight,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: AppColors.bentoBlue.withValues(alpha: 0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                widget.word.topic.toUpperCase(),
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                  fontWeight: FontWeight.bold,
                  letterSpacing: 1.2,
                  fontSize: 11,
                  color: AppColors.bentoBlue,
                ),
              ),
            ),
          ),

          // CENTER CONTENT: Word & Meaning
          Padding(
            padding: const EdgeInsets.only(
              top: 40.0,
              bottom: 8.0,
              left: 8.0,
              right: 8.0,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                FittedBox(
                  fit: BoxFit.scaleDown,
                  child: Text(
                    widget.word.word,
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                      fontSize: 48,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  widget.word.meaning,
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                    color: AppColors.success,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
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

  Widget _buildPronunciationRow(BuildContext context) {
    final hasUS = widget.word.phoneticUS.isNotEmpty;
    final hasUK = widget.word.phoneticUK.isNotEmpty;

    if (!hasUS && !hasUK) return const SizedBox.shrink();

    return Row(
      children: [
        if (hasUS)
          Expanded(
            child: _buildPronunciationCard(
              context,
              title: "word_detail.us_accent".tr(), // INJECTED
              ipa: widget.word.phoneticUS,
              accentColor: AppColors.bentoBlue,
              onSpeak: () =>
                  _ttsService.speak(widget.word.word, accent: 'en-US'),
            ),
          ),
        if (hasUS && hasUK) const SizedBox(width: 16),
        if (hasUK)
          Expanded(
            child: _buildPronunciationCard(
              context,
              title: "word_detail.uk_accent".tr(), // INJECTED
              ipa: widget.word.phoneticUK,
              accentColor: AppColors.bentoPurple,
              onSpeak: () =>
                  _ttsService.speak(widget.word.word, accent: 'en-GB'),
            ),
          ),
      ],
    );
  }

  Widget _buildPronunciationCard(
    BuildContext context, {
    required String title,
    required String ipa,
    required Color accentColor,
    required VoidCallback onSpeak,
  }) {
    return BentoCard(
      onTap: onSpeak,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
              fontWeight: FontWeight.bold,
              color: accentColor,
            ),
          ),
          const SizedBox(height: 8),
          FittedBox(
            fit: BoxFit.scaleDown,
            child: Text(
              ipa,
              style: Theme.of(
                context,
              ).textTheme.bodyMedium?.copyWith(fontStyle: FontStyle.italic),
            ),
          ),
          const SizedBox(height: 20),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: accentColor.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: Icon(
              CupertinoIcons.speaker_2_fill,
              color: accentColor,
              size: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildContextCard(BuildContext context) {
    return BentoCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.bentoYellow.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  CupertinoIcons.lightbulb_fill,
                  color: AppColors.bentoYellow,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                "word_detail.context_title".tr(), // INJECTED
                style: Theme.of(
                  context,
                ).textTheme.displaySmall?.copyWith(fontSize: 18),
              ),
            ],
          ),
          const SizedBox(height: 20),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.05),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Text(
              "\"${widget.word.example}\"",
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
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
