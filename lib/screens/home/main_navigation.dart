import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import '../../core/utils/constants.dart';
import 'dashboard_screen.dart';
import '../library/library_screen.dart';
import '../learning/review_screen.dart';
import '../settings/settings_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const ReviewScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).scaffoldBackgroundColor,
          boxShadow: [
            BoxShadow(
              color: isDark ? Colors.black26 : Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -5),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) {
            setState(() {
              _currentIndex = index;
            });
          },
          type: BottomNavigationBarType.fixed,
          backgroundColor: Theme.of(context).cardColor,
          selectedItemColor: isDark ? Colors.white : AppConstants.primaryColor,
          unselectedItemColor: isDark ? Colors.grey[500] : Colors.grey[400],
          showSelectedLabels: true,
          showUnselectedLabels: true,
          elevation: 0,
          items:  [
            BottomNavigationBarItem(
              icon: Icon(Icons.home_rounded),
              label: 'navigation.nav_home'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.library_books_rounded),
              label: 'navigation.nav_categories'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.refresh_rounded),
              label: 'navigation.nav_review'.tr(),
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'navigation.nav_settings'.tr(),
            ),
          ],
        ),
      ),
    );
  }
}
