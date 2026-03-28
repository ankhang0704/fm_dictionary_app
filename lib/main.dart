import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/utils/loading.dart';
import 'package:fm_dictionary/services/voice_service.dart';
import 'services/database_service.dart';
import 'services/tts_service.dart';
import 'services/theme_manager.dart';
import 'screens/home/main_navigation.dart';
import 'screens/welcome/welcome_screen.dart';
import 'core/utils/constants.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await EasyLocalization.ensureInitialized();
  // 1. Khởi tạo Hive & Data
  await DatabaseService.init();
  // 2. Khởi tạo TTS
  await TtsService().init();

  await VoiceService.instance.initModel();
  
  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations', // Đường dẫn tới file JSON
      fallbackLocale: const Locale('en'),
      child: const MyApp(),
    ),
  );
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
          // --- GIỮ NGUYÊN PHẦN LOCALIZATION ---
          localizationsDelegates: context.localizationDelegates,
          supportedLocales: context.supportedLocales,
          locale: context.locale,
          title: AppConstants.appName,
          debugShowCheckedModeBanner: false,
          themeMode: currentMode,

          // --- GIỮ NGUYÊN THEME DATA ---
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

          // --- PHẦN QUAN TRỌNG: TÍCH HỢP LOADING TẠI ĐÂY ---
          builder: (context, child) {
            return Stack(
              children: [
                child!, // Đây là màn hình App của bạn
                ValueListenableBuilder<bool>(
                  valueListenable: LoadingManager.isLoading,
                  builder: (context, loading, _) {
                    if (!loading) return const SizedBox.shrink();

                    return Container(
                      color: Colors
                          .black45, // Làm tối màn hình (màu này đẹp hơn black26)
                      child: const Center(
                        child: CircularProgressIndicator(
                          color: AppConstants.primaryColor, // Đồng bộ màu sắc
                        ),
                      ),
                    );
                  },
                ),
              ],
            );
          },

          home: settings.isFirstRun
              ? const WelcomeScreen()
              : const MainNavigation(),
        );
      },
    );
  }
}
