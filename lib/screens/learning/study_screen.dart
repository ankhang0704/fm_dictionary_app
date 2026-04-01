// file: lib/screens/learning/study_screen.dart
import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/services/ai_speech/ai_assistant/pronunciation_scorer.dart';
import 'package:fm_dictionary/services/ai_speech/ai_assistant/ai_assistant_service.dart';
import '../../models/word_model.dart';
import '../../services/database/word_service.dart';
import '../../services/ai_speech/text_to_speech/speech_service.dart';
import '../../core/constants/constants.dart';

class StudyScreen extends StatefulWidget {
  final String topic;
  const StudyScreen({super.key, required this.topic});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  final WordService _wordService = WordService();
  final TtsService _ttsService = TtsService();
  List<Word> _words = [];
  int _currentIndex = 0;
  bool _isFlipped = false;

  // Recording State
  bool _isRecording = false;
  bool _isAnalyzing = false;
  String _spokenText = "";
  double? _pronunciationScore;

  bool _isMounted = true;
  Timer? _recordingTimer;
  final int _maxRecordSeconds = 5;
  final ValueNotifier<int> _timeRemaining = ValueNotifier<int>(5);

  @override
  void initState() {
    super.initState();
    _loadWords();
    AiAssistantService.instance.initModel();
  }

  @override
  void dispose() {
    _isMounted = false;
    _recordingTimer?.cancel();
    AiAssistantService.instance.disposeSession();
    _timeRemaining.dispose();
    super.dispose();
  }

  Word get currentWord => _words[_currentIndex];

  void _startRecording() async {
    try {
      _recordingTimer?.cancel();
      _timeRemaining.value = _maxRecordSeconds;

      await AiAssistantService.instance.startRecording();
      if (_isMounted) setState(() => _isRecording = true);

      _recordingTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (!_isRecording) {
          timer.cancel();
          return;
        }
        if (_timeRemaining.value > 1) {
          _timeRemaining.value--;
        } else {
          timer.cancel();
          _stopRecording(currentWord.word);
        }
      });
    } catch (e) {
      debugPrint("Lỗi khởi động ghi âm: $e");
    }
  }

  void _stopRecording(String targetWord) async {
    _recordingTimer?.cancel();
    if (!_isRecording || _isAnalyzing) return;

    if (_isMounted) {
      setState(() {
        _isRecording = false;
        _isAnalyzing = true;
      });
    }

    try {
      final spokenText = await AiAssistantService.instance.stopAndTranscribe();
      if (spokenText != null && _isMounted) {
        final result = PronunciationScorer.evaluate(spokenText, targetWord);
        setState(() {
          _spokenText = spokenText;
          _pronunciationScore = result.score;
        });
      }
    } catch (e) {
      debugPrint("Lỗi xử lý AI: $e");
    } finally {
      if (_isMounted) setState(() => _isAnalyzing = false);
    }
  }

  void _loadWords() {
    final allTopicWords = widget.topic == 'Review'
        ? _wordService.getWordsToReview()
        : _wordService.getWordsByTopic(widget.topic);

    final nowMs = DateTime.now().millisecondsSinceEpoch;

    _words = allTopicWords.where((w) {
      final progress = _wordService.getWordProgress(w.id);
      final nextReview = progress['nr'] as int;
      final step = progress['s'] as int;
      return nextReview <= nowMs || step < 4;
    }).toList();

    if (_words.isEmpty) {
      _words = List.from(allTopicWords);
    }
    _words.shuffle();
  }

  void _showNotification(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          textAlign: TextAlign.center,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
        ),
        margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
      ),
    );
  }

  void _nextCard(bool known) {
    _showNotification(
      known ? 'study.known_btn'.tr() : 'study.unknown_btn'.tr(),
      known ? AppConstants.successColor : AppConstants.errorColor,
    );

    if (_isRecording || _isAnalyzing) {
      AiAssistantService.instance.disposeSession();
    }

    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
        _spokenText = "";
        _pronunciationScore = null;
        _isRecording = false;
        _isAnalyzing = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        body: const Center(child: CircularProgressIndicator.adaptive()),
      );
    }

    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.xmark,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          '${_currentIndex + 1} / ${_words.length}',
          style: AppConstants.bodyStyle.copyWith(
            color: AppConstants.textSecondary,
            fontSize: 14,
            fontWeight: FontWeight.bold,
          ),
        ),
        centerTitle: true,
      ),
      body: Stack(
        children: [
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              child: Column(
                children: [
                  Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _isFlipped = !_isFlipped),
                      child: _buildFlipAnimation(currentWord, isDark),
                    ),
                  ),
                  const SizedBox(height: 32),
                  _buildActionButtons(),
                  const SizedBox(height: 16),
                ],
              ),
            ),
          ),
          if (_isRecording) _buildRecordingOverlay(),
        ],
      ),
    );
  }

  Widget _buildFlipAnimation(Word currentWord, bool isDark) {
    return AnimatedSwitcher(
      duration: AppConstants.flipDuration,
      transitionBuilder: (Widget child, Animation<double> animation) {
        final rotate = Tween(begin: pi, end: 0.0).animate(animation);
        return AnimatedBuilder(
          animation: rotate,
          builder: (context, child) {
            final isBack = (child!.key == const ValueKey(true));
            var value = isBack ? min(rotate.value, pi / 2) : rotate.value;
            return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateY(value),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: child,
        );
      },
      child: _isFlipped
          ? _buildBack(currentWord, isDark)
          : _buildFront(currentWord, isDark),
    );
  }

  Widget _buildFront(Word word, bool isDark) {
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: _cardDecoration(isDark),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              word.topic.toUpperCase(),
              style: const TextStyle(
                color: AppConstants.accentColor,
                fontSize: 10,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.5,
              ),
            ),
          ),
          Expanded(
            child: Center(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      word.word,
                      textAlign: TextAlign.center,
                      style: AppConstants.headingStyle.copyWith(
                        fontSize: 32,
                        fontStyle: FontStyle.normal,
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 24),
                    _buildPronunciationRow(word, isDark),
                  ],
                ),
              ),
            ),
          ),
          _buildMicSection(isDark),
        ],
      ),
    );
  }

  Widget _buildPronunciationRow(Word word, bool isDark) {
    return Column(
      children: [
        if (word.phoneticUS.isNotEmpty)
          _PronunciationPill(
            label: 'US',
            flag: '🇺🇸',
            phonetic: word.phoneticUS,
            onTap: () => _ttsService.speak(word.word, accent: 'en-US'),
            isDark: isDark,
          ),
        const SizedBox(height: 12),
        if (word.phoneticUK.isNotEmpty)
          _PronunciationPill(
            label: 'UK',
            flag: '🇬🇧',
            phonetic: word.phoneticUK,
            onTap: () => _ttsService.speak(word.word, accent: 'en-GB'),
            isDark: isDark,
          ),
      ],
    );
  }

  Widget _buildMicSection(bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: _isAnalyzing ? null : _startRecording,
          child: AnimatedContainer(
            duration: AppConstants.defaultAnimationDuration,
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.darkBgColor
                  : AppConstants.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: _isAnalyzing ? Colors.grey : AppConstants.accentColor,
                width: 2,
              ),
              boxShadow: _isAnalyzing
                  ? []
                  : [
                      BoxShadow(
                        color: AppConstants.accentColor.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: _isAnalyzing
                ? const Padding(
                    padding: EdgeInsets.all(16),
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: AppConstants.accentColor,
                    ),
                  )
                : const Icon(
                    CupertinoIcons.mic_solid,
                    size: 28,
                    color: AppConstants.accentColor,
                  ),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          _isAnalyzing ? "study.analyzing".tr() : "study.tap_to_speak".tr(),
          style: AppConstants.bodyStyle.copyWith(
            color: AppConstants.textSecondary,
            fontSize: 12,
          ),
        ),
        if (_pronunciationScore != null) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: _pronunciationScore! > 80
                  ? AppConstants.successColor.withValues(alpha: 0.1)
                  : AppConstants.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "\"$_spokenText\"",
                  style: AppConstants.bodyStyle.copyWith(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : AppConstants.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  _pronunciationScore! > 80
                      ? "${"study.excellent".tr()} (${_pronunciationScore!.toInt()}%)"
                      : "${"study.try_again".tr()} (${_pronunciationScore!.toInt()}%)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: _pronunciationScore! > 80
                        ? AppConstants.successColor
                        : AppConstants.errorColor,
                  ),
                ),
              ],
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildBack(Word word, bool isDark) {
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      decoration: _cardDecoration(isDark).copyWith(
        border: Border.all(
          color: AppConstants.accentColor.withValues(alpha: 0.3),
          width: 2,
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Center(
          child: SingleChildScrollView(
            physics: const BouncingScrollPhysics(),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  'study.meaning'.tr(),
                  style: AppConstants.subHeadingStyle.copyWith(
                    color: AppConstants.accentColor,
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  word.meaning,
                  textAlign: TextAlign.center,
                  style: AppConstants.bodyStyle.copyWith(
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    color: isDark ? Colors.white : AppConstants.textPrimary,
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 32),
                  child: Divider(
                    color: Colors.grey.withValues(alpha: 0.2),
                    indent: 40,
                    endIndent: 40,
                  ),
                ),
                Text('study.example'.tr(), style: AppConstants.subHeadingStyle),
                const SizedBox(height: 16),
                Text(
                  word.example,
                  textAlign: TextAlign.center,
                  style: AppConstants.bodyStyle.copyWith(
                    fontSize: 16,
                    fontStyle: FontStyle.italic,
                    height: 1.5,
                    color: isDark ? Colors.white70 : AppConstants.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  BoxDecoration _cardDecoration(bool isDark) {
    return BoxDecoration(
      color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
      borderRadius: BorderRadius.circular(AppConstants.cardRadius),
      boxShadow: isDark
          ? []
          : [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.05),
                blurRadius: 20,
                offset: const Offset(0, 10),
              ),
            ],
    );
  }

  Widget _buildActionButtons() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        _ActionButton(
          icon: CupertinoIcons.xmark,
          label: 'study.again'.tr(),
          color: AppConstants.errorColor,
          onTap: () async {
            await _wordService.updateProgress(currentWord.id, false);
            if (mounted) _nextCard(false);
          },
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: CupertinoIcons.clock,
          label: 'study.good'.tr(),
          color: Colors.blue,
          onTap: () async {
            await _wordService.updateProgress(currentWord.id, true);
            if (mounted) _nextCard(true);
          },
        ),
        const SizedBox(width: 24),
        _ActionButton(
          icon: CupertinoIcons.checkmark_alt,
          label: 'study.easy'.tr(),
          color: AppConstants.successColor,
          onTap: () async {
            await _wordService.markAsLearned(currentWord.id);
            if (mounted) _nextCard(true);
          },
        ),
      ],
    );
  }

  Widget _buildRecordingOverlay() {
    return Positioned.fill(
      child: GestureDetector(
        onTap: () => _stopRecording(currentWord.word),
        child: Container(
          color: Colors.black.withValues(alpha: 0.85),
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 140,
                      height: 140,
                      child: ValueListenableBuilder<int>(
                        valueListenable: _timeRemaining,
                        builder: (context, time, _) {
                          return TweenAnimationBuilder<double>(
                            duration: const Duration(seconds: 1),
                            tween: Tween(
                              begin: time / _maxRecordSeconds,
                              end: (time - 1) / _maxRecordSeconds,
                            ),
                            builder: (context, value, _) {
                              return CircularProgressIndicator(
                                value: value,
                                strokeWidth: 4,
                                color: AppConstants.accentColor,
                                backgroundColor: Colors.white24,
                              );
                            },
                          );
                        },
                      ),
                    ),
                    Container(
                      width: 100,
                      height: 100,
                      decoration: BoxDecoration(
                        color: AppConstants.accentColor,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: AppConstants.accentColor.withValues(
                              alpha: 0.5,
                            ),
                            blurRadius: 30,
                            spreadRadius: 10,
                          ),
                        ],
                      ),
                      child: const Icon(
                        CupertinoIcons.mic_solid,
                        size: 48,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                ValueListenableBuilder<int>(
                  valueListenable: _timeRemaining,
                  builder: (context, time, _) => Text(
                    "00:0$time",
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 2,
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  "study.listening".tr(),
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70, fontSize: 16),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PronunciationPill extends StatelessWidget {
  final String label;
  final String flag;
  final String phonetic;
  final VoidCallback onTap;
  final bool isDark;

  const _PronunciationPill({
    required this.label,
    required this.flag,
    required this.phonetic,
    required this.onTap,
    required this.isDark,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 300),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(color: Colors.grey.withValues(alpha: 0.2)),
          borderRadius: BorderRadius.circular(AppConstants.buttonRadius),
          color: isDark
              ? AppConstants.darkBgColor
              : AppConstants.backgroundColor,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(flag, style: const TextStyle(fontSize: 16)),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.bold,
                color: AppConstants.textSecondary,
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                phonetic,
                style: TextStyle(
                  fontSize: 14,
                  fontFamily: 'sans-serif',
                  color: isDark ? Colors.white : AppConstants.textPrimary,
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
              ),
            ),
            const SizedBox(width: 12),
            const Icon(
              CupertinoIcons.speaker_2_fill,
              size: 16,
              color: AppConstants.accentColor,
            ),
          ],
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback onTap;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 28),
          ),
          const SizedBox(height: 8),
          Text(
            label,
            style: TextStyle(
              color: color,
              fontWeight: FontWeight.bold,
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
