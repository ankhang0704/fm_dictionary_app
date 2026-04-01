// file: lib/screens/home/dashboard_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/screens/home/widgets/greeting_widget.dart';
import 'package:fm_dictionary/screens/home/widgets/quick_action_widget.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database/database_service.dart';
import '../../services/database/word_service.dart';
import '../../core/constants/constants.dart';
import '../../widgets/common/progress_card.dart';
import '../../widgets/common/home_search_bar.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      body: SafeArea(
        child: ValueListenableBuilder(
          valueListenable: Hive.box(DatabaseService.progressBoxName).listenable(),
          builder: (context, progressBox, _) {
            return ValueListenableBuilder(
              valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
              builder: (context, wordBox, _) {
                final totalCount = wordBox.length;
                final learnedCount = wordBox.values.where((w) => _wordService.isWordLearned(w.id)).length;

                return SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppConstants.defaultPadding,
                    vertical: 16.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GreetingSection(userName: settings.userName, isDark: isDark),
                      const SizedBox(height: 24),
                      const HomeSearchBar(),
                      const SizedBox(height: 32),
                      ProgressCard(learnedCount: learnedCount, totalCount: totalCount),
                      const SizedBox(height: 32),
                      Text(
                        'dashboard.quick_action'.tr(),
                        style: AppConstants.subHeadingStyle.copyWith(
                          fontSize: 14,
                          color: isDark ? Colors.white70 : AppConstants.textSecondary,
                        ),
                      ),
                      const SizedBox(height: 16),
                      QuickActionsList(wordService: _wordService, isDark: isDark),
                      const SizedBox(height: 24),
                    ],
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}


