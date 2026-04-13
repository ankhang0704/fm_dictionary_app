// Đường dẫn: lib/features/info/presentation/screens/static_content_screen.dart

import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class StaticContentScreen extends StatelessWidget {
  final String titleKey;
  final String contentKey;

  const StaticContentScreen({
    super.key,
    required this.titleKey,
    required this.contentKey,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? Colors.grey[900] : Colors.grey[100],
      appBar: AppBar(
        title: Text(titleKey.tr()),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          physics: const BouncingScrollPhysics(),
          child: Container(
            // SKELETON LAYOUT BENTO: Một khối Paper đọc văn bản
            width: double.infinity,
            padding: const EdgeInsets.all(24.0),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(24),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: Text(
              contentKey.tr(),
              style: TextStyle(
                fontSize: 16,
                height: 1.6, // Khoảng cách dòng chuẩn để đọc Text dài
                color: isDark ? Colors.white70 : Colors.black87,
              ),
            ),
          ),
        ),
      ),
    );
  }
}
