import 'package:easy_localization/easy_localization.dart';
import 'package:flutter/material.dart';
import 'package:fm_dictionary/core/constants/app_routes.dart';
import 'package:fm_dictionary/core/utils/loading.dart';
import 'package:fm_dictionary/data/services/auth/auth_sync_service.dart';
import 'package:fm_dictionary/data/services/ai_speech/ai_assistant/ai_assistant_service.dart';
import 'package:fm_dictionary/data/services/notify/notification_service.dart';
import 'package:fm_dictionary/features/auth/presentation/screens/change_password_screen.dart';
import 'package:fm_dictionary/features/auth/presentation/screens/forgot_password_screen.dart';
import 'package:fm_dictionary/features/auth/presentation/screens/login_screen.dart';
import 'package:fm_dictionary/features/auth/presentation/screens/register_screen.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:fm_dictionary/features/home/presentation/screens/menu_screen.dart';
import 'package:fm_dictionary/features/home/presentation/screens/streak_screen.dart';
import 'package:fm_dictionary/features/info/presentation/screens/static_content_screen.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/quiz_provider.dart';
import 'package:fm_dictionary/features/learning/quiz_configuration_screen.dart';
import 'package:fm_dictionary/features/learning/review_screen.dart';
import 'package:fm_dictionary/features/roadmap/presentation/providers/roadmap_provider.dart';
import 'package:fm_dictionary/features/roadmap/presentation/screen/roadmap_screen.dart';
import 'package:fm_dictionary/features/search/presentation/providers/search_provider.dart';
import 'package:fm_dictionary/features/search/presentation/screens/search_screen.dart';
import 'package:fm_dictionary/features/search/presentation/screens/word_detail_screen.dart';
import 'package:provider/provider.dart';
import 'data/services/database/database_service.dart';
import 'data/services/ai_speech/text_to_speech/speech_service.dart';
import 'data/services/ui_management/theme_manager.dart';
import 'features/home/presentation/screens/main_navigation.dart';
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
import 'features/auth/presentation/screens/profile_screen.dart';
import 'features/settings/settings_screen.dart';
import 'features/history/presentation/screens/history_screen.dart';
import 'features/saved/presentation/screens/saved_words_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Start Firebase initialization before anything else
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  tz.initializeTimeZones();
  try {
    final TimezoneInfo timezoneInfo = await FlutterTimezone.getLocalTimezone();
    final String timeZoneName =
        timezoneInfo.identifier; // Dùng .identifier nhé!

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
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create:  (_) => RoadmapProvider()),
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
          // --- PHẦN QUAN TRỌNG: KHAI BÁO ROUTES TẠI ĐÂY ---
          initialRoute: settings.isFirstRun
              ? AppRoutes.welcome
              : AppRoutes.main,
          routes: {
            // Core & Welcome
            AppRoutes.welcome: (context) => const WelcomeScreen(),
            AppRoutes.main: (context) => const MainNavigation(),
            // Auth Module
            AppRoutes.login: (context) => const LoginScreen(),
            AppRoutes.register: (context) => const RegisterScreen(),
            AppRoutes.profile: (context) => const ProfileScreen(),
            AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
            AppRoutes.changePassword: (context) => const ChangePasswordScreen(),
            // Home & Stats Module
            AppRoutes.stats: (context) => const StatsScreen(),
            AppRoutes.menu: (context) => const MenuScreen(),
             // Learning Module
            AppRoutes.quizConfig: (context) =>
                const QuizConfigurationScreen(initialTopic: 'All'),
            AppRoutes.review: (context) => const SmartReviewScreen(),

             // Library & Search Module
            AppRoutes.library: (context) => const RoadmapScreen(),
            AppRoutes.search: (context) => const SearchScreen(),
            AppRoutes.wordDetail: (context) {
              final args =
                  ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;

              if (args == null || !args.containsKey('word')) {
                return Scaffold(
                  appBar: AppBar(title: const Text('Error')),
                  body: const Center(child: Text('No word data provided!')),
                );
              }

              final word = args['word'];
              return WordDetailScreen(word: word);
            },
            // History & Saved Module
            AppRoutes.history: (context) =>  HistoryScreen(),
            AppRoutes.saved: (context) => const SavedWordsScreen(),

            AppRoutes.settings: (context) => const SettingsScreen(),
            AppRoutes.staticContent: (context) {
              // Lấy arguments và ép kiểu về Map
              final args =
                  ModalRoute.of(context)?.settings.arguments
                      as Map<String, String>?;

              return StaticContentScreen(
                title: args?['title'] ?? 'Content',
                mdFileName:
                    args?['mdFileName'] ??
                    'content.md', // Đã khớp key với nơi gửi
              );
            },
          },
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
        );
      },
    );
  }
}
