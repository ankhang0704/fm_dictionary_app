import 'package:easy_localization/easy_localization.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fm_dictionary/core/di/service_locator.dart';
import 'package:fm_dictionary/data/services/ui_management/theme_manager.dart';
import 'package:fm_dictionary/features/auth/presentation/screens/profile_screen.dart';
import 'package:fm_dictionary/features/home/presentation/screens/streak_screen.dart';
import 'package:fm_dictionary/features/learning/study_screen.dart';
import 'package:fm_dictionary/features/library/presentation/screens/detail_dictionary_screen.dart';
import 'package:fm_dictionary/features/settings/presentation/screens/settings_screen.dart';
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
          onGenerateRoute: (settings) {
            switch (settings.name) {
              case AppRoutes.welcome:
                return CupertinoPageRoute(
                  builder: (_) => const WelcomeScreen(),
                );
              case AppRoutes.dashboard:
                return CupertinoPageRoute(
                  builder: (_) => const MainNavigation(),
                );

              // Auth
              case AppRoutes.login:
                return CupertinoPageRoute(builder: (_) => const LoginScreen());
              case AppRoutes.register:
                return CupertinoPageRoute(
                  builder: (_) => const RegisterScreen(),
                );
              case AppRoutes.forgotPassword:
                return CupertinoPageRoute(
                  builder: (_) => const ForgotPasswordScreen(),
                );
              case AppRoutes.changePassword:
                return CupertinoPageRoute(
                  builder: (_) => const ChangePasswordScreen(),
                );

              // Library & Search
              case AppRoutes.library:
                return CupertinoPageRoute(
                  builder: (_) => const RoadmapScreen(),
                );
              case AppRoutes.search:
                return CupertinoPageRoute(builder: (_) => const SearchScreen());
              case AppRoutes.wordDetail:
                {
                  final args = settings.arguments as Map<String, dynamic>;
                  return CupertinoPageRoute(
                    builder: (_) => WordDetailScreen(word: args['word']),
                  );
                }

              // ✅ THE FIX: topicDetail now safely extracts the topic string
              case AppRoutes.topicDetail:
                {
                  final args = settings.arguments as Map<String, dynamic>;
                  final topic = args['topic'] as String;
                  return CupertinoPageRoute(
                    builder: (_) => DictionaryDetailScreen(topic: topic),
                  );
                }

              // Learning
              case AppRoutes.quizConfig:
                {
                  final args = settings.arguments;
                  return CupertinoPageRoute(
                    builder: (_) => QuizConfigurationScreen(
                      initialTopic: args is String ? args : 'All',
                    ),
                  );
                }
              case AppRoutes.study:
                {
                  final args = settings.arguments as Map<String, dynamic>;
                  return CupertinoPageRoute(
                    builder: (_) => StudyScreen(
                      words: args['words'],
                      isFromRoadmap: args['isFromRoadmap'] ?? false,
                    ),
                  );
                }
              case AppRoutes.review:
                return CupertinoPageRoute(
                  builder: (_) => const SmartReviewScreen(),
                );
              case AppRoutes.quiz:
                return CupertinoPageRoute(builder: (_) => const QuizScreen());

              // Stats & Settings
              case AppRoutes.stats:
                return CupertinoPageRoute(builder: (_) => const StatsScreen());
              case AppRoutes.settings:
                return CupertinoPageRoute(
                  builder: (_) => const SettingsScreen(),
                );
              case AppRoutes.profile:
                return CupertinoPageRoute(
                  builder: (_) => const ProfileScreen(),
                );

              // History, Saved
              case AppRoutes.history:
                return CupertinoPageRoute(builder: (_) => HistoryScreen());
              case AppRoutes.saved:
                return CupertinoPageRoute(
                  builder: (_) => const SavedWordsScreen(),
                );

              // Static Content
              case AppRoutes.staticContent:
                {
                  final args = settings.arguments as Map<String, String>;
                  return CupertinoPageRoute(
                    builder: (_) => StaticContentScreen(
                      title: args['title']!,
                      mdFileName: args['mdFileName']!,
                    ),
                  );
                }

              default:
                return CupertinoPageRoute(
                  builder: (_) => const MainNavigation(),
                );
            }
          },
          initialRoute: settings.isFirstRun
              ? AppRoutes.welcome
              : AppRoutes.dashboard,
        ),
      ),
    );
  }
}
