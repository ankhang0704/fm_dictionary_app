// lib/features/home/presentation/screens/main_navigation.dart

import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/home/presentation/screens/detail_statistical_screen.dart';
import 'package:fm_dictionary/features/home/presentation/screens/menu_screen.dart';
import 'package:fm_dictionary/features/library/presentation/screens/dictionary_screen.dart';
import 'package:fm_dictionary/features/roadmap/presentation/screen/roadmap_screen.dart';
import 'dashboard_screen.dart';

// import 'package:fm_dictionary/features/roadmap/presentation/screen/roadmap_screen.dart';
// import 'package:fm_dictionary/features/library/presentation/screens/dictionary_screen.dart';
// import 'package:fm_dictionary/features/home/presentation/screens/detail_statistical_screen.dart';
// import 'package:fm_dictionary/features/profile/presentation/screens/profile_screen.dart';
// import 'package:fm_dictionary/core/constants/app_constants.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;

  // Pre-initialize screens. Use placeholders for non-dashboard screens.
  final List<Widget> _screens = const [
    DashboardScreen(),
    RoadmapScreen(),
    DictionaryScreen(),
    DetailStatisticalScreen(),
    MenuScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // CRITICAL: extendBody allows the screen content (mesh gradient) to flow underneath the transparent bottom bar
      extendBody: true,
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: ClipRRect(
        child: BackdropFilter(
          // Glassmorphism blur effect
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Container(
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha:  0.25),
              border: Border(
                top: BorderSide(color: Colors.white.withValues(alpha: 0.5), width: 1),
              ),
            ),
            child: BottomNavigationBar(
              currentIndex: _currentIndex,
              onTap: (index) => setState(() => _currentIndex = index),
              backgroundColor:
                  Colors.transparent, // Ensures glass effect shows through
              elevation: 0,
              type: BottomNavigationBarType.fixed,
              selectedItemColor: const Color(
                0xFF9013FE,
              ), // Vibrant Purple (or AppColors.vibrantPurple)
              unselectedItemColor: const Color(
                0xFF64748B,
              ), // Slate 500 (or AppColors.slate500)
              showSelectedLabels: true,
              showUnselectedLabels: true,
              selectedLabelStyle: const TextStyle(
                fontFamily: 'Quicksand',
                fontWeight: FontWeight.bold,
                fontSize: 12,
              ),
              unselectedLabelStyle: const TextStyle(
                fontFamily: 'Quicksand',
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
        ),
      ),
    );
  }
}
