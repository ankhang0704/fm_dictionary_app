// file: lib/screens/home/main_navigation.dart
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import '../../widgets/layout/custom_sidebar.dart';
import '../../widgets/layout/right_sidebar.dart';
import '../../core/constants/constants.dart';
import 'dashboard_screen.dart';
import '../library/library_screen.dart';
import '../learning/review_screen.dart';

class MainNavigation extends StatefulWidget {
  const MainNavigation({super.key});

  @override
  State<MainNavigation> createState() => _MainNavigationState();
}

class _MainNavigationState extends State<MainNavigation> {
  int _currentIndex = 0;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  late final List<Widget> _screens;

  @override
  void initState() {
    super.initState();
    _screens = const [
      DashboardScreen(),
      LibraryScreen(),
      ReviewScreen(),
    ];
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: isDark ? AppConstants.darkBgColor : AppConstants.backgroundColor,
      drawer: const CustomSideBar(),
      endDrawer: const RightSideBar(),
      appBar: AppBar(
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(
            CupertinoIcons.bars,
            color: isDark ? Colors.white : AppConstants.textPrimary,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: IconButton(
              icon: Icon(
                CupertinoIcons.calendar,
                color: isDark ? Colors.white : AppConstants.textPrimary,
              ),
              onPressed: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _screens,
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: isDark ? AppConstants.darkCardColor : AppConstants.cardColor,
          boxShadow: isDark ? [] : [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.04),
              blurRadius: 15,
              offset: const Offset(0, -4),
            ),
          ],
        ),
        child: SafeArea(
          child: BottomNavigationBar(
            currentIndex: _currentIndex,
            onTap: (index) => setState(() => _currentIndex = index),
            type: BottomNavigationBarType.fixed,
            backgroundColor: Colors.transparent,
            elevation: 0,
            selectedItemColor: AppConstants.accentColor,
            unselectedItemColor: isDark ? Colors.grey[600] : AppConstants.textLight,
            selectedLabelStyle: AppConstants.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: AppConstants.bodyStyle.copyWith(
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            items: [
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(CupertinoIcons.house_fill),
                ),
                label: 'navigation.nav_home'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(CupertinoIcons.book_fill),
                ),
                label: 'navigation.nav_categories'.tr(),
              ),
              BottomNavigationBarItem(
                icon: const Padding(
                  padding: EdgeInsets.only(bottom: 4),
                  child: Icon(CupertinoIcons.arrow_2_squarepath),
                ),
                label: 'navigation.nav_review'.tr(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}