import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fm_dictionary/core/di/service_locator.dart';
import 'package:fm_dictionary/data/services/ui_management/theme_manager.dart';
import 'package:fm_dictionary/features/learning/study_screen.dart';
import 'package:provider/provider.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'package:flutter_timezone/flutter_timezone.dart';

// --- CORE / CONSTANTS ---
import 'core/constants/app_routes.dart';
import 'core/theme/app_colors.dart';
import 'firebase_options.dart';

// --- SERVICES ---
import 'data/services/database/database_service.dart';
import 'data/services/auth_sync/auth_sync_service.dart';
import 'data/services/ai_speech/ai_assistant/ai_assistant_service.dart';
import 'data/services/ai_speech/text_to_speech/speech_service.dart';
import 'data/services/notify/notification_service.dart';

// --- PROVIDERS ---
import 'features/auth/presentation/providers/auth_provider.dart';
import 'features/learning/presentation/providers/learning_provider.dart';
import 'features/learning/presentation/providers/quiz_provider.dart';
import 'features/home/presentation/providers/home_provider.dart';
import 'features/roadmap/presentation/providers/roadmap_provider.dart';
import 'features/search/presentation/providers/search_provider.dart';
import 'features/gamification/presentation/providers/gamification_provider.dart';
import 'features/settings/presentation/providers/settings_provider.dart';
import 'features/settings/presentation/providers/notification_provider.dart';

// --- SCREENS ---
import 'features/welcome/welcome_screen.dart';
import 'features/home/presentation/screens/main_navigation.dart';
import 'features/auth/presentation/screens/login_screen.dart';
import 'features/auth/presentation/screens/register_screen.dart';
import 'features/auth/presentation/screens/forgot_password_screen.dart';
import 'features/auth/presentation/screens/change_password_screen.dart';
import 'features/roadmap/presentation/screen/roadmap_screen.dart';
import 'features/search/presentation/screens/search_screen.dart';
import 'features/search/presentation/screens/word_detail_screen.dart';
import 'features/history/presentation/screens/history_screen.dart';
import 'features/saved/presentation/screens/saved_words_screen.dart';
import 'features/learning/review_screen.dart';
import 'features/learning/quiz_configuration_screen.dart';
import 'features/learning/quiz_screen.dart';
import 'features/info/presentation/screens/static_content_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await init();
  // 1. Core Initializations
  await EasyLocalization.ensureInitialized();

  // 2. Local Storage & Timezone
  await DatabaseService.init();
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

  // 3. Audio & AI Services
  await TtsService().init();
  await AiAssistantService().initModel();

  // 4. Auth & Notifications
  await AuthSyncService().init();
  await NotificationService.instance.init();

  // Lock Orientation
  SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('en'), Locale('vi')],
      path: 'assets/translations',
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

    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => LearningProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => HomeProvider()),
        ChangeNotifierProvider(create: (_) => QuizProvider()),
        ChangeNotifierProvider(create: (_) => SearchProvider()),
        ChangeNotifierProvider(create: (_) => RoadmapProvider()),
        ChangeNotifierProvider(create: (_) => GamificationProvider()),
        ChangeNotifierProvider(create: (_) => SettingsProvider()),
      ],
       child: ValueListenableBuilder<ThemeMode>(
        valueListenable: ThemeManager.themeNotifier,
        builder: (_, themeMode, _) => MaterialApp(
        title: 'English Mesh',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        darkTheme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Quicksand',
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.meshBlue,
            brightness: Brightness.dark,
          ),
        ),
        // Localization
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,

        // --- GLOBAL DESIGN SYSTEM THEME ---
        theme: ThemeData(
          useMaterial3: true,
          fontFamily: 'Quicksand',
          // CRITICAL: Scaffolds are transparent to show the Mesh Gradient background wrapper
          scaffoldBackgroundColor: Colors.transparent,
          colorScheme: ColorScheme.fromSeed(
            seedColor: AppColors.meshBlue,
            brightness: Brightness.light,
          ),
        ),

        // --- NAVIGATION & ROUTING ---
        initialRoute: settings.isFirstRun
            ? AppRoutes.welcome
            : AppRoutes.dashboard,
        routes: {
          AppRoutes.welcome: (context) => const WelcomeScreen(),
          AppRoutes.dashboard: (context) => const MainNavigation(),

          // Auth
          AppRoutes.login: (context) => const LoginScreen(),
          AppRoutes.register: (context) => const RegisterScreen(),
          AppRoutes.forgotPassword: (context) => const ForgotPasswordScreen(),
          AppRoutes.changePassword: (context) => const ChangePasswordScreen(),

          // Library & Search
          AppRoutes.library: (context) => const RoadmapScreen(),
          AppRoutes.search: (context) => const SearchScreen(),
          AppRoutes.wordDetail: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return WordDetailScreen(word: args['word']);
          },

          // Learning
          AppRoutes.quizConfig: (context) {
            final args = ModalRoute.of(context)?.settings.arguments;
            return QuizConfigurationScreen(
              initialTopic: args is String ? args : 'All',
            );
          },
          AppRoutes.study: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, dynamic>;
            return StudyScreen(
              words: args['words'],
              isFromRoadmap: args['isFromRoadmap'] ?? false,
            );
          },
          AppRoutes.review: (context) => const SmartReviewScreen(),
          AppRoutes.quiz: (context) => const QuizScreen(),

          // Profile & Settings
          AppRoutes.history: (context) => HistoryScreen(),
          AppRoutes.saved: (context) => const SavedWordsScreen(),
          AppRoutes.staticContent: (context) {
            final args =
                ModalRoute.of(context)!.settings.arguments
                    as Map<String, String>;
            return StaticContentScreen(
              title: args['title']!,
              mdFileName: args['mdFileName']!,
            );
          },
        },
      ),
    )
      
    );
  }
}
  

