import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/constants.dart';
import 'package:fm_dictionary/data/models/word_model.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/data/services/database/word_service.dart';
import 'package:fm_dictionary/features/library/presentation/screens/detail_dictionary_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';


class DictionaryScreen extends StatelessWidget {
  const DictionaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final WordService wordService = WordService();

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text('Kho Từ Điển', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
      ),
      body: ValueListenableBuilder(
        valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
        builder: (context, wordBox, child) {
          // Tính toán topic
          final Map<String, int> topicCounts = {};
          for (var word in wordBox.values) {
            topicCounts[word.topic] = (topicCounts[word.topic] ?? 0) + 1;
          }
          final topics = topicCounts.keys.toList()..sort();

          return GridView.builder(
            padding: const EdgeInsets.all(20),
            physics: const BouncingScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2, // 2 cột
              crossAxisSpacing: 16,
              mainAxisSpacing: 16,
              childAspectRatio: 0.9, // Tỷ lệ khối Bento
            ),
            itemCount: topics.length,
            itemBuilder: (context, index) {
              final topic = topics[index];
              final total = topicCounts[topic] ?? 0;
              
              return InkWell(
                onTap: () => Navigator.push(context, CupertinoPageRoute(builder: (_) => DictionaryDetailScreen(topic: topic))),
                borderRadius: BorderRadius.circular(24),
                child: Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
                    borderRadius: BorderRadius.circular(24),
                    border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppConstants.accentColor.withValues(alpha: 0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(AppConstants.topicIcons[topic] ?? CupertinoIcons.book_fill, color: AppConstants.accentColor),
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(topic, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16), maxLines: 2, overflow: TextOverflow.ellipsis),
                          const SizedBox(height: 4),
                          Text('$total từ', style: const TextStyle(color: Colors.grey, fontSize: 13)),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}