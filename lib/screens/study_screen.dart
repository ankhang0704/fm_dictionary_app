import 'package:flutter/material.dart';
import 'package:fm_dictionary/services/database_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import 'package:flutter_tts/flutter_tts.dart';

class StudyScreen extends StatefulWidget {
  final String topic;
  const StudyScreen({super.key, required this.topic});

  @override
  State<StudyScreen> createState() => _StudyScreenState();
}

class _StudyScreenState extends State<StudyScreen>
    with SingleTickerProviderStateMixin {
  List<Word> words = [];
  int currentIndex = 0;
  final FlutterTts _flutterTts = FlutterTts();
  late AnimationController _controller;
  late Animation<double> _animation;
  bool isFlipped = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 500),
      vsync: this,
    );
    _animation = Tween<double>(begin: 0, end: 1).animate(_controller);

    _loadWordsFromHive(); // SỬA TẠI ĐÂY: Load từ Hive
    _initTts();
  }

  void _initTts() async {
    final settings = DatabaseService.getSettings();
    await _flutterTts.setLanguage("en-US");
    await _flutterTts.setSpeechRate(settings.ttsSpeed);
  }

  @override
  void dispose() {
    _flutterTts.stop();
    _controller.dispose();
    super.dispose();
  }

  // FIX LỖI: Load dữ liệu từ Hive Box để có thể dùng lệnh .save()
  void _loadWordsFromHive() {
    final box = Hive.box<Word>(DatabaseService.wordBoxName);
    setState(() {
      // Lấy toàn bộ từ trong Hive và lọc theo Topic
      words = box.values.where((w) => w.topic == widget.topic).toList();
    });
  }

  void _playAudio(String text, String locale) async {
    final settings = DatabaseService.getSettings();
    await _flutterTts.setLanguage(locale);
    await _flutterTts.setSpeechRate(settings.ttsSpeed);
    await _flutterTts.speak(text);
  }

  void _handleNext(bool learned) async {
    if (words.isEmpty) return;

    final currentWord = words[currentIndex];

    if (learned) {
      currentWord.isLearned = true;
      _updateAnkiLogic(currentWord, quality: 5);
    } else {
      currentWord.wrongCount++;
      _updateAnkiLogic(currentWord, quality: 0);
    }

    // Lưu vào Hive (Bây giờ sẽ không còn lỗi vì word được lấy từ Box)
    await currentWord.save();

    if (!mounted) return;

    if (currentIndex < words.length - 1) {
      setState(() {
        currentIndex++;
        isFlipped = false;
        _controller.reset();
      });
    } else {
      _showCompletionDialog();
    }
  }

  void _updateAnkiLogic(Word word, {required int quality}) {
    if (quality >= 3) {
      if (word.repetitions == 0) {
        word.interval = 1;
      } else if (word.repetitions == 1) {
        word.interval = 6;
      } else {
        word.interval = (word.interval * word.easeFactor).round();
      }
      word.repetitions++;
    } else {
      word.repetitions = 0;
      word.interval = 1;
    }
    word.easeFactor =
        word.easeFactor + (0.1 - (5 - quality) * (0.08 + (5 - quality) * 0.02));
    if (word.easeFactor < 1.3) word.easeFactor = 1.3;
    word.lastReview = DateTime.now();
    word.nextReview = DateTime.now().add(Duration(days: word.interval));
  }

  void _showCompletionDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(32)),
        title: const Text('🎉 Hoàn thành!', textAlign: TextAlign.center),
        content: const Text('Bạn đã học hết các từ trong chủ đề này.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text(
              'XÁC NHẬN',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (words.isEmpty) {
      return const Scaffold(
        body: Center(child: Text("Không có dữ liệu cho chủ đề này")),
      );
    }

    final currentWord = words[currentIndex];

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.chevron_left, color: Colors.black, size: 32),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          widget.topic.toUpperCase(),
          style: const TextStyle(
            color: Colors.black,
            fontSize: 14,
            letterSpacing: 2,
          ),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              Text(
                '${currentIndex + 1} / ${words.length}',
                style: const TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () {
                  if (_controller.isCompleted) {
                    _controller.reverse();
                    setState(() => isFlipped = false);
                  } else {
                    _controller.forward();
                    setState(() => isFlipped = true);
                  }
                },
                child: AnimatedBuilder(
                  animation: _animation,
                  builder: (context, child) {
                    return Transform(
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(_animation.value * 3.14159),
                      alignment: Alignment.center,
                      child: _animation.value <= 0.5
                          ? _buildFront(currentWord)
                          : _buildBack(currentWord),
                    );
                  },
                ),
              ),
              const SizedBox(height: 40),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildActionButton(
                    Icons.close,
                    "Don't Know",
                    Colors.red,
                    () => _handleNext(false),
                  ),
                  _buildActionButton(
                    Icons.check,
                    "I Know",
                    Colors.green,
                    () => _handleNext(true),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFront(Word word) {
    return Container(
      height: 400,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(40),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
        border: Border.all(color: Colors.grey.shade100, width: 2),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Text(
            'ENGLISH',
            style: TextStyle(
              color: Colors.grey,
              letterSpacing: 2,
              fontSize: 12,
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              word.word,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
            ),
          ),
          Text(
            word.phonetic,
            style: const TextStyle(color: Colors.grey, fontSize: 18),
          ),
          const SizedBox(height: 40),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildSpeakerButton(word.word, "en-US", "US"),
              const SizedBox(width: 32),
              _buildSpeakerButton(word.word, "en-GB", "UK"),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSpeakerButton(String text, String locale, String label) {
    return Column(
      children: [
        IconButton(
          icon: const Icon(
            Icons.volume_up_rounded,
            size: 40,
            color: Color(0xFF1A1A1A),
          ),
          onPressed: () => _playAudio(text, locale),
        ),
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
      ],
    );
  }

  Widget _buildBack(Word word) {
    return Transform(
      transform: Matrix4.identity()..rotateY(3.14159),
      alignment: Alignment.center,
      child: Container(
        height: 400,
        width: double.infinity,
        decoration: BoxDecoration(
          color: const Color(0xFF1A1A1A),
          borderRadius: BorderRadius.circular(40),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              'VIETNAMESE',
              style: TextStyle(color: Colors.grey, fontSize: 12),
            ),
            const SizedBox(height: 20),
            Text(
              word.meaning,
              style: const TextStyle(color: Colors.white, fontSize: 32),
            ),
            const Divider(color: Colors.white24, indent: 40, endIndent: 40),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                word.example,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white70,
                  fontSize: 16,
                  fontStyle: FontStyle.italic,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButton(
    IconData icon,
    String label,
    Color color,
    VoidCallback onTap,
  ) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(24),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade200),
              borderRadius: BorderRadius.circular(24),
            ),
            child: Icon(icon, color: color, size: 32),
          ),
          const SizedBox(height: 8),
          Text(
            label.toUpperCase(),
            style: const TextStyle(fontSize: 10, color: Colors.grey),
          ),
        ],
      ),
    );
  }
}
