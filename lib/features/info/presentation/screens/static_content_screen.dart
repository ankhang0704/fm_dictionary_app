// Đường dẫn: lib/features/info/presentation/screens/static_content_screen.dart

import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; // Bắt buộc để load file asset
import 'package:flutter_markdown/flutter_markdown.dart';

class StaticContentScreen extends StatelessWidget {
  final String title;
  final String mdFileName; // Ví dụ: 'privacy_en.md'

  const StaticContentScreen({
    super.key,
    required this.title,
    required this.mdFileName,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(title: Text(title), centerTitle: true),
      body: FutureBuilder(
        // Đọc nội dung file từ assets
        future: rootBundle.loadString('assets/docs/$mdFileName'),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !snapshot.hasData) {
            return const Center(child: Text("Document not found."));
          }

          return SafeArea(
            child: Container(
              margin: const EdgeInsets.all(16),
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Markdown(
                data: snapshot.data!,
                selectable: true, // Cho phép người dùng copy text tài liệu
                styleSheet: MarkdownStyleSheet(
                  h1: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                  h3: TextStyle(fontSize: 18, color: Colors.blue.shade700, fontWeight: FontWeight.w600),
                  p: const TextStyle(fontSize: 15, height: 1.5),
                  listBullet: const TextStyle(fontSize: 15),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}