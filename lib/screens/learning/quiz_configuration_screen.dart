import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../services/word_service.dart';
import 'quiz_screen.dart'; 

// Khai báo Enum quản lý 3 chế độ
enum QuizMode { enToVi, viToEn, listening }

class QuizConfigurationScreen extends StatefulWidget {
  const QuizConfigurationScreen({super.key});

  @override
  State<QuizConfigurationScreen> createState() => _QuizConfigurationScreenState();
}

class _QuizConfigurationScreenState extends State<QuizConfigurationScreen> {
  final WordService _wordService = WordService();
  String _selectedTopic = 'All';
  int _questionCount = 10;
  QuizMode _selectedMode = QuizMode.enToVi; // Mặc định Anh - Việt

  @override
  Widget build(BuildContext context) {
    final topics =['All', ..._wordService.getAllTopics()];

    return Scaffold(
      appBar: AppBar(title: Text('quiz_config.config_title'.tr())),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children:[
            Text('quiz_config.select_topic'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<String>(
              isExpanded: true,
              value: _selectedTopic,
              items: topics.map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
              onChanged: (val) => setState(() => _selectedTopic = val!),
            ),
            const SizedBox(height: 24),
            
            Text('quiz_config.select_count'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            Slider(
              value: _questionCount.toDouble(),
              min: 5, max: 50, divisions: 9,
              label: _questionCount.toString(),
              onChanged: (val) => setState(() => _questionCount = val.toInt()),
            ),
            const SizedBox(height: 24),

            // THAY THẾ BẰNG DROPDOWN CHỌN CHẾ ĐỘ
            Text('quiz_config.select_mode'.tr(), style: const TextStyle(fontWeight: FontWeight.bold)),
            DropdownButton<QuizMode>(
              isExpanded: true,
              value: _selectedMode,
              items:[
                DropdownMenuItem(value: QuizMode.enToVi, child: Text('quiz_config.mode_en_vi'.tr())),
                DropdownMenuItem(value: QuizMode.viToEn, child: Text('quiz_config.mode_vi_en'.tr())),
                DropdownMenuItem(value: QuizMode.listening, child: Text('quiz_config.mode_listening'.tr())),
              ],
              onChanged: (val) => setState(() => _selectedMode = val!),
            ),

            const Spacer(),
            ElevatedButton(
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 50)),
              onPressed: () {
                final pool = _selectedTopic == 'All' 
                    ? _wordService.getRandomWords(1000) 
                    : _wordService.getWordsByTopic(_selectedTopic);
                    
                if (pool.length < 4) {
                  ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('quiz_config.not_enough_words'.tr())));
                  return;
                }

                final targetWords = pool.take(_questionCount).toList();

                Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(builder: (_) => QuizScreen(
                    targetWords: targetWords,
                    distractorPool: pool,
                    questionCount: _questionCount,
                    mode: _selectedMode, // Truyền Enum vào QuizScreen
                  )),
                );
              },
              child: Text('quiz_config.start_btn'.tr()),
            )
          ],
        ),
      ),
    );
  }
}