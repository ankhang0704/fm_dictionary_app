// lib/features/roadmap/presentation/screen/learning_roadmap_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/data/services/features/quiz_service.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import '../../../learning/presentation/providers/quiz_provider.dart';
import '../../../learning/quiz_screen.dart';
import '../../../learning/study_screen.dart';

class LearningRoadmapScreen extends StatelessWidget {
  const LearningRoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Consumer<RoadmapProvider>(
          builder: (context, provider, _) => Text(
            provider.chapters[provider.selectedChapterIndex].title,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ),
        centerTitle: true, backgroundColor: Colors.transparent, elevation: 0,
      ),
      body: Consumer<RoadmapProvider>(
        builder: (context, provider, _) {
          final currentChapter = provider.chapters[provider.selectedChapterIndex];

          return ListView.builder(
            padding: const EdgeInsets.symmetric(vertical: 20),
            itemCount: currentChapter.lessons.length,
            itemBuilder: (context, index) {
              final lesson = currentChapter.lessons[index];
              final isUnlocked = provider.isLessonUnlocked(lesson.globalIndex);
              final progress = provider.getLessonProgress(lesson.globalIndex);
              final isLeft = index % 2 == 0;

              // KIỂM TRA CHUYỂN TOPIC LÀM ĐƯỜNG PHÂN CÁCH
              bool showTopicDivider = false;
              if (index == 0) {
                showTopicDivider = true;
              } else {
                final prevLesson = currentChapter.lessons[index - 1];
                if (lesson.dominantTopic != prevLesson.dominantTopic) {
                  showTopicDivider = true;
                }
              }

              return Column(
                children: [
                  if (showTopicDivider) _buildTopicDivider(lesson.dominantTopic, isDark),
                  Padding(
                    padding: EdgeInsets.only(
                      left: isLeft ? 50 : 150, 
                      right: isLeft ? 150 : 50, 
                      bottom: 40, top: 10
                    ),
                    child: _buildNode(context, lesson, isUnlocked, progress, isDark),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildTopicDivider(String topicName, bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 30),
      child: Row(
        children: [
          const Expanded(child: Divider(thickness: 2)),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Text(
              "Chủ đề: $topicName",
              style: TextStyle(
                fontWeight: FontWeight.bold, color: isDark ? Colors.white54 : Colors.black54, letterSpacing: 1.2
              ),
            ),
          ),
          const Expanded(child: Divider(thickness: 2)),
        ],
      ),
    );
  }

  Widget _buildNode(BuildContext context, RoadmapLesson lesson, bool isUnlocked, double progress, bool isDark) {
    int wordsLearned = (progress * lesson.words.length).toInt();

    return GestureDetector(
      onTap: isUnlocked ? () => _showLevelActions(context, lesson) : null,
      child: Column(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 90, height: 90,
                child: CircularProgressIndicator(
                  value: progress, strokeWidth: 8,
                  backgroundColor: Colors.grey.withValues(alpha: 0.2),
                  valueColor: AlwaysStoppedAnimation<Color>(progress >= 0.8 ? Colors.amber : AppConstants.accentColor),
                ),
              ),
              Container(
                width: 70, height: 70,
                decoration: BoxDecoration(
                  color: isUnlocked ? (progress >= 0.8 ? Colors.amber : AppConstants.accentColor) : Colors.grey,
                  shape: BoxShape.circle,
                  boxShadow: isUnlocked ? [BoxShadow(color: AppConstants.accentColor.withValues(alpha: 0.3), blurRadius: 10)] : [],
                ),
                child: Icon(
                  !isUnlocked ? CupertinoIcons.lock_fill : (progress >= 0.8 ? CupertinoIcons.star_fill : CupertinoIcons.flag_fill),
                  color: Colors.white, size: 30,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text("Bài ${lesson.globalIndex + 1}", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          Text("$wordsLearned/${lesson.words.length}", style: TextStyle(color: isDark ? Colors.white54 : Colors.black54, fontSize: 13)),
        ],
      ),
    );
  }

  void _showLevelActions(BuildContext context, RoadmapLesson lesson) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(28))),
      builder: (context) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text("Bài ${lesson.globalIndex + 1}", style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            const SizedBox(height: 8),
            Text("Chủ đề chính: ${lesson.dominantTopic}", style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 32),
            _actionBtn(
              context, "Học Flashcard", CupertinoIcons.book, AppConstants.accentColor, 
              () {
                // Sửa lại StudyScreen để nhận List<Word> thay vì String topic
                // Navigator.push(context, CupertinoPageRoute(builder: (_) => StudyScreen(words: lesson.words)));
              }
            ),
            const SizedBox(height: 16),
            _actionBtn(
              context, "Làm Quiz ôn tập", CupertinoIcons.checkmark_shield, Colors.blue, 
              () {
                context.read<QuizProvider>().initQuiz(lesson.words, QuizMode.viToEn);
                Navigator.push(context, CupertinoPageRoute(builder: (_) => const QuizScreen()));
              }
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionBtn(BuildContext context, String label, IconData icon, Color color, VoidCallback onTap) {
    return SizedBox(
      width: double.infinity, height: 56,
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(backgroundColor: color, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16))),
        onPressed: onTap, icon: Icon(icon, color: Colors.white), label: Text(label, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
    );
  }
}