// lib/features/home/presentation/screens/main_navigation.dart
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:fm_dictionary/features/learning/review_screen.dart';
import 'package:fm_dictionary/features/library/library_screen.dart';
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
    LibraryScreen(),
    ReviewScreen(),
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
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.book_fill), label: "Library"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.repeat), label: "Review"),
          BottomNavigationBarItem(icon: Icon(CupertinoIcons.bars), label: "Menu"), // Nút Menu mới
        ],
      ),
    );
  }
}