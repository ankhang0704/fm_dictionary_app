import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database/database_service.dart';
import 'word_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final ValueNotifier<List<Word>> _searchResults = ValueNotifier([]);
  late Box<Word> _wordBox;

  @override
  void initState() {
    super.initState();
    _wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _searchResults.value =[];
      return;
    }
    final lowercaseQuery = query.toLowerCase();
    _searchResults.value = _wordBox.values.where((word) {
      return word.word.toLowerCase().contains(lowercaseQuery) || 
             word.meaning.toLowerCase().contains(lowercaseQuery);
    }).toList();
  }
  void _saveToHistory(String word) {
    final box = Hive.box<String>('searchHistoryBox');
    final history = box.values.toList();
    // Xóa nếu đã tồn tại để đưa lên đầu
    if (history.contains(word)) {
      final keyToDelete = box.keys.firstWhere((k) => box.get(k) == word);
      box.delete(keyToDelete);
    }
    box.add(word);
    // Chỉ giữ lại 10 từ gần nhất cho nhẹ
    if (box.length > 10) {
      box.delete(box.keys.first);
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0,
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: TextField(
            controller: _controller,
            autofocus: true,
            onChanged: _onSearch,
            decoration:  InputDecoration(
              hintText: 'search.search_placeholder'.tr(),
              border: InputBorder.none,
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Word>>(
        valueListenable: _searchResults,
        builder: (context, results, _) {
          // NẾU CHƯA GÕ GÌ -> HIỆN LỊCH SỬ
          if (_controller.text.isEmpty) return _buildHistory();

          if (results.isEmpty) return _buildInfo('search.no_results'.tr(args: [_controller.text]));

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final word = results[index];
              return ListTile(
                title: Text(
                  word.word,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                subtitle: Text(
                  word.meaning,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                onTap: () {
                  FocusScope.of(context).unfocus();
                  _saveToHistory(word.word); // LƯU VÀO LỊCH SỬ KHI BẤM XEM
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => WordDetailScreen(word: word),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfo(String text) {
    return Center(child: Text(text, style: const TextStyle(color: Colors.grey)));
  }
  // Hàm render phần Lịch sử
  Widget _buildHistory() {
    final box = Hive.box<String>('searchHistoryBox');
    final history = box.values
        .toList()
        .reversed
        .toList(); // Đảo ngược để hiện từ mới nhất

    if (history.isEmpty) return _buildInfo('search.no_results'.tr(args: ['']));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
         Padding(
          padding: EdgeInsets.all(16.0),
          child: Text(
            'search.history'.tr(),
            style: TextStyle(fontWeight: FontWeight.bold, color: Colors.grey),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: history.length,
            itemBuilder: (context, index) {
              return ListTile(
                leading: const Icon(Icons.history, color: Colors.grey),
                title: Text(history[index]),
                onTap: () {
                  _controller.text = history[index];
                  _onSearch(history[index]);
                },
              );
            },
          ),
        ),
      ],
    );
  }
}