import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database_service.dart';
import '../../services/tts_service.dart';
import 'word_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TtsService _ttsService = TtsService();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 0, // Giúp TextField không bị ép lề gây overflow
        title: Hero(
          tag: 'search_hero',
          child: Material(
            color: Colors.transparent,
            child: Padding(
              padding: const EdgeInsets.only(right: 16.0),
              child: TextField(
                controller: _controller,
                autofocus: true,
                onChanged: _onSearch,
                decoration: const InputDecoration(
                  hintText: 'Search 1,500 words...',
                  border: InputBorder.none,
                ),
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Word>>(
        valueListenable: _searchResults,
        builder: (context, results, _) {
          if (_controller.text.isEmpty) return _buildInfo("Nhập từ để tìm kiếm...");
          if (results.isEmpty) return _buildInfo("Không tìm thấy từ này.");

          return ListView.builder(
            itemCount: results.length,
            itemBuilder: (context, index) {
              final word = results[index];
              return ListTile(
                // CHỐNG TRÀN CHỮ Ở ĐÂY
                title: Text(
                  word.word, 
                  style: const TextStyle(fontWeight: FontWeight.bold),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                subtitle: Text(
                  word.meaning,
                  maxLines: 2, // Giới hạn nghĩa dài tối đa 2 dòng
                  overflow: TextOverflow.ellipsis,
                ),
                trailing: IconButton(
                  icon: const Icon(Icons.volume_up, color: Colors.blue),
                  onPressed: () => _ttsService.speak(word.word),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => WordDetailScreen(word: word)),
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
}