// file: lib/screens/search/search_screen.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:hive_flutter/hive_flutter.dart';
import '../../models/word_model.dart';
import '../../services/database/database_service.dart';
import '../../core/constants/constants.dart';
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

  @override
  void dispose() {
    _controller.dispose();
    _searchResults.dispose();
    super.dispose();
  }

  void _onSearch(String query) {
    if (query.isEmpty) {
      _searchResults.value = [];
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

    if (history.contains(word)) {
      final keyToDelete = box.keys.firstWhere((k) => box.get(k) == word);
      box.delete(keyToDelete);
    }
    box.add(word);

    if (box.length > 10) {
      box.delete(box.keys.first);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark
          ? AppConstants.darkBgColor
          : AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: isDark
            ? AppConstants.darkBgColor
            : AppConstants.cardColor,
        elevation: 0,
        titleSpacing: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.back,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          onPressed: () => Navigator.pop(context),
        ),
        title: Padding(
          padding: const EdgeInsets.only(right: 16.0),
          child: Container(
            height: 40,
            decoration: BoxDecoration(
              color: isDark
                  ? AppConstants.darkCardColor
                  : Colors.grey.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppConstants.inputRadius),
            ),
            child: TextField(
              controller: _controller,
              autofocus: true,
              onChanged: _onSearch,
              style: AppConstants.bodyStyle.copyWith(
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
              decoration: InputDecoration(
                hintText: 'search.search_placeholder'.tr(),
                hintStyle: TextStyle(color: AppConstants.textSecondary),
                prefixIcon: Icon(
                  CupertinoIcons.search,
                  size: 20,
                  color: AppConstants.textSecondary,
                ),
                suffixIcon: ValueListenableBuilder<TextEditingValue>(
                  valueListenable: _controller,
                  builder: (context, value, child) {
                    return value.text.isNotEmpty
                        ? IconButton(
                            icon: Icon(
                              CupertinoIcons.clear_thick_circled,
                              size: 18,
                              color: AppConstants.textLight,
                            ),
                            onPressed: () {
                              _controller.clear();
                              _onSearch('');
                            },
                          )
                        : const SizedBox.shrink();
                  },
                ),
                border: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 10),
              ),
            ),
          ),
        ),
      ),
      body: ValueListenableBuilder<List<Word>>(
        valueListenable: _searchResults,
        builder: (context, results, _) {
          if (_controller.text.isEmpty) return _buildHistory(isDark);

          if (results.isEmpty) {
            return _buildInfo(
              'search.no_results'.tr(args: [_controller.text]),
              isDark,
            );
          }

          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            itemCount: results.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final word = results[index];
              return Container(
                decoration: BoxDecoration(
                  color: isDark
                      ? AppConstants.darkCardColor
                      : AppConstants.cardColor,
                  borderRadius: BorderRadius.circular(AppConstants.inputRadius),
                  border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
                  boxShadow: isDark
                      ? []
                      : [
                          BoxShadow(
                            color: Colors.black.withValues(alpha: 0.02),
                            blurRadius: 5,
                            offset: const Offset(0, 2),
                          ),
                        ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 4,
                  ),
                  title: Text(
                    word.word,
                    style: AppConstants.bodyStyle.copyWith(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isDark ? Colors.white : AppConstants.textPrimary,
                    ),
                  ),
                  subtitle: Padding(
                    padding: const EdgeInsets.only(top: 4),
                    child: Text(
                      word.meaning,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: AppConstants.bodyStyle.copyWith(
                        fontSize: 14,
                        color: AppConstants.textSecondary,
                      ),
                    ),
                  ),
                  trailing: Icon(
                    CupertinoIcons.chevron_right,
                    color: AppConstants.textLight,
                    size: 18,
                  ),
                  onTap: () {
                    FocusScope.of(context).unfocus();
                    _saveToHistory(word.word);
                    Navigator.push(
                      context,
                      CupertinoPageRoute(
                        builder: (_) => WordDetailScreen(word: word),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfo(String text, bool isDark) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(CupertinoIcons.search, size: 48, color: AppConstants.textLight),
          const SizedBox(height: 16),
          Text(
            text,
            style: AppConstants.bodyStyle.copyWith(
              color: AppConstants.textSecondary,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Widget _buildHistory(bool isDark) {
    return ValueListenableBuilder(
      valueListenable: Hive.box<String>('searchHistoryBox').listenable(),
      builder: (context, box, _) {
        final history = box.values.toList().reversed.toList();

        if (history.isEmpty) {
          return Center(
            child: Text(
              'search.no_history'.tr(), // Hoặc dùng translation key
              style: AppConstants.bodyStyle.copyWith(
                color: AppConstants.textSecondary,
              ),
            ),
          );
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(
                AppConstants.defaultPadding,
                16,
                AppConstants.defaultPadding,
                8,
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'search.history'.tr(),
                    style: AppConstants.subHeadingStyle,
                  ),
                  if (history.isNotEmpty)
                    GestureDetector(
                      onTap: () => box.clear(),
                      child: Text(
                        'search.clear_history'.tr(), // Thay bằng key dịch nếu có
                        style: AppConstants.bodyStyle.copyWith(
                          color: AppConstants.errorColor,
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                physics: const BouncingScrollPhysics(),
                itemCount: history.length,
                separatorBuilder: (_, _) => Divider(
                  height: 1,
                  indent: 56,
                  color: Colors.grey.withValues(alpha: 0.1),
                ),
                itemBuilder: (context, index) {
                  return ListTile(
                    contentPadding: const EdgeInsets.symmetric(
                      horizontal: AppConstants.defaultPadding,
                    ),
                    leading: Icon(
                      CupertinoIcons.clock,
                      color: AppConstants.textLight,
                      size: 20,
                    ),
                    title: Text(
                      history[index],
                      style: AppConstants.bodyStyle.copyWith(
                        color: isDark ? Colors.white : AppConstants.textPrimary,
                        fontSize: 15,
                      ),
                    ),
                    trailing: IconButton(
                      icon: Icon(
                        CupertinoIcons.arrow_up_left,
                        color: AppConstants.textLight,
                        size: 18,
                      ),
                      onPressed: () {
                        _controller.text = history[index];
                        _onSearch(history[index]);
                      },
                    ),
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
      },
    );
  }
}
