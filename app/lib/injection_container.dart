import 'package:get_it/get_it.dart';

// Core services
import 'core/services/firebase_service.dart';
import 'core/services/geolocation_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/network_checker.dart';

// Data sources
import 'data/sources/firebase_source.dart';
import 'data/sources/hive_source.dart';
import 'data/sources/mapbox_source.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/team_repository.dart';

// BLoCs
import 'features/auth/bloc/auth_bloc.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'features/teams/bloc/team_bloc.dart';

/// Dependency injection container
final GetIt sl = GetIt.instance;

/// Initializes all dependencies
Future<void> initializeDependencies() async {
  // Core services
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
  sl.registerLazySingleton<GeolocationService>(() => GeolocationService.instance);
  sl.registerLazySingleton<HiveService>(() => HiveService.instance);
  sl.registerLazySingleton<NetworkChecker>(() => NetworkChecker.instance);

  // Data sources
  sl.registerLazySingleton<FirebaseSource>(() => FirebaseSource());
  sl.registerLazySingleton<HiveSource>(() => HiveSource());
  sl.registerLazySingleton<MapboxSource>(() => MapboxSource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(() => AuthRepository(
    firebaseSource: sl<FirebaseSource>(),
    hiveSource: sl<HiveSource>(),
    networkChecker: sl<NetworkChecker>(),
  ));
  sl.registerLazySingleton<TaskRepository>(() => TaskRepository(
    firebaseSource: sl<FirebaseSource>(),
    hiveSource: sl<HiveSource>(),
    networkChecker: sl<NetworkChecker>(),
  ));
  sl.registerLazySingleton<TeamRepository>(() => TeamRepository(
    firebaseSource: sl<FirebaseSource>(),
    hiveSource: sl<HiveSource>(),
    networkChecker: sl<NetworkChecker>(),
  ));

  // BLoCs
  sl.registerFactory<AuthBloc>(() => AuthBloc(
    authRepository: sl<AuthRepository>(),
  ));
  sl.registerFactory<TaskBloc>(() => TaskBloc(
    taskRepository: sl<TaskRepository>(),
  ));
  sl.registerFactory<TeamBloc>(() => TeamBloc(
    teamRepository: sl<TeamRepository>(),
  ));
}

/// Initializes core services
Future<void> initializeCoreServices() async {
  try {
    // Initialize Firebase
    await sl<FirebaseService>().initialize();
    
    // Initialize Hive
    await sl<HiveService>().initialize();
    
    // Initialize other services as needed
    // Note: GeolocationService and NetworkChecker don't need explicit initialization
    
  } catch (e) {
    throw Exception('Failed to initialize core services: $e');
  }
}

/// Resets all dependencies (useful for testing)
Future<void> resetDependencies() async {
  await sl.reset();
}

