import 'package:flutter/material.dart';
import 'package:fm_dictionary/screens/library/topic_detail.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../utils/constants.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(AppConstants.defaultPadding, 40, AppConstants.defaultPadding, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Categories', style: AppConstants.headingStyle),
                  Text('EXPLORE FM TOPICS', style: AppConstants.subHeadingStyle),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ValueListenableBuilder(
                valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
                builder: (context, box, _) {
                  final Map<String, int> topicCounts = {};
                  final Map<String, int> learnedCounts = {};
                  
                  for (var word in box.values) {
                    topicCounts[word.topic] = (topicCounts[word.topic] ?? 0) + 1;
                    if (word.isLearned) {
                      learnedCounts[word.topic] = (learnedCounts[word.topic] ?? 0) + 1;
                    }
                  }
                  final topics = topicCounts.keys.toList();

                  return ListView.separated(
                    padding: const EdgeInsets.symmetric(horizontal: AppConstants.defaultPadding, vertical: 8),
                    itemCount: topics.length,
                    separatorBuilder: (context, index) => const SizedBox(height: 16),
                    itemBuilder: (context, index) {
                      final name = topics[index];
                      final totalCount = topicCounts[name] ?? 0;
                      final learnedCount = learnedCounts[name] ?? 0;
                      final icon = AppConstants.topicIcons[name] ?? Icons.book_rounded;
                      final isDark = Theme.of(context).brightness == Brightness.dark;
                      final progress = totalCount > 0 ? learnedCount / totalCount : 0.0;

                      return GestureDetector(
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => TopicDetailScreen(topic: name),
                          ),
                        ),
                        child: Container(
                          decoration: BoxDecoration(
                            color: Theme.of(context).cardColor,
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.05),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ],
                          ),
                          padding: const EdgeInsets.all(20),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: isDark ? Colors.grey[600] : Colors.grey[200],
                                  borderRadius: BorderRadius.circular(16),
                                ),
                                child: Icon(icon, color: isDark? Colors.white : AppConstants.primaryColor, size: 28),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      name,
                                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      '$learnedCount / $totalCount words learned',
                                      style: TextStyle(
                                        fontSize: 13,
                                        color: isDark ? Colors.grey[400] : Colors.grey[600],
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(4),
                                      child: LinearProgressIndicator(
                                        value: progress,
                                        backgroundColor: isDark ? Colors.grey[800] : Colors.grey[200],
                                        valueColor: AlwaysStoppedAnimation<Color>(
                                          progress == 1.0 ? AppConstants.successColor : AppConstants.primaryColor,
                                        ),
                                        minHeight: 6,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 12),
                              const Icon(Icons.chevron_right_rounded, color: Colors.grey),
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
