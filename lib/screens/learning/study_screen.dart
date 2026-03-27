import 'dart:async';
import 'dart:math';

import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/services/voice_service.dart';
import '../../models/word_model.dart';
import '../../services/word_service.dart';
import '../../services/tts_service.dart';
import '../../core/utils/constants.dart';
import 'widgets/speaker_button.dart';

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
  bool _isRecording = false;
  String _spokenText = "";
  double? _pronunciationScore;
  bool _isAnalyzing = false;
  final VoiceService _whisperService = VoiceService();
  // final NativeVoiceService _nativeService = NativeVoiceService();

  Timer? _recordingTimer;
  final bool _useNativeEngine = true;
  
  @override
  void initState() {
    super.initState();
    _loadWords();
    // Nạp model AI ngay khi vào màn hình
    if (_useNativeEngine) {
      // _nativeService.init();
    } else {
      _whisperService.initModel();
    }
  }

  // Xử lý khi nhấn giữ nút Micro
  void _onRecordStart() async {
    try {
      setState(() {
        _isRecording = true;
        _spokenText = "";
        _pronunciationScore = null;
      });

      if (_useNativeEngine) {
        // LUỒNG NATIVE (Google/Siri)
        // await _nativeService.startListening((text) {
        //   _spokenText = text; // Cập nhật text liên tục
        // });
      } else {
        // LUỒNG WHISPER AI
        await _whisperService.startRecording();
      }

      // Giới hạn 5s ghi âm để tránh file quá lớn làm đơ máy
      _recordingTimer = Timer(const Duration(seconds: 5), () {
        if (_isRecording) {
           _showNotification("Hết 5s ghi âm!", Colors.orange);
          _onRecordStop(_words[_currentIndex].word);
        }
      });

    } catch (e) {
      _showNotification("Lỗi Micro: $e", Colors.red);
      setState(() => _isRecording = false);
    }
  }

  // Thả tay Micro
  void _onRecordStop(String targetWord) async {
    if (!_isRecording) return;
    _recordingTimer?.cancel(); // Hủy timer nếu thả tay sớm

    setState(() {
      _isRecording = false;
      _isAnalyzing = true;
    });

    String? finalSpokenText;

    if (_useNativeEngine) {
      // await _nativeService.stopListening();
      finalSpokenText = _spokenText; 
      // Chờ Native ngắt hẳn 1 nhịp (Fix lỗi UI)
      await Future.delayed(const Duration(milliseconds: 500)); 
    } else {
      finalSpokenText = await _whisperService.stopAndTranscribe();
    }

    if (finalSpokenText != null && finalSpokenText.isNotEmpty) {
      // Tái sử dụng hàm chấm điểm của VoiceService
      final score = _whisperService.calculateScore(finalSpokenText, targetWord);
      setState(() {
        _spokenText = finalSpokenText!;
        _pronunciationScore = score;
      });
    } else {
      setState(() {
        _spokenText = "Không nghe rõ. Thử lại nhé!";
      });
    }

    setState(() {
      _isAnalyzing = false;
    });
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
    _showNotification(known ? 'study.known_btn'.tr() : 'study.unknown_btn'.tr(), known ? AppConstants.successColor : AppConstants.errorColor);
    
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
          Text(
            word.word,
            textAlign: TextAlign.center,
            style: AppConstants.wordStyle.copyWith(
              color: theme.textTheme.displayLarge?.color,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            word.phoneticUS.isNotEmpty ? word.phoneticUS : word.phoneticUK,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 20,
              color: theme.colorScheme.primary,
              fontWeight: FontWeight.w500,
              fontFamily: 'sans-serif',
            ),
          ),
          const SizedBox(height: 20),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SpeakerButton(
                ttsService: _ttsService,
                context: context,
                text: word.word,
                accent: 'en-US',
                label: 'US',
              ),
              const SizedBox(width: 15),
              SpeakerButton(
                ttsService: _ttsService,
                context: context,
                text: word.word,
                accent: 'en-GB',
                label: 'UK',
              ),
            ],
          ),

          const SizedBox(height: 40),

          // ================= THÊM PHẦN GHI ÂM Ở ĐÂY =================

          // Nút Micro (Nhấn giữ để nói)
          GestureDetector(
            onLongPressStart: (_) => _onRecordStart(),
            onLongPressEnd: (_) => _onRecordStop(word.word),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _isRecording ? 80 : 65, // Nút to ra khi đang bấm
              height: _isRecording ? 80 : 65,
              decoration: BoxDecoration(
                color: _isRecording
                    ? Colors.red
                    : theme.colorScheme.primary.withValues(alpha: 0.1),
                shape: BoxShape.circle,
                border: Border.all(
                  color: _isRecording ? Colors.red : theme.colorScheme.primary,
                  width: 2,
                ),
                boxShadow: _isRecording
                    ? [
                        BoxShadow(
                          color: Colors.red.withValues(alpha: 0.5),
                          blurRadius: 15,
                        ),
                      ]
                    : [],
              ),
              child: _isAnalyzing
                  ? const Padding(
                      padding: EdgeInsets.all(16.0),
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : Icon(
                      Icons.mic_rounded,
                      size: 32,
                      color: _isRecording
                          ? Colors.white
                          : theme.colorScheme.primary,
                    ),
            ),
          ),

          const SizedBox(height: 12),
          Text(
            _isRecording ? "Đang nghe... (Thả ra để chấm)" : "Nhấn giữ để đọc",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 12),
          ),

          // Hiển thị kết quả sau khi phân tích
          if (_pronunciationScore != null) ...[
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: _pronunciationScore! > 80
                    ? Colors.green.withValues(alpha: 0.1)
                    : Colors.orange.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Text(
                    "Bạn đọc: \"$_spokenText\"",
                    style: const TextStyle(fontStyle: FontStyle.italic),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    _pronunciationScore! > 80
                        ? "Tuyệt vời! (${_pronunciationScore!.toInt()}%)"
                        : "Cố lên nhé! (${_pronunciationScore!.toInt()}%)",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: _pronunciationScore! > 80
                          ? Colors.green
                          : Colors.orange,
                    ),
                  ),
                ],
              ),
            ),
          ],
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
             Text('study.meaning'.tr(), style: AppConstants.subHeadingStyle),
            const SizedBox(height: 12),
            Text(word.meaning, textAlign: TextAlign.center, 
                style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
            const Padding(
              padding: EdgeInsets.symmetric(vertical: 20),
              child: Divider(indent: 50, endIndent: 50),
            ),
             Text('study.example'.tr(), style: AppConstants.subHeadingStyle),
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
          label: 'study.unknown_btn'.tr(),
          color: AppConstants.errorColor,
          onTap: () {
            currentWord.wrongCount++;
            currentWord.save();
            _nextCard(false);
          },
        ),
        _buildActionButton(
          icon: Icons.check_rounded,
          label: 'study.known_btn'.tr(),
          color: AppConstants.successColor,
          onTap: () {
            _wordService.markAsLearned(currentWord);
            _nextCard(true);
          },
        ),
      ],
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

