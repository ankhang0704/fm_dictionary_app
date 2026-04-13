import 'dart:math';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';

import '../../data/models/word_model.dart';
import '../../data/services/database/database_service.dart';
import '../../data/services/database/word_service.dart';
import '../../core/constants/constants.dart';
import '../../core/widgets/common/progress_card.dart';
import '../../core/widgets/common/home_search_bar.dart';
import '../learning/study_screen.dart';
import 'widgets/greeting_widget.dart';
import 'widgets/quick_action_widget.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WordService _wordService = WordService();
  late String _randomSlogan;

  @override
  void initState() {
    super.initState();
    _randomSlogan = _getMotivationalSlogan();
  }

  String _getMotivationalSlogan() {
    final random = Random();
    // Luôn bọc .tr() để đa ngôn ngữ
    return AppConstants
        .motivationalSlogans[random.nextInt(
          AppConstants.motivationalSlogans.length,
        )]
        .tr();
  }

  // Hàm Popup cho AI Features (Không tạo màn hình mới)
  void _showAIFeatureInfo(BuildContext context, String title, String desc) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title).tr(),
        content: Text(desc).tr(),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder(
          // CHỈ LẮNG NGHE DUY NHẤT PROGRESS BOX
          valueListenable: Hive.box(
            DatabaseService.progressBoxName,
          ).listenable(),
          builder: (context, Box progressBox, _) {
            final wordBox = Hive.box<Word>(DatabaseService.wordBoxName);

            // A. KIỂM TRA TRẠNG THÁI USER
            bool isNewUser = progressBox.isEmpty;

            return SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const HomeSearchBar(),
                  const SizedBox(height: 24),

                  if (isNewUser)
                    _buildNewUserLayout(context, isDark)
                  else
                    _buildReturningUserLayout(
                      context,
                      settings.userName,
                      isDark,
                      progressBox,
                      wordBox,
                    ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  // --- 1. LAYOUT NEW USER (CỦA BẠN: KHÁM PHÁ + AI) ---
  Widget _buildNewUserLayout(BuildContext context, bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('dashboard.explore_topics'.tr(), isDark),
        const SizedBox(height: 12),
        _buildDiscoveryCard(
          'dashboard.explore_topics'.tr(),
          'dashboard.explore_desc'.tr(),
          Icons.auto_awesome_motion,
          Colors.blue,
          onTap: () => Navigator.push(
            context,
            CupertinoPageRoute(
              builder: (_) => const StudyScreen(topic: 'General'),
            ),
          ),
        ),
        const SizedBox(height: 24),
        _buildSectionTitle('dashboard.ai_features'.tr(), isDark),
        const SizedBox(height: 12),
        _buildDiscoveryCard(
          'dashboard.whisper_title'.tr(),
          'dashboard.whisper_desc'.tr(),
          Icons.mic,
          Colors.purple,
          onTap: () => _showAIFeatureInfo(
            context,
            'dashboard.whisper_title',
            'dashboard.whisper_desc',
          ),
        ),
        _buildDiscoveryCard(
          'dashboard.tts_title'.tr(),
          'dashboard.tts_desc'.tr(),
          Icons.volume_up,
          Colors.orange,
          onTap: () => _showAIFeatureInfo(
            context,
            'dashboard.tts_title',
            'dashboard.tts_desc',
          ),
        ),
      ],
    );
  }

  // --- 2. LAYOUT RETURNING USER (DỰA TRÊN TIẾN ĐỘ THẬT) ---
  Widget _buildReturningUserLayout(
    BuildContext context,
    String userName,
    bool isDark,
    Box progressBox,
    Box<Word> wordBox,
  ) {
    // Thống kê tiến độ
    final totalCount = wordBox.length;
    final learnedCount = wordBox.values
        .where((w) => _wordService.isWordLearned(w.id))
        .length;

    // Lấy danh sách các Word ID đã sắp xếp theo thời gian ua (updated at) giảm dần
    final List<dynamic> sortedEntries = progressBox.keys.toList()
      ..sort((a, b) {
        final progressA = Map<String, dynamic>.from(progressBox.get(a));
        final progressB = Map<String, dynamic>.from(progressBox.get(b));
        return (progressB['ua'] as int).compareTo(progressA['ua'] as int);
      });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        GreetingSection(userName: userName, isDark: isDark),
        const SizedBox(height: 8),
        Text(
          _randomSlogan,
          style: TextStyle(
            fontStyle: FontStyle.italic,
            color: isDark ? Colors.white60 : Colors.black54,
          ),
        ),
        const SizedBox(height: 24),

        // 1. Progress Card (Thanh tiến độ của bạn)
        ProgressCard(learnedCount: learnedCount, totalCount: totalCount),
        const SizedBox(height: 24),

        // 4. Quick Actions
        QuickActionsList(wordService: _wordService, isDark: isDark),
        const SizedBox(height: 24),

        // 3. Recent History (Top 5 từ có ua cao nhất)
        _buildSectionTitle('dashboard.recent_history'.tr(), isDark),
        const SizedBox(height: 8),
        ...sortedEntries.take(5).map((id) {
          final word = wordBox.get(id);
          return ListTile(
            dense: true,
            contentPadding: EdgeInsets.zero,
            leading: const Icon(Icons.history, size: 18),
            title: Text(word?.word ?? ""),
            onTap: () => Navigator.push(
              context,
              CupertinoPageRoute(
                builder: (_) => StudyScreen(topic: word?.topic ?? "General"),
              ),
            ),
          );
        }),
      ],
    );
  }

  // --- HELPER WIDGETS ---
  Widget _buildDiscoveryCard(
    String title,
    String desc,
    IconData icon,
    Color color, {
    required VoidCallback onTap,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 12),
      elevation: 0,
      color: color.withValues(alpha: 0.05),
      child: ListTile(
        onTap: onTap,
        leading: Icon(icon, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(desc),
      ),
    );
  }

  Widget _buildSectionTitle(String title, bool isDark) {
    return Text(
      title,
      style: AppConstants.subHeadingStyle.copyWith(
        fontSize: 15,
        fontWeight: FontWeight.bold,
        color: isDark ? Colors.white70 : AppConstants.textSecondary,
      ),
    );
  }
}
