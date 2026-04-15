// lib/features/home/presentation/screens/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/home/presentation/screens/detail_statistical_screen.dart';
import 'package:fm_dictionary/features/library/presentation/screens/dictionary_screen.dart';
import 'package:fm_dictionary/features/roadmap/presentation/screen/roadmap_screen.dart';
import 'dashboard_screen.dart';
import 'menu_screen.dart'; // Tab mới


class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});
  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  
  final _screens = const [
    DashboardScreen(),
    RoadmapScreen(),
    DictionaryScreen(),
    DetailStatisticalScreen(), // Tab Review giờ là DetailStatisticalScreen
    MenuScreen(), // Tab thứ 4 thay cho Sidebar
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.house_fill), label: "Home"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_fill), label: "Roadmap"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book), label: "Dictionary"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.repeat), label: "Stats"), // Tab Review giờ là Stats
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bars), label: "Menu"), // Nút Menu mới
        ],
      ),
    );
  }
}