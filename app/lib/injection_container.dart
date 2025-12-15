import 'package:get_it/get_it.dart';

// Core services
import 'core/services/firebase_service.dart';
import 'core/services/geolocation_service.dart';
import 'core/services/hive_service.dart';
import 'core/services/network_checker.dart';
import 'core/constants/mapbox_constants.dart';
import 'core/services/sync_service.dart';
import 'core/services/theme_service.dart';

// Data sources
import 'data/sources/firebase_source.dart';
import 'data/sources/hive_source.dart';
import 'data/sources/mapbox_remote_data_source.dart';
import 'data/sources/offline_map_cache.dart';
import 'data/sources/firebase_map_snapshot_source.dart';
// import 'data/sources/mapbox_source.dart';

// Repositories
import 'data/repositories/auth_repository.dart';
import 'data/repositories/task_repository.dart';
import 'data/repositories/team_repository.dart';
import 'data/repositories/map_repository.dart';
import 'data/repositories/offline_map_region_repository.dart';

// BLoCs
import 'features/auth/bloc/auth_bloc.dart';
import 'features/tasks/bloc/task_bloc.dart';
import 'features/teams/bloc/team_bloc.dart';
import 'features/map/bloc/map_bloc.dart';
// import 'features/profile/bloc/profile_bloc.dart';

/// Dependency injection container
final GetIt sl = GetIt.instance;

/// Initializes all dependencies
Future<void> initializeDependencies() async {
  // Core services
  sl.registerLazySingleton<FirebaseService>(() => FirebaseService.instance);
  sl.registerLazySingleton<GeolocationService>(
    () => GeolocationService.instance,
  );
  sl.registerLazySingleton<HiveService>(() => HiveService.instance);
  sl.registerLazySingleton<NetworkChecker>(() => NetworkChecker.instance);
  sl.registerLazySingleton<SyncService>(() => SyncService.instance);
  sl.registerLazySingleton<ThemeService>(() => ThemeService.instance);

  // Data sources
  sl.registerLazySingleton<FirebaseSource>(() => FirebaseSource());
  sl.registerLazySingleton<HiveSource>(() => HiveSource());

  // Map data sources
  sl.registerLazySingleton<MapboxRemoteDataSource>(
    () => MapboxRemoteDataSource(
      accessToken: MapboxConstants.accessToken,
      styleId: MapboxConstants.defaultStyleId,
    ),
  );
  sl.registerLazySingleton<OfflineMapCache>(() => OfflineMapCache());
  sl.registerLazySingleton<OfflineMapRegionRepository>(
    () => OfflineMapRegionRepository(),
  );
  sl.registerLazySingleton<FirebaseMapSnapshotSource>(
    () => FirebaseMapSnapshotSource(),
  );

  // sl.registerLazySingleton<MapboxSource>(() => MapboxSource());

  // Repositories
  sl.registerLazySingleton<AuthRepository>(
    () => AuthRepository(
      firebaseSource: sl<FirebaseSource>(),
      hiveSource: sl<HiveSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerLazySingleton<TaskRepository>(
    () => TaskRepository(
      firebaseSource: sl<FirebaseSource>(),
      hiveSource: sl<HiveSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );
  sl.registerLazySingleton<TeamRepository>(
    () => TeamRepository(
      firebaseSource: sl<FirebaseSource>(),
      hiveSource: sl<HiveSource>(),
      networkChecker: sl<NetworkChecker>(),
    ),
  );

  // Map repository
  sl.registerLazySingleton<MapRepository>(
    () => MapRepositoryImpl(
      networkChecker: sl<NetworkChecker>(),
      mapboxDataSource: sl<MapboxRemoteDataSource>(),
      offlineCache: sl<OfflineMapCache>(),
      regionRepository: sl<OfflineMapRegionRepository>(),
      geolocationService: sl<GeolocationService>(),
      snapshotSource: sl<FirebaseMapSnapshotSource>(),
    ),
  );

  // BLoCs
  sl.registerFactory<AuthBloc>(
    () => AuthBloc(authRepository: sl<AuthRepository>()),
  );
  sl.registerFactory<TaskBloc>(
    () => TaskBloc(taskRepository: sl<TaskRepository>()),
  );
  sl.registerFactory<TeamBloc>(
    () => TeamBloc(teamRepository: sl<TeamRepository>()),
  );
  sl.registerFactory<MapBloc>(
    () => MapBloc(
      mapRepository: sl<MapRepository>(),
      taskRepository: sl<TaskRepository>(),
    ),
  );
  // sl.registerFactory<ProfileBloc>(() => ProfileBloc(
  //    authRepository: sl<AuthRepository>(),
  //  ));
}

/// Initializes core services
Future<void> initializeCoreServices() async {
  try {
    // Initialize Firebase
    await sl<FirebaseService>().initialize();

    // Initialize Hive
    await sl<HiveService>().initialize();

    // Initialize Theme Service (depends on Hive)
    await sl<ThemeService>().initialize();

    // Initialize map cache and region repository
    await sl<OfflineMapCache>().initialize();
    await sl<OfflineMapRegionRepository>().initialize();

    // Initialize other services as needed
    // Note: GeolocationService and NetworkChecker don't need explicit initialization
    // Initialize Sync Service
    await sl<SyncService>().initialize();

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
