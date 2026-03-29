import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';

class StaticContentScreen extends StatelessWidget {
  final String titleKey;
  final String contentKey;

  const StaticContentScreen({super.key, required this.titleKey, required this.contentKey});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(titleKey.tr())),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20.0),
        child: Text(
          contentKey.tr(), 
          style: TextStyle(fontSize: 16, height: 1.5, color: Theme.of(context).textTheme.bodyLarge?.color),
        ),
      ),
    );
  }
}