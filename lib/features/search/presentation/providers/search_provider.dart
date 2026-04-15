import 'package:flutter/material.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../data/models/word_model.dart';
import '../../../../data/services/database/database_service.dart';

class SearchProvider extends ChangeNotifier {
  final Box<Word> _wordBox = Hive.box<Word>(DatabaseService.wordBoxName);
  final Box<String> _historyBox = Hive.box<String>('searchHistoryBox');

  List<Word> _searchResults = [];
  List<String> _history = [];
  String _currentQuery = "";

  List<Word> get searchResults => _searchResults;
  List<String> get history => _history;
  String get currentQuery => _currentQuery;

  SearchProvider() {
    _loadHistory();
  }

  void _loadHistory() {
    _history = _historyBox.values.toList().reversed.toList();
    notifyListeners();
  }

  void search(String query) {
    _currentQuery = query;
    if (query.isEmpty) {
      _searchResults = [];
    } else {
      final lowercaseQuery = query.toLowerCase();
      // Nếu có 1500+ từ, tương lai có thể bọc trong Isolate/compute
      _searchResults = _wordBox.values.where((word) {
        return word.word.toLowerCase().contains(lowercaseQuery) ||
               word.meaning.toLowerCase().contains(lowercaseQuery);
      }).toList();
    }
    notifyListeners();
  }

  void saveToHistory(String word) {
    if (_historyBox.values.contains(word)) {
      final keyToDelete = _historyBox.keys.firstWhere((k) => _historyBox.get(k) == word);
      _historyBox.delete(keyToDelete);
    }
    _historyBox.add(word);

    if (_historyBox.length > 10) {
      _historyBox.delete(_historyBox.keys.first);
    }
    _loadHistory();
  }

  void clearHistory() {
    _historyBox.clear();
    _loadHistory();
  }

  void clearSearch() {
    _currentQuery = "";
    _searchResults = [];
    notifyListeners();
  }
}