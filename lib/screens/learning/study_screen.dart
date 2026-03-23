import 'dart:math';

import 'package:flutter/material.dart';
import '../../models/word_model.dart';
import '../../services/word_service.dart';
import '../../services/tts_service.dart';
import '../../utils/constants.dart';

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

  @override
  void initState() {
    super.initState();
    _loadWords();
  }

  void _loadWords() {
    final allTopicWords = widget.topic == 'Review' 
        ? _wordService.getWordsToReview() 
        : _wordService.getWordsByTopic(widget.topic);
    
    final now = DateTime.now();
    
    // Lọc các từ chưa học hoặc cần ôn tập
    _words = allTopicWords.where((w) => 
      !w.isLearned || 
      (w.nextReview != null && w.nextReview!.isBefore(now)) ||
      w.wrongCount > 0
    ).toList();

    if (_words.isEmpty) {
      // Nếu đã học hết, hiển thị lại tất cả để không bị màn hình trống
      _words = List.from(allTopicWords);
    }
    _words.shuffle();
  }

  void _showNotification(String message, Color color) {
    ScaffoldMessenger.of(context).clearSnackBars();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: color,
        duration: const Duration(milliseconds: 800),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        margin: const EdgeInsets.only(bottom: 20, left: 40, right: 40),
      ),
    );
  }

  void _nextCard(bool known) {
    _showNotification(known ? 'Got it! +1' : 'Needs review!', known ? AppConstants.successColor : AppConstants.errorColor);
    
    if (_currentIndex < _words.length - 1) {
      setState(() {
        _currentIndex++;
        _isFlipped = false;
      });
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_words.isEmpty) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final currentWord = _words[_currentIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close, color: isDark ? Colors.white : Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text('${_currentIndex + 1} / ${_words.length}', 
            style: TextStyle(color: isDark ? Colors.white60 : Colors.grey, fontSize: 16)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            Expanded(
              child: GestureDetector(
                onTap: () => setState(() => _isFlipped = !_isFlipped),
                child: _buildFlipAnimation(currentWord),
              ),
            ),
            const SizedBox(height: 40),
            _buildActionButtons(currentWord),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  // Tách riêng Widget Animation để build() ngắn gọn
 Widget _buildFlipAnimation(Word currentWord) {
  return AnimatedSwitcher(
    duration: AppConstants.flipDuration,
    transitionBuilder: (Widget child, Animation<double> animation) {
      // Tween chạy từ Pi (180 độ) về 0
      final rotate = Tween(begin: pi, end: 0.0).animate(animation);
      
      return AnimatedBuilder(
        animation: rotate,
        builder: (context, child) {
          final isBack = (child!.key == const ValueKey(true));
          
          // Tính toán giá trị xoay: 
          // Nếu là mặt sau, ta giới hạn nó xoay trong khoảng phù hợp để không bị ngược chữ
          var value = isBack ? min(rotate.value, pi / 2) : rotate.value;
          
          return Transform(
            transform: Matrix4.identity()
              ..setEntry(3, 2, 0.001) // FIX: Thay (3, 0) thành (3, 2) để tạo độ sâu chuẩn
              ..rotateY(value),       // Xoay theo trục Y
            alignment: Alignment.center,
            child: child,
          );
        },
        child: child,
      );
    },
    // Chuyển đổi giữa mặt trước và mặt sau dựa trên biến _isFlipped
    child: _isFlipped ? _buildBack(currentWord) : _buildFront(currentWord),
  );
}

  // Mặt trước của thẻ
  Widget _buildFront(Word word) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey(false),
      width: double.infinity,
      decoration: _cardDecoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(word.topic.toUpperCase(), style: AppConstants.subHeadingStyle),
          const SizedBox(height: 20),
          Text(word.word, textAlign: TextAlign.center, 
              style: AppConstants.wordStyle.copyWith(
                color: theme.textTheme.displayLarge?.color // Tự động đổi màu theo theme
              )),
          const SizedBox(height: 12),
          // FIX IPA HIỂN THỊ TRÊN DARK MODE
          Text(
            word.phoneticUS.isNotEmpty ? word.phoneticUS : word.phoneticUK,
            textAlign: TextAlign.center, 
            style: TextStyle(
              fontSize: 20,
              color: theme.colorScheme.primary, // Dùng primary của theme để có độ sáng phù hợp
              fontWeight: FontWeight.w500,
              fontFamily: 'sans-serif', // Font hỗ trợ ký tự phiên âm
            ),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpeakerButton(word.word, 'en-US', 'US'),
              const SizedBox(width: 15),
              _buildSpeakerButton(word.word, 'en-GB', 'UK'),
            ],
          ),
        ],
      ),
    );
  }

  // Mặt sau của thẻ
  Widget _buildBack(Word word) {
    final theme = Theme.of(context);
    return Container(
      key: const ValueKey(true),
      width: double.infinity,
      decoration: _cardDecoration().copyWith(
        border: Border.all(color: theme.colorScheme.primary.withValues(alpha: 0.3), width: 2),
      ),
      child: Padding(
        padding: const EdgeInsets.all(30),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const Text('MEANING', style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            Text(word.meaning, textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(indent: 50, endIndent: 50),
            ),
            const Text('EXAMPLE', style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            Text(
              word.example,
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 18,
                fontStyle: FontStyle.italic,
                color: theme.textTheme.bodyMedium?.color?.withValues(alpha: 0.7),
              ),
            ),
          ],
        ),
      ),
    );
  }
  
  BoxDecoration _cardDecoration() {
  final isDark = Theme.of(context).brightness == Brightness.dark;
  return BoxDecoration(
    color: Theme.of(context).cardColor,
    borderRadius: BorderRadius.circular(32),
    boxShadow: [
      BoxShadow(
        // Dark mode dùng shadow nhẹ hơn, Light mode dùng shadow đậm hơn
        color: isDark ? Colors.black45 : Colors.black.withValues(alpha: 0.08),
        blurRadius: 20,
        offset: const Offset(0, 10),
      ),
    ],
  );
}

  // Gom cụm Action Buttons
  Widget _buildActionButtons(Word currentWord) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        _buildActionButton(
          icon: Icons.close_rounded,
          label: 'FORGOT',
          color: AppConstants.errorColor,
          onTap: () {
            currentWord.wrongCount++;
            currentWord.save();
            _nextCard(false);
          },
        ),
        _buildActionButton(
          icon: Icons.check_rounded,
          label: 'KNOW',
          color: AppConstants.successColor,
          onTap: () {
            _wordService.markAsLearned(currentWord);
            _nextCard(true);
          },
        ),
      ],
    );
  }
  Widget _buildSpeakerButton(String text, String accent, String label) {
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

  Widget _buildActionButton({required IconData icon, required String label, required Color color, required VoidCallback onTap}) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          Container(
            width: 70,
            height: 70,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(label, style: TextStyle(color: color, fontWeight: FontWeight.bold, fontSize: 12, letterSpacing: 1)),
        ],
      ),
    );
  }
}
