import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/utils/loading.dart';
import 'package:fm_dictionary/data/services/auth/auth_sync_service.dart';
import 'package:fm_dictionary/data/services/ai_speech/ai_assistant/ai_assistant_service.dart';
import 'package:fm_dictionary/data/services/notify/notification_service.dart';
import 'package:provider/provider.dart';
import 'data/services/database/database_service.dart';
import 'data/services/ai_speech/text_to_speech/speech_service.dart';
import 'data/services/ui_management/theme_manager.dart';
import 'features/home/main_navigation.dart';
import 'features/welcome/welcome_screen.dart';
import 'core/constants/constants.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:timezone/data/latest.dart' as tz; // Quan trọng: import cái này
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/learning/presentation/providers/learning_provider.dart';
import 'features/settings/presentation/providers/notification_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start Firebase initialization before anything else
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  tz.initializeTimeZones();
   try {
    final TimezoneInfo timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName = timezoneInfo.identifier; // Dùng .identifier nhé!
    
    tz.setLocalLocation(tz.getLocation(timeZoneName));
    debugPrint('✅ Đã cấu hình Timezone: $timeZoneName');
  } catch (e) {
    debugPrint('❌ Lỗi Timezone: $e');
  }
  
  await EasyLocalization.ensureInitialized();
  // 1. Khởi tạo Hive & Data
  await DatabaseService.init();
  // 2. Khởi tạo TTS
  await TtsService().init();
  // 3. Khởi tạo Model Whisper (Bắt buộc phải khởi tạo trước AuthSync để tránh lỗi khi vào StudyScreen)
  await AiAssistantService.instance.initModel();
  // 4. Khởi tạo AuthSyncService (Lắng nghe Auth và đồng bộ dữ liệu)
  await AuthSyncService.instance.init(); 
  await NotificationService.instance.init();
   runApp(
    // 1. Bọc ngoài cùng là MultiProvider để quản lý State toàn ứng dụng
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
      ],
      // 2. Tiếp theo là EasyLocalization để xử lý đa ngôn ngữ
      child: EasyLocalization(
        supportedLocales: const [Locale('en'), Locale('vi')],
        path: 'assets/translations',
        fallbackLocale: const Locale('en'),
        // 3. Cuối cùng mới là MyApp
        child: const MyApp(),
      ),
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
