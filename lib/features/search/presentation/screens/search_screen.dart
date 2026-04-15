// file: lib/features/search/search_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/search/presentation/providers/search_provider.dart';
import 'package:provider/provider.dart';
import '../../../../core/constants/constants.dart';
import 'word_detail_screen.dart';

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(CupertinoIcons.back, color: isDark ? Colors.white : AppConstants.textPrimary),
          onPressed: () => Navigator.pop(context),
        ),
        title: _buildSearchBar(context, isDark),
      ),
      body: Consumer<SearchProvider>(
        builder: (context, provider, _) {
          if (provider.currentQuery.isEmpty) return _buildHistory(provider, isDark);
          if (provider.searchResults.isEmpty) return _buildEmptyInfo(isDark);
          
          return ListView.separated(
            physics: const BouncingScrollPhysics(),
            padding: const EdgeInsets.all(20),
            itemCount: provider.searchResults.length,
            separatorBuilder: (_, _) => const SizedBox(height: 12),
            itemBuilder: (context, index) {
              final word = provider.searchResults[index];
              return _buildWordTile(word, provider, context, isDark);
            },
          );
        },
      ),
    );
  }

  Widget _buildSearchBar(BuildContext context, bool isDark) {
    return Container(
      height: 44,
      margin: const EdgeInsets.only(right: 16),
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : Colors.grey.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
      ),
      child: TextField(
        controller: _controller,
        autofocus: true,
        onChanged: context.read<SearchProvider>().search,
        style: TextStyle(color: isDark ? Colors.white : AppConstants.textPrimary),
        decoration: InputDecoration(
          hintText: 'Tìm kiếm từ vựng...',
          prefixIcon: const Icon(CupertinoIcons.search, size: 20, color: Colors.grey),
          suffixIcon: _controller.text.isNotEmpty
              ? IconButton(
                  icon: const Icon(CupertinoIcons.clear_thick_circled, size: 18, color: Colors.grey),
                  onPressed: () {
                    _controller.clear();
                    context.read<SearchProvider>().clearSearch();
                  },
                )
              : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(vertical: 12),
        ),
      ),
    );
  }

  Widget _buildWordTile(word, SearchProvider provider, BuildContext context, bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.withValues(alpha: 0.1)),
      ),
      child: ListTile(
        contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
        title: Text(word.word, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        subtitle: Text(word.meaning, maxLines: 1, overflow: TextOverflow.ellipsis),
        trailing: const Icon(CupertinoIcons.chevron_right, color: Colors.grey, size: 18),
        onTap: () {
          FocusScope.of(context).unfocus();
          provider.saveToHistory(word.word);
          Navigator.push(context, CupertinoPageRoute(builder: (_) => WordDetailScreen(word: word)));
        },
      ),
    );
  }

  Widget _buildHistory(SearchProvider provider, bool isDark) {
    if (provider.history.isEmpty) return const Center(child: Text("Chưa có lịch sử tìm kiếm", style: TextStyle(color: Colors.grey)));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Lịch sử', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
              GestureDetector(
                onTap: provider.clearHistory,
                child: const Text('Xóa', style: TextStyle(color: AppConstants.errorColor, fontWeight: FontWeight.bold)),
              ),
            ],
          ),
        ),
        Expanded(
          child: ListView.builder(
            physics: const BouncingScrollPhysics(),
            itemCount: provider.history.length,
            itemBuilder: (context, index) {
              final term = provider.history[index];
              return ListTile(
                leading: const Icon(CupertinoIcons.clock, color: Colors.grey, size: 20),
                title: Text(term),
                onTap: () {
                  _controller.text = term;
                  provider.search(term);
                },
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildEmptyInfo(bool isDark) => const Center(child: Text("Không tìm thấy kết quả", style: TextStyle(color: Colors.grey)));
}