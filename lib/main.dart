import 'package:flutter/material.dart';
import 'services/database_service.dart';
import 'services/tts_service.dart';
import 'services/theme_manager.dart';
import 'screens/home/main_navigation.dart';
import 'screens/welcome/welcome_screen.dart';
import 'utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Khởi tạo Hive & Data
  await DatabaseService.init();
  
  // 2. Khởi tạo TTS
  await TtsService().init();
  
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final settings = DatabaseService.getSettings();
    
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: ThemeManager.themeNotifier,
      builder: (_, ThemeMode currentMode, _) {
        return MaterialApp(
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,
          
          // Light Theme
          theme: ThemeData(
            useMaterial3: true,
            primaryColor: AppConstants.primaryColor,
            scaffoldBackgroundColor: AppConstants.backgroundColor,
            brightness: Brightness.light,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.primaryColor,
              primary: AppConstants.primaryColor,
            ),
          ),
          
          // Dark Theme
          darkTheme: ThemeData(
            useMaterial3: true,
            brightness: Brightness.dark,
            scaffoldBackgroundColor: AppConstants.darkBgColor,
            cardColor: AppConstants.darkCardColor,
            fontFamily: 'Inter',
            colorScheme: ColorScheme.fromSeed(
              seedColor: AppConstants.primaryColor,
              brightness: Brightness.dark,
              surface: AppConstants.darkCardColor,
            ),
          ),
          
          home: settings.isFirstRun ? const WelcomeScreen() : const MainNavigation(),
        );
      },
    );
  }
}
