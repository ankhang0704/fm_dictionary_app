import 'package:fm_dictionary/data/services/ai_speech/ai_assistant/ai_assistant_service.dart';
import 'package:fm_dictionary/data/services/ai_speech/text_to_speech/speech_service.dart';
import 'package:fm_dictionary/data/services/auth_sync/auth_sync_service.dart';
import 'package:fm_dictionary/data/services/database/database_service.dart';
import 'package:fm_dictionary/features/auth/presentation/providers/auth_provider.dart';
import 'package:fm_dictionary/features/gamification/presentation/providers/gamification_provider.dart';
import 'package:fm_dictionary/features/home/presentation/providers/home_provider.dart';
import 'package:fm_dictionary/features/learning/presentation/providers/learning_provider.dart';
import 'package:fm_dictionary/providers/streak_provider.dart';
import 'package:get_it/get_it.dart';

// --- Imaginary Imports ---
// Services


// Providers

final sl = GetIt.instance;

Future<void> init() async {
  // ---------------------------------------------------------------------------
  // ! CORE SERVICES (Registered as Lazy Singletons)
  // These are instantiated only once when they are first requested.
  // ---------------------------------------------------------------------------
  
  sl.registerLazySingleton<DatabaseService>(
    () => DatabaseService(),
  );
  
  sl.registerLazySingleton<AiAssistantService>(
    () => AiAssistantService(),
  );
  
  sl.registerLazySingleton<TtsService>(
    () => TtsService(),
  );
  
  sl.registerLazySingleton<AuthSyncService>(
    () => AuthSyncService(),
  );


  // ---------------------------------------------------------------------------
  // ! STATE MANAGEMENT / PROVIDERS (Registered as Factories)
  // These are instantiated fresh every time they are injected/requested.
  // Assume dependencies (if any) are resolved via sl().
  // ---------------------------------------------------------------------------
  
  sl.registerFactory<AuthProvider>(
    () => AuthProvider(
      // Example of injecting a service:
      // authSyncService: sl(),
    ),
  );
  
  sl.registerFactory<HomeProvider>(
    () => HomeProvider(),
  );
  
  sl.registerFactory<LearningProvider>(
    () => LearningProvider(
      // databaseService: sl(),
    ),
  );
  
  sl.registerFactory<GamificationProvider>(
    () => GamificationProvider(),
  );
  
  sl.registerFactory<StreakProvider>(
    () => StreakProvider(),
  );
}