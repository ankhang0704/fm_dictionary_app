import 'package:flutter/material.dart';
import 'screens/dashboard_screen.dart';
import 'screens/library_screen.dart';
import 'screens/review_screen.dart';
import 'screens/settings_screen.dart';
import 'services/database_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Database (Hive + Import dữ liệu)
  await DatabaseService.init();
  
  runApp(const EnglishMasterApp());
}

class EnglishMasterApp extends StatefulWidget {
  const EnglishMasterApp({super.key});

  @override
  State<EnglishMasterApp> createState() => _EnglishMasterAppState();
}

class _EnglishMasterAppState extends State<EnglishMasterApp> {
  int _selectedIndex = 0;

  // Danh sách các màn hình tương ứng với Menu
  final List<Widget> _screens = [
    const DashboardScreen(),
    const LibraryScreen(),
    const ReviewScreen(),
    const SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        fontFamily: 'Inter',
        scaffoldBackgroundColor: const Color(0xFFFDFCF9),
      ),
      home: Scaffold(
        body: IndexedStack(
          // Giữ trạng thái của các màn hình khi chuyển tab
          index: _selectedIndex,
          children: _screens,
        ),
        bottomNavigationBar: BottomNavigationBar(
          currentIndex: _selectedIndex,
          onTap: (index) => setState(() => _selectedIndex = index),
          type: BottomNavigationBarType.fixed,
          backgroundColor: Colors.white,
          selectedItemColor: const Color(0xFF1A1A1A),
          unselectedItemColor: Colors.grey.shade400,
          showSelectedLabels: true,
          showUnselectedLabels: true,
          selectedLabelStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
          ),
          unselectedLabelStyle: const TextStyle(fontSize: 10),
          items: const [
            BottomNavigationBarItem(
              icon: Icon(Icons.dashboard_rounded),
              label: 'HOME',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.auto_stories_rounded),
              label: 'LIBRARY',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.history_rounded),
              label: 'REVIEW',
            ),
            BottomNavigationBarItem(
              icon: Icon(Icons.settings_rounded),
              label: 'SETTINGS',
            ),
          ],
        ),
      ),
    );
  }
}
