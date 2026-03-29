import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/screens/learning/quiz_configuration_screen.dart';
import 'package:fm_dictionary/screens/learning/quiz_screen.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../services/word_service.dart';
import '../../core/constants/constants.dart';
import '../learning/study_screen.dart';
import '../search/word_detail_screen.dart';

class TopicDetailScreen extends StatefulWidget {
  final String topic;
  const TopicDetailScreen({super.key, required this.topic});

  @override
  State<TopicDetailScreen> createState() => _TopicDetailScreenState();
}

class _TopicDetailScreenState extends State<TopicDetailScreen> {
  String _searchQuery = "";
  final WordService _wordService = WordService();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return ValueListenableBuilder(
      valueListenable: Hive.box<Word>(DatabaseService.wordBoxName).listenable(),
      builder: (context, progressBox, child) {
        final allWords = WordService().getWordsByTopic(widget.topic);
        final filteredWords = allWords
            .where(
              (w) => w.word.toLowerCase().contains(_searchQuery.toLowerCase()),
            )
            .toList();
        final learnedCount = allWords
            .where((w) => _wordService.isWordLearned(w.id))
            .length;
        final progress = allWords.isEmpty
            ? 0.0
            : learnedCount / allWords.length;

        return Scaffold(
          body: CustomScrollView(
            slivers: [
              SliverAppBar(
                expandedHeight: 220,
                pinned: true,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                flexibleSpace: FlexibleSpaceBar(
                  centerTitle: true,
                  titlePadding: const EdgeInsets.only(
                    bottom: 16,
                    left: 20,
                    right: 20,
                  ),
                  title: Text(
                    widget.topic,
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                      color: isDark ? Colors.white : Colors.black87,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis, // CHỐNG TRÀN TÊN TOPIC
                  ),
                  background: Container(
                    decoration: BoxDecoration(
                      color: AppConstants.primaryColor.withValues(alpha: 0.1),
                      borderRadius: const BorderRadius.only(
                        bottomLeft: Radius.circular(40),
                        bottomRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const SizedBox(height: 20),
                        Icon(
                          Icons.auto_stories_rounded,
                          size: 40,
                          color: AppConstants.primaryColor,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          "$learnedCount / ${allWords.length} ${'topic.words_learned'.tr()}",
                          style: TextStyle(
                            color: isDark ? Colors.white70 : Colors.black54,
                          ),
                        ),
                        const SizedBox(height: 16),
                        // Dùng phần trăm width thay vì pixel cứng để tránh tràn trên máy nhỏ
                        SizedBox(
                          width: MediaQuery.of(context).size.width * 0.5,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: LinearProgressIndicator(
                              value: progress,
                              minHeight: 8,
                              backgroundColor: Colors.grey.withValues(
                                alpha: 0.2,
                              ),
                              valueColor: AlwaysStoppedAnimation<Color>(
                                progress == 1.0
                                    ? Colors.green
                                    : AppConstants.primaryColor,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(
                          height: 40,
                        ), // Chừa chỗ cho Title của SliverAppBar
                      ],
                    ),
                  ),
                ),
              ),

              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      TextField(
                        onChanged: (v) => setState(() => _searchQuery = v),
                        decoration: InputDecoration(
                          hintText: 'topic.search_words'.tr(),
                          prefixIcon: const Icon(Icons.search),
                          filled: true,
                          fillColor: Theme.of(context).cardColor,
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(15),
                            borderSide: BorderSide.none,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => StudyScreen(topic: widget.topic),
                          ),
                        ),
                        icon: const Icon(Icons.style),
                        label: Text('topic.study'.tr()),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: AppConstants.primaryColor,
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton.icon(
                        onPressed: () {
                          final wordsInTopic = WordService().getWordsByTopic(
                            widget.topic,
                          );

                          // Safety Check: Hiện tại UI cần 4 đáp án (1 đúng, 3 sai)
                          // Nên nếu lúc bạn đang test mà chủ đề mới nhập có 2-3 từ thì phải chặn lại để khỏi crash app
                          if (wordsInTopic.length < 4) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(
                                content: Text(
                                  'topic.not_enough_words'.tr(
                                    args: [wordsInTopic.length.toString()],
                                  ),
                                  style: const TextStyle(color: Colors.white),
                                ),
                                backgroundColor: Colors.orange,
                              ),
                            );
                            return;
                          }

                          // Tương lai: Chỗ này bạn có thể gọi showDialog để hỏi người dùng muốn test 10, 20 hay 50 câu.
                          // Tạm thời bây giờ ta truyền thẳng vào QuizScreen
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => QuizScreen(
                                targetWords: wordsInTopic,
                                distractorPool:
                                    wordsInTopic, // Dùng chính danh sách này làm đáp án nhiễu
                                questionCount: 10, // Tạm fix cứng 10 câu
                                mode: QuizMode.enToVi, // Tạm fix cứng chế độ EN->VI
                              ),
                            ),
                          );
                        },
                        icon: const Icon(Icons.quiz_rounded),
                        label: Text('topic.take_quiz'.tr()),
                        style: ElevatedButton.styleFrom(
                          minimumSize: const Size(double.infinity, 55),
                          backgroundColor: Colors
                              .orange
                              .shade600, // Đổi sang màu Cam để dễ phân biệt
                          foregroundColor: Colors.white,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(15),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              SliverList(
                delegate: SliverChildBuilderDelegate((context, index) {
                  final word = filteredWords[index];

                  // Lấy trạng thái từ Service
                  final bool isLearned = _wordService.isWordLearned(word.id);

                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: 24,
                      vertical: 4,
                    ),
                    leading: Icon(
                      isLearned ? Icons.check_circle : Icons.circle_outlined,
                      color: isLearned ? Colors.green : Colors.grey.shade400,
                      size: 28,
                    ),
                    title: Text(
                      word.word,
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    subtitle: Text(
                      word.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    trailing: const Icon(
                      Icons.chevron_right,
                      color: Colors.grey,
                    ),
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => WordDetailScreen(word: word),
                      ),
                    ),
                  );
                }, childCount: filteredWords.length),
              ),
              const SliverToBoxAdapter(
                child: SizedBox(height: 40),
              ), // Khoảng trống dưới cùng
            ],
          ),
        );
      },
    );
  }
}
