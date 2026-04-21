// lib/features/home/presentation/screens/main_navigation.dart

import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/home/presentation/screens/detail_statistical_screen.dart';
import 'package:fm_dictionary/features/home/presentation/screens/menu_screen.dart';
import 'package:fm_dictionary/features/library/presentation/screens/dictionary_screen.dart';
import 'package:fm_dictionary/features/roadmap/presentation/screen/roadmap_screen.dart';
import 'dashboard_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  final List<Widget> _screens = const [
    DashboardScreen(),
    RoadmapScreen(),
    DictionaryScreen(),
    DetailStatisticalScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    // Dynamic theme colors
    final backgroundColor = Theme.of(context).colorScheme.surface;
    final selectedColor = Theme.of(context).colorScheme.primary;
    final unselectedColor = Theme.of(
      context,
    ).textTheme.bodySmall?.color?.withValues(alpha: 0.6);

    return Scaffold(
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: backgroundColor,
          border: Border(
            top: BorderSide(
              color: Theme.of(context).dividerColor.withValues(alpha: 0.1),
              width: 1,
            ),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.05),
              blurRadius: 10,
              offset: const Offset(0, -2),
            ),
          ],
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (index) => setState(() => _currentIndex = index),
          backgroundColor: Colors.transparent,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedItemColor: selectedColor,
          unselectedItemColor: unselectedColor,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.bold,
            fontSize: 12,
          ),
          unselectedLabelStyle: Theme.of(context).textTheme.bodySmall?.copyWith(
            fontWeight: FontWeight.w600,
            fontSize: 11,
          ),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.house_fill),
              label: "Home",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.map_fill),
              label: "Roadmap",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.book_fill),
              label: "Dictionary",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.chart_bar_fill),
              label: "Stats",
            ),
            BottomNavigationBarItem(
              icon: Icon(CupertinoIcons.person_fill),
              label: "Profile",
            ),
          ],
        ),
      ),
    );
  }
}
