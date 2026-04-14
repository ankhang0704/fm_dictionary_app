import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/common/steak_celebration.dart';

class StudyScreen extends StatefulWidget {
  final String topic;
  const StudyScreen({super.key, required this.topic});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<LearningProvider>().loadWords(widget.topic);
    });
  }

  void _handleAnkiAction(bool isCorrect, bool isEasy) async {
    final provider = context.read<LearningProvider>();
    final isDone = provider.currentIndex == provider.words.length - 1;
    
    bool showCelebration = await provider.processAnswer(isCorrect, isEasy);

    if (showCelebration && mounted) {
      await Navigator.push(
        context,
        MaterialPageRoute(
          fullscreenDialog: true,
          builder: (context) => StreakCelebrationScreen(
            streakCount: provider.currentStreak, 
          ),
        ),
      );
    }

    if (isDone && mounted) {
      Navigator.pop(context); // Học xong thì thoát
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    
    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      body: Consumer<LearningProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.words.isEmpty) {
            return _buildEmptyState(context);
          }

          return Stack(
            children: [
              SafeArea(
                child: Column(
                  children: [
                    _buildHeader(provider, isDark),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                        child: GestureDetector(
                          onTap: provider.toggleFlip,
                          child: _buildFlipAnimation(provider, isDark),
                        ),
                      ),
                    ),
                    _buildBottomControls(provider, isDark),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
              if (provider.isRecording) _buildRecordingOverlay(provider),
            ],
          );
        },
      ),
    );
  }

  Widget _buildHeader(LearningProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
            icon: Icon(CupertinoIcons.xmark, color: isDark ? Colors.white : AppConstants.textPrimary),
            onPressed: () => Navigator.pop(context),
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: AppConstants.accentColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(20),
            ),
            child: Text(
              '${provider.currentIndex + 1} / ${provider.words.length}',
              style: const TextStyle(color: AppConstants.accentColor, fontWeight: FontWeight.bold),
            ),
          ),
          IconButton(
            icon: Icon(
              provider.isCurrentWordSaved ? CupertinoIcons.bookmark_solid : CupertinoIcons.bookmark,
              color: provider.isCurrentWordSaved ? AppConstants.errorColor : (isDark ? Colors.white : AppConstants.textPrimary),
            ),
            onPressed: provider.toggleSave,
          ),
        ],
      ),
    );
  }

  Widget _buildFlipAnimation(LearningProvider provider, bool isDark) {
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
              transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(value),
              alignment: Alignment.center,
              child: child,
            );
          },
          child: child,
        );
      },
      child: provider.isFlipped 
          ? _buildBackCard(provider, isDark) 
          : _buildFrontCard(provider, isDark),
    );
  }

  // --- BENTO FRONT CARD ---
  Widget _buildFrontCard(LearningProvider provider, bool isDark) {
    final word = provider.currentWord!;
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
        boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.05), blurRadius: 20, offset: const Offset(0, 10))],
      ),
      
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
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    word.word,
                    style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppConstants.textPrimary),
                  ),
                  const SizedBox(height: 24),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (word.phoneticUS.isNotEmpty) _buildPhoneticPill('US', word.phoneticUS, () => provider.playAudio('en-US'), isDark),
                      const SizedBox(width: 12),
                      if (word.phoneticUK.isNotEmpty) _buildPhoneticPill('UK', word.phoneticUK, () => provider.playAudio('en-GB'), isDark),
                    ],
                  )
                ],
              ),
            ),
          ),
          _buildMicSection(provider, isDark),
        ],
      ),
    );
  }

  // --- BENTO BACK CARD ---
  Widget _buildBackCard(LearningProvider provider, bool isDark) {
    final word = provider.currentWord!;
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: AppConstants.accentColor.withValues(alpha: 0.3), width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text('study.meaning'.tr(), style: const TextStyle(color: AppConstants.accentColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(word.meaning, textAlign: TextAlign.center, style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppConstants.textPrimary)),
          const Padding(padding: EdgeInsets.symmetric(vertical: 24), child: Divider()),
          Text('study.example'.tr(), style: const TextStyle(color: AppConstants.accentColor, fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          Text(word.example, textAlign: TextAlign.center, style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic, color: isDark ? Colors.white70 : AppConstants.textSecondary)),
        ],
      ),
    );
  }

  // --- BOTTOM CONTROLS (Next, Back, Anki) ---
  Widget _buildBottomControls(LearningProvider provider, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        children: [
          // Nút Lùi / Tới
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: provider.currentIndex > 0 ? provider.previousCard : null,
                icon: Icon(CupertinoIcons.arrow_left_circle_fill, size: 40, color: provider.currentIndex > 0 ? AppConstants.textSecondary : Colors.grey.withValues(alpha: 0.2)),
              ),
              Text('Chạm vào thẻ để lật', style: TextStyle(color: AppConstants.textSecondary, fontSize: 13)),
              IconButton(
                onPressed: provider.currentIndex < provider.words.length - 1 ? provider.nextCard : null,
                icon: Icon(CupertinoIcons.arrow_right_circle_fill, size: 40, color: provider.currentIndex < provider.words.length - 1 ? AppConstants.textSecondary : Colors.grey.withValues(alpha: 0.2)),
              ),
            ],
          ),
          
          // Chỉ hiện 3 nút Anki nếu thẻ ĐÃ LẬT (bắt buộc xem đáp án mới đc đánh giá)
          if (provider.isFlipped) ...[
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: _buildAnkiBtn("Quên", AppConstants.errorColor, () => _handleAnkiAction(false, false))),
                const SizedBox(width: 12),
                Expanded(child: _buildAnkiBtn("Nhớ", Colors.blue, () => _handleAnkiAction(true, false))),
                const SizedBox(width: 12),
                Expanded(child: _buildAnkiBtn("Dễ", AppConstants.successColor, () => _handleAnkiAction(true, true))),
              ],
            )
          ]
        ],
      ),
    );
  }

  Widget _buildAnkiBtn(String label, Color color, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color.withValues(alpha: 0.1),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: color.withValues(alpha: 0.3)),
        ),
        alignment: Alignment.center,
        child: Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 16)),
      ),
    );
  }

  // --- Các widget phụ trợ ---
  Widget _buildMicSection(LearningProvider provider, bool isDark) {
    return Column(
      children: [
        GestureDetector(
          onTap: provider.isAnalyzing ? null : provider.startRecording,
          child: Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.darkBgColor
                  : AppConstants.backgroundColor,
              shape: BoxShape.circle,
              border: Border.all(
                color: provider.isAnalyzing
                    ? Colors.grey
                    : AppConstants.accentColor,
                width: 2,
              ),
              boxShadow: provider.isAnalyzing
                  ? []
                  : [
                      BoxShadow(
                        color: AppConstants.accentColor.withValues(alpha: 0.2),
                        blurRadius: 15,
                        spreadRadius: 2,
                      ),
                    ],
            ),
            child: provider.isAnalyzing
                ? const SizedBox(
                    width: 28,
                    height: 28,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(
                    CupertinoIcons.mic_solid,
                    size: 28,
                    color: AppConstants.accentColor,
                  ),
          ),
        ),

        // --- PHẦN UI BỊ THIẾU: HIỂN THỊ KẾT QUẢ ĐIỂM ---
        if (provider.pronunciationScore != null && !provider.isAnalyzing) ...[
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: provider.pronunciationScore! > 80
                  ? AppConstants.successColor.withValues(alpha: 0.1)
                  : AppConstants.errorColor.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Text(
                  "\"${provider.spokenText}\"",
                  style: TextStyle(
                    fontStyle: FontStyle.italic,
                    color: isDark ? Colors.white70 : AppConstants.textPrimary,
                  ),
                  textAlign: TextAlign.center,
                  maxLines: 2,
                ),
                const SizedBox(height: 4),
                Text(
                  provider.pronunciationScore! > 80
                      ? "Xuất sắc (${provider.pronunciationScore!.toInt()}%)"
                      : "Thử lại nhé (${provider.pronunciationScore!.toInt()}%)",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 14,
                    color: provider.pronunciationScore! > 80
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

  Widget _buildPhoneticPill(String flag, String text, VoidCallback onTap, bool isDark) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: isDark ? Colors.white10 : Colors.black.withValues(alpha: 0.05),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Text(flag, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: Colors.grey)),
            const SizedBox(width: 8),
            Text(text, style: TextStyle(color: isDark ? Colors.white : Colors.black, fontWeight: FontWeight.w500)),
            const SizedBox(width: 6),
            const Icon(CupertinoIcons.speaker_2_fill, size: 14, color: AppConstants.accentColor),
          ],
        ),
      ),
    );
  }

  Widget _buildRecordingOverlay(LearningProvider provider) {
    return Positioned.fill(
      child: Container(
        color: Colors.black.withValues(alpha: 0.9),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(CupertinoIcons.mic_fill, size: 80, color: AppConstants.accentColor),
              const SizedBox(height: 20),
              Text("00:0${provider.timeRemaining}", style: const TextStyle(color: Colors.white, fontSize: 40, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextButton(
                onPressed: provider.stopRecording,
                child: const Text("Dừng ghi âm", style: TextStyle(color: Colors.redAccent, fontSize: 18)),
              )
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState(BuildContext context) {
    return const Center(child: Text("Tuyệt vời! Bạn đã hoàn thành bài học hôm nay."));
  }
}