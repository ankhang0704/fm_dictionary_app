// file: lib/features/saved/presentation/screens/saved_words_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/services/database/database_service.dart';
import '../../../../data/services/database/word_service.dart';
import '../../../../core/constants/constants.dart';
import '../../../../core/widgets/generic_status_screen.dart';

class SavedWordsScreen extends StatefulWidget {
  const SavedWordsScreen({super.key});

  @override
  State<SavedWordsScreen> createState() => _SavedWordsScreenState();
}

class _SavedWordsScreenState extends State<SavedWordsScreen> {
  final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final saveBoxListenable = Hive.box(DatabaseService.saveBoxName).listenable();

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: const Text("Từ vựng đã lưu", style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
      ),
      body: ValueListenableBuilder(
        valueListenable: saveBoxListenable,
        builder: (context, box, _) {
          final savedWords = _wordService.getSavedWords();

          // TẬN DỤNG GENERIC STATUS SCREEN LÀM EMPTY STATE TẠI CHỖ
          if (savedWords.isEmpty) {
            return GenericStatusScreen(
              icon: CupertinoIcons.bookmark_fill,
              themeColor: AppConstants.accentColor,
              title: "Chưa có từ vựng nào",
              subTitle: "Hãy nhấn vào biểu tượng trái tim khi học bài để lưu lại những từ vựng quan trọng nhé.",
              primaryButtonLabel: "Khám phá ngay",
              onPrimaryPressed: () => Navigator.pop(context), // Quay lại màn hình trước
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            physics: const BouncingScrollPhysics(),
            itemCount: savedWords.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final word = savedWords[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
                  title: Text(word.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  subtitle: Text(word.meaning, maxLines: 1, overflow: TextOverflow.ellipsis),
                  trailing: IconButton(
                    icon: const Icon(CupertinoIcons.heart_solid, color: AppConstants.errorColor),
                    onPressed: () => _wordService.toggleSaveWord(word.id), // Bỏ lưu realtime
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