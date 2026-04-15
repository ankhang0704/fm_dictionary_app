// file: lib/features/history/presentation/screens/history_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/generic_status_screen.dart';

class HistoryScreen extends StatelessWidget {
  HistoryScreen({super.key});

  final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final progressBoxListenable = Hive.box(
      DatabaseService.progressBoxName,
    ).listenable();

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text(
          "Lịch sử học tập",
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: progressBoxListenable,
        builder: (context, box, _) {
          final historyWords = _wordService.getHistoryWords();

          if (historyWords.isEmpty) {
            return GenericStatusScreen(
              icon: CupertinoIcons.clock_fill,
              themeColor: AppConstants.accentColor,
              title: "Chưa có dữ liệu",
              subTitle:
                  "Bạn chưa bắt đầu bài học nào. Hãy quay lại trang chủ và bắt đầu chuỗi học tập của mình nhé!",
              primaryButtonLabel: "Bắt đầu học",
              onPrimaryPressed: () => Navigator.pop(context),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: historyWords.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final word = historyWords[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppConstants.darkCardColor
                      : AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 8,
                  ),
                  leading: CircleAvatar(
                    backgroundColor: AppConstants.accentColor.withValues(
                      alpha: 0.1,
                    ),
                    child: const Icon(
                      CupertinoIcons.checkmark_alt,
                      color: AppConstants.accentColor,
                    ),
                  ),
                  title: Text(
                    word.word,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                  subtitle: Text(
                    word.topic,
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                  onTap: () {
                    Navigator.pushNamed(context, AppRoutes.wordDetail,
                        arguments: {'word': word});
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
