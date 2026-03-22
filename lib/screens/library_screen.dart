import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../models/word_model.dart';
import '../services/database_service.dart';
import 'study_screen.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  static const Map<String, IconData> topicIcons = {
    'General Facilities Management': Icons.business_rounded,
    'Hard Services': Icons.build_rounded,
    'Soft Services': Icons.cleaning_services_rounded,
    'Finance': Icons.payments_rounded,
    'Procurement': Icons.shopping_cart_rounded,
    'Workplace Experience': Icons.sentiment_satisfied_alt_rounded,
    'ESS': Icons.badge_rounded,
    'HSSE': Icons.security_rounded,
    'Technology': Icons.memory_rounded,
    'Human Resources': Icons.groups_rounded,
    'Laws, Ethics & BCP': Icons.gavel_rounded,
  };

  @override
  Widget build(BuildContext context) {
    final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);

    // Gom nhóm và đếm từ từ Hive
    final Map<String, int> topicCounts = {};
    for (var word in wordBox.values) {
      topicCounts[word.topic] = (topicCounts[word.topic] ?? 0) + 1;
    }
    final topics = topicCounts.keys.toList();

    return Scaffold(
      backgroundColor: const Color(0xFFFDFCF9),
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Padding(
              padding: EdgeInsets.fromLTRB(24, 40, 24, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Library',
                    style: TextStyle(
                      fontSize: 32,
                      fontFamily: 'Georgia',
                      fontStyle: FontStyle.italic,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    'EXPLORE FM TOPICS',
                    style: TextStyle(
                      fontSize: 12,
                      letterSpacing: 2,
                      color: Colors.grey,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: ListView.separated(
                // Sử dụng ListView thay vì GridView
                padding: const EdgeInsets.symmetric(
                  horizontal: 24,
                  vertical: 8,
                ),
                itemCount: topics.length,
                separatorBuilder: (context, index) =>
                    const SizedBox(height: 12), // Khoảng cách giữa các hàng
                itemBuilder: (context, index) {
                  final name = topics[index];
                  final count = topicCounts[name];
                  final icon = topicIcons[name] ?? Icons.book_rounded;

                  return GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => StudyScreen(topic: name),
                      ),
                    ),
                    child: Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(
                          24,
                        ), // Bo góc hiện đại
                        border: Border.all(color: Colors.grey.shade200),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withAlpha((255 * 0.02).toInt()),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        // Chuyển sang Row để hiển thị theo hàng ngang
                        children: [
                          Container(
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF5F5F5),
                              borderRadius: BorderRadius.circular(16),
                            ),
                            child: Icon(
                              icon,
                              size: 28,
                              color: const Color(0xFF1A1A1A),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  name,
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                    color: Color(0xFF1A1A1A),
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  '$count words available',
                                  style: const TextStyle(
                                    fontSize: 13,
                                    color: Colors.grey,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(
                            Icons.chevron_right_rounded,
                            color: Colors.grey,
                          ),
                        ],
                      ),
                    ),
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
