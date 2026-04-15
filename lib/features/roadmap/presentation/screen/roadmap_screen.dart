// lib/features/roadmap/presentation/screen/roadmap_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import 'learning_roadmap_screen.dart';

class RoadmapScreen extends StatelessWidget {
  const RoadmapScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      body: SafeArea(
        child: Consumer<RoadmapProvider>(
          builder: (context, provider, child) {
            if (provider.isLoading) {
              return const Center(child: CircularProgressIndicator());
            }

            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.all(AppConstants.defaultPadding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Lộ trình học tập',
                        style: AppConstants.headingStyle.copyWith(
                          fontSize: 28, color: isDark ? Colors.white : AppConstants.textPrimary,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        '1500+ từ vựng được chia thành các chặng nhỏ',
                        style: AppConstants.bodyStyle.copyWith(color: AppConstants.textSecondary),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.only(
                      left: AppConstants.defaultPadding,
                      right: AppConstants.defaultPadding,
                      bottom: 100, // Bottom Nav
                    ),
                    itemCount: provider.chapters.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final chapter = provider.chapters[index];
                      // Tính tổng từ của Chapter
                      int totalWords = chapter.lessons.fold(0, (sum, lesson) => sum + lesson.words.length);
                      
                      return _ChapterCard(
                        chapter: chapter,
                        totalWords: totalWords,
                        isDark: isDark,
                        onTap: () {
                          provider.selectChapter(index);
                          Navigator.push(
                            context,
                            CupertinoPageRoute(builder: (context) => const LearningRoadmapScreen()),
                          );
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

class _ChapterCard extends StatelessWidget {
  final RoadmapChapter chapter;
  final int totalWords;
  final bool isDark;
  final VoidCallback onTap;

  const _ChapterCard({required this.chapter, required this.totalWords, required this.isDark, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          borderRadius: BorderRadius.circular(AppConstants.cardRadius / 1.5),
          boxShadow: isDark ? [] : [BoxShadow(color: Colors.black.withValues(alpha: 0.03), blurRadius: 10, offset: const Offset(0, 4))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AppConstants.accentColor.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(CupertinoIcons.map_fill, color: AppConstants.accentColor, size: 28),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    chapter.title,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: isDark ? Colors.white : AppConstants.textPrimary),
                  ),
                  const SizedBox(height: 4),
                  Text('$totalWords từ vựng (${chapter.lessons.length} Bài học)', style: TextStyle(color: AppConstants.textSecondary)),
                ],
              ),
            ),
            const Icon(CupertinoIcons.chevron_right, color: AppConstants.textLight, size: 20),
          ],
        ),
      ),
    );
  }
}