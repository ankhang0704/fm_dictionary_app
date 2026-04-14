// lib/features/saved/presentation/screens/saved_words_screen.dart
import 'package:flutter/material.dart';

class SavedWordsScreen extends StatelessWidget {
  const SavedWordsScreen({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Saved Words")),
      body: const Center(child: Text("SKELETON: List of words you bookmarked")),
    );
  }
}