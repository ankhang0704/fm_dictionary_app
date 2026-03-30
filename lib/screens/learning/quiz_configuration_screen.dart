import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../models/word_model.dart';
import '../../services/word_service.dart';
import 'quiz_screen.dart';

enum QuizMode { enToVi, viToEn, listening }

class QuizConfigurationScreen extends StatefulWidget {
  final String initialTopic;
  const QuizConfigurationScreen({super.key, this.initialTopic = 'All'});

  @override
  State<QuizConfigurationScreen> createState() =>
      _QuizConfigurationScreenState();
}

class _QuizConfigurationScreenState extends State<QuizConfigurationScreen> {
  final WordService _wordService = WordService();
  late String _selectedTopic;
  int _questionCount = 10;
  QuizMode _selectedMode = QuizMode.enToVi;

  // Chứa danh sách từ của topic đang chọn
  List<Word> _currentWordsPool = [];

  @override
  void initState() {
    super.initState();
    _selectedTopic = widget.initialTopic;
    _updateWordsPool();
  }

  // Cập nhật kho từ vựng mỗi khi đổi Topic
  void _updateWordsPool() {
    if (_selectedTopic == 'All') {
      _currentWordsPool = _wordService.getRandomWords(9999); // Lấy tất cả
    } else if (_selectedTopic == 'Review') {
      _currentWordsPool = _wordService.getWordsToReview();
    } else {
      _currentWordsPool = _wordService.getWordsByTopic(_selectedTopic);
    }

    // Logic điều chỉnh số lượng câu hỏi an toàn
    final maxWords = _currentWordsPool.length;
    if (maxWords < 4) {
      _questionCount = maxWords; // Sẽ khóa nút Start ở build()
    } else {
      // Đảm bảo lựa chọn hiện tại không vượt quá số từ đang có
      if (_questionCount > maxWords && _questionCount != 9999) {
        _questionCount = 10;
      }
      if (_questionCount == 10 && maxWords < 10) {
        _questionCount = 9999; // Nếu ít hơn 10 nhưng > 4, chọn "Tất cả"
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    // Thêm 'Review' vào danh sách để user có thể chủ động chọn ôn tập
    final topics = ['All', 'Review', ..._wordService.getAllTopics()];
    final maxWords = _currentWordsPool.length;
    final bool isNotEnoughWords = maxWords < 4;

    return Scaffold(
      appBar: AppBar(title: Text('quiz_config.config_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'quiz_config.select_topic'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<String>(
              isExpanded: true,
              value: topics.contains(_selectedTopic) ? _selectedTopic : 'All',
              items: topics.map((t) {
                // Đổi tên hiển thị cho đẹp
                String displayName = t;
                if (t == 'All') displayName = 'quiz_config.topic_all'.tr();
                if (t == 'Review') {
                  displayName = 'quiz_config.topic_review'.tr();
                }

                return DropdownMenuItem(value: t, child: Text(displayName));
              }).toList(),
              onChanged: (val) {
                setState(() {
                  _selectedTopic = val!;
                  _updateWordsPool();
                });
              },
            ),
            const SizedBox(height: 24),

            // XỬ LÝ LOGIC HIỂN THỊ SỐ LƯỢNG CÂU HỎI ĐỘNG
            Text(
              'quiz_config.select_count'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            if (isNotEnoughWords)
              Padding(
                padding: const EdgeInsets.only(top: 8.0),
                child: Text(
                  'quiz_config.not_enough_words'.tr(
                    args: [maxWords.toString()],
                  ),
                  style: const TextStyle(
                    color: Colors.red,
                    fontStyle: FontStyle.italic,
                  ),
                ),
              )
            else
              DropdownButton<int>(
                isExpanded: true,
                value: _questionCount,
                items: [
                  if (maxWords >= 10)
                    const DropdownMenuItem(value: 10, child: Text("10 Câu")),
                  if (maxWords >= 20)
                    const DropdownMenuItem(value: 20, child: Text("20 Câu")),
                  if (maxWords >= 50)
                    const DropdownMenuItem(value: 50, child: Text("50 Câu")),
                  DropdownMenuItem(
                    value: 9999,
                    child: Text("Tất cả ($maxWords câu)"),
                  ),
                ],
                onChanged: (val) => setState(() => _questionCount = val!),
              ),

            const SizedBox(height: 24),

            Text(
              'quiz_config.select_mode'.tr(),
              style: const TextStyle(fontWeight: FontWeight.bold),
            ),
            DropdownButton<QuizMode>(
              isExpanded: true,
              value: _selectedMode,
              items: [
                DropdownMenuItem(
                  value: QuizMode.enToVi,
                  child: Text('quiz_config.mode_en_vi'.tr()),
                ),
                DropdownMenuItem(
                  value: QuizMode.viToEn,
                  child: Text('quiz_config.mode_vi_en'.tr()),
                ),
                DropdownMenuItem(
                  value: QuizMode.listening,
                  child: Text('quiz_config.mode_listening'.tr()),
                ),
              ],
              onChanged: (val) => setState(() => _selectedMode = val!),
            ),

            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                minimumSize: const Size(double.infinity, 50),
                backgroundColor: isNotEnoughWords
                    ? Colors.grey
                    : Theme.of(context).colorScheme.primary,
                foregroundColor: Colors.white,
              ),
              onPressed: isNotEnoughWords
                  ? null
                  : () {
                      // Xử lý chốt danh sách câu hỏi
                      List<Word> targetWords = List.from(_currentWordsPool);
                      targetWords.shuffle();

                      if (_questionCount != 9999) {
                        targetWords = targetWords.take(_questionCount).toList();
                      }

                      // Luôn lấy toàn bộ DB làm Pool đáp án nhiễu để Quiz khó hơn (trừ khi All DB quá ít)
                      final distractorPool = _wordService.getRandomWords(9999);

                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(
                          builder: (_) => QuizScreen(
                            targetWords: targetWords,
                            distractorPool: distractorPool,
                            questionCount: targetWords.length,
                            mode: _selectedMode,
                          ),
                        ),
                      );
                    },
              child: Text('quiz_config.start_btn'.tr()),
            ),
          ],
        ),
      ),
    );
  }
}
