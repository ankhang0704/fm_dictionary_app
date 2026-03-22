import 'package:flutter/material.dart';
import 'package:fm_dictionary/models/word_model.dart';
import 'package:fm_dictionary/services/database_service.dart';
import 'package:hive/hive.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();
    final learnedCount = DatabaseService.getLearnedCount();
    final totalCount = Hive.box<Word>(DatabaseService.wordBoxName).length;
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header: Lời chào & Tiến độ tổng quát
              const Text(
                'Good Morning,',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              Text(
                 settings.userName, 
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  fontFamily: 'Georgia',
                  fontStyle: FontStyle.italic,
                ),
              ),
              const SizedBox(height: 24),

              // Thanh tìm kiếm (Dictionary Mode)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.grey.shade200),
                ),
                child: const TextField(
                  decoration: InputDecoration(
                    hintText: 'Search 1,500 words...',
                    border: InputBorder.none,
                    icon: Icon(Icons.search, color: Colors.grey),
                  ),
                ),
              ),
              const SizedBox(height: 32),

              // Thẻ tiến độ (Progress Card)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: const Color(0xFF1A1A1A),
                  borderRadius: BorderRadius.circular(32),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Overall Progress',
                      style: TextStyle(color: Colors.white70, fontSize: 12),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '$learnedCount / $totalCount words',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),

                    const SizedBox(height: 16),
                    LinearProgressIndicator(
                      value: totalCount > 0 ? learnedCount / totalCount : 0,
                      backgroundColor: Colors.white10,
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),

              // Smart Buttons Section
              const Text(
                'QUICK ACTIONS',
                style: TextStyle(
                  fontSize: 12,
                  letterSpacing: 2,
                  color: Colors.grey,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 16),

              _buildSmartButton(
                context,
                icon: Icons.play_circle_fill_rounded,
                title: 'Continue Learning',
                subtitle: 'Topic: Business • Word 42',
                color: const Color(0xFFE3F2FD),
                iconColor: Colors.blue,
              ),
              const SizedBox(height: 12),
              _buildSmartButton(
                context,
                icon: Icons.error_outline_rounded,
                title: 'Review Mistakes',
                subtitle: '12 words need attention',
                color: const Color(0xFFFFEBEE),
                iconColor: Colors.red,
              ),
              const SizedBox(height: 12),
              _buildSmartButton(
                context,
                icon: Icons.shuffle_rounded,
                title: 'Random 10 Words',
                subtitle: 'Quick daily test',
                color: const Color(0xFFF1F8E9),
                iconColor: Colors.green,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSmartButton(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required Color iconColor,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: Colors.grey.shade100),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(16),
            ),
            child: Icon(icon, color: iconColor),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                Text(
                  subtitle,
                  style: const TextStyle(color: Colors.grey, fontSize: 12),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey),
        ],
      ),
    );
  }
}
