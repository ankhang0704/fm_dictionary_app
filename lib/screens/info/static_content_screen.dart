// file: lib/screens/info/static_content_screen.dart
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import '../../core/constants/constants.dart';

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
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      appBar: AppBar(
        title: Text(
          titleKey.tr(),
          style: AppConstants.headingStyle.copyWith(
            fontSize: 20,
            fontStyle: FontStyle.normal,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: IconThemeData(
          color: isDark ? Colors.white : AppConstants.textPrimary,
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          padding: const EdgeInsets.all(AppConstants.defaultPadding),
          child: Container(
            padding: const EdgeInsets.all(AppConstants.defaultPadding),
            decoration: BoxDecoration(
              color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
              borderRadius: BorderRadius.circular(AppConstants.cardRadius / 1.5),
              boxShadow: isDark
                  ? []
                  : [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.03),
                        blurRadius: 10,
                        offset: const Offset(0, 4),
                      ),
                    ],
            ),
            child: Text(
              contentKey.tr(),
              style: AppConstants.bodyStyle.copyWith(
                fontSize: 16,
                height: 1.6,
                letterSpacing: 0.3,
                color: isDark ? Colors.white70 : AppConstants.textPrimary,
              ),
            ),
          ),
        ),
      ),
    );
  }
}