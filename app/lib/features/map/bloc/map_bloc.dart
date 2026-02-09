import 'dart:async';

import 'package:flutter_bloc/flutter_bloc.dart';

import '../../../core/services/geolocation_service.dart';
import '../../../core/utils/logger.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../../../data/repositories/map_repository.dart';
import '../../../data/repositories/task_repository.dart';
import '../models/map_camera_state.dart';
import 'map_event.dart';
import 'map_state.dart';

/// Coordinates Mapbox rendering with offline bubble management.
class MapBloc extends Bloc<MapEvent, MapState> {
  MapBloc({
    required MapRepository mapRepository,
    required TaskRepository taskRepository,
  })  : mapRepository = mapRepository,
        _taskRepository = taskRepository,
        super(const MapLoading()) {
    on<MapStarted>(_onMapStarted);
    on<MapCameraMoved>(_onCameraMoved);
    on<OfflineBubbleRefreshRequested>(_onRefreshRequested);
    on<OfflineBubbleProgressReported>(_onProgressReported);
    on<OfflineBubbleDownloadCompleted>(_onDownloadCompleted);
    on<LoadTasksOnMap>(_onLoadTasksOnMap);
    on<MapReset>(_onMapReset);
  }

  final MapRepository mapRepository;
  final TaskRepository _taskRepository;
  final GeolocationService _geolocationService = GeolocationService.instance;

  static const _movementThresholdMeters = 804.672; // ~0.5 mile

  Timer? _refreshTimer;
  StreamSubscription<double>? _progressSubscription;
  OfflineMapRegion? _activeRegion;
  MapCameraState? _lastCamera;
  DateTime? _lastRefresh;

  Future<void> _onMapStarted(MapStarted event, Emitter<MapState> emit) async {
    try {
      final cached = await _loadLatestRegionFromCache();
      if (cached != null) {
        _activeRegion = cached;
        final offline = await mapRepository.isOfflineMode();
        emit(
          MapReady(
            region: cached,
            isOfflineMode: offline,
            lastCamera: _lastCamera,
          ),
        );
      } else {
        emit(const MapLoading());
      }

      await _startOrRestartRefreshTimer();

      if (cached == null) {
        add(const OfflineBubbleRefreshRequested(force: true));
      }
    } catch (e) {
      // Logger.task('Failed to bootstrap map', error: e);
      emit(MapError(message: e.toString()));
    }
  }

  Future<void> _onCameraMoved(
    MapCameraMoved event,
    Emitter<MapState> emit,
  ) async {
    _lastCamera = event.camera;
    final currentState = state;
    if (currentState is MapReady) {
      emit(
        MapReady(
          region: currentState.region,
          isOfflineMode: currentState.isOfflineMode,
          lastCamera: _lastCamera,
        ),
      );
    }
  }

  Future<void> _onRefreshRequested(
    OfflineBubbleRefreshRequested event,
    Emitter<MapState> emit,
  ) async {
    try {
      if (!event.force && !_shouldRefreshByInterval()) {
        // Reduced logging frequency - only log occasionally
        // Logger.task('Skipping bubble refresh (interval not reached)');
        return;
      }

      if (!event.force && !(await _hasMovedMoreThanThreshold())) {
        // Reduced logging frequency - only log occasionally
        // Logger.task('Skipping bubble refresh (movement below threshold)');
        return;
      }

      await _startNewBubble(emit, targetLat: event.targetLat, targetLon: event.targetLon);
    } catch (e) {
      // Logger.task('Error refreshing offline bubble', error: e);
      emit(MapError(message: e.toString()));
    }
  }

  Future<void> _onProgressReported(
    OfflineBubbleProgressReported event,
    Emitter<MapState> emit,
  ) async {
    final region = _activeRegion;
    if (region == null) return;
    if (event.regionId != region.id) return;

    if (event.progress >= 1.0) {
      add(OfflineBubbleDownloadCompleted(region));
    } else {
      final offline = await mapRepository.isOfflineMode();
      emit(
        OfflineRegionUpdating(
          region: region,
          progress: event.progress,
          isOfflineMode: offline,
        ),
      );
    }
  }

  Future<void> _onDownloadCompleted(
    OfflineBubbleDownloadCompleted event,
    Emitter<MapState> emit,
  ) async {
    _activeRegion = event.region;
    final offline = await mapRepository.isOfflineMode();
    emit(
      MapReady(
        region: event.region,
        isOfflineMode: offline,
        lastCamera: _lastCamera,
      ),
    );
  }

  /// Handle load tasks on map
  Future<void> _onLoadTasksOnMap(
    LoadTasksOnMap event,
    Emitter<MapState> emit,
  ) async {
    try {
      Logger.task('Loading tasks for map: ${event.teamIds.length} teams');

      // Load tasks for user's teams (or all if admin)
      final tasks = await _taskRepository.getTasksForUserTeams(
        event.teamIds,
        userId: event.userId,
      );

      Logger.task('Loaded ${tasks.length} tasks for map');

      final offline = await mapRepository.isOfflineMode();
      emit(
        MapWithTasks(
          tasks: tasks,
          region: _activeRegion,
          isOfflineMode: offline,
          lastCamera: _lastCamera,
        ),
      );
    } catch (e) {
      Logger.task('Error loading tasks for map', error: e);
      emit(MapError(message: e.toString()));
    }
  }

  Future<void> _startNewBubble(Emitter<MapState> emit, {double? targetLat, double? targetLon}) async {
    // Logger.task('Starting offline bubble refresh');
    await _progressSubscription?.cancel();
    final result = await mapRepository.loadRegionForCurrentLocation(
      radiusKm: 4.8, // ~3 miles
      zoomMin: 13,
      zoomMax: 18,
      targetLat: targetLat,
      targetLon: targetLon,
    );
    _activeRegion = result.region;
    _lastRefresh = DateTime.now();
    final offline = await mapRepository.isOfflineMode();
    emit(
      MapReady(
        region: result.region,
        isOfflineMode: offline,
        lastCamera: _lastCamera,
      ),
    );
    _progressSubscription = mapRepository
        .streamRegionStatus(result.region.id)
        .listen((progress) {
          add(
            OfflineBubbleProgressReported(
              regionId: result.region.id,
              progress: progress,
            ),
          );
        });
  }

  Future<OfflineMapRegion?> _loadLatestRegionFromCache() async {
    final regions = await mapRepository.getDownloadedRegions();
    if (regions.isEmpty) return null;
    regions.sort((a, b) => b.lastSyncedAt.compareTo(a.lastSyncedAt));
    return regions.first;
  }

  bool _shouldRefreshByInterval() {
    if (_lastRefresh == null) return true;
    return DateTime.now().difference(_lastRefresh!) >=
        const Duration(minutes: 5);
  }

  Future<bool> _hasMovedMoreThanThreshold() async {
    final region = _activeRegion;
    if (region == null) return true;
    final position = await _geolocationService.getCurrentPosition();
    final distance = _geolocationService.calculateDistance(
      startLatitude: region.centerLat,
      startLongitude: region.centerLon,
      endLatitude: position.latitude,
      endLongitude: position.longitude,
    );
    // Reduced logging - only log if movement is significant
    // if (distance >= _movementThresholdMeters) {
    //   Logger.task('Device moved $distance m since last bubble center');
    // }
    return distance >= _movementThresholdMeters;
  }

  Future<void> _startOrRestartRefreshTimer() async {
    _refreshTimer?.cancel();
    _refreshTimer = Timer.periodic(
      const Duration(minutes: 5),
      (_) => add(const OfflineBubbleRefreshRequested()),
    );
  }

  /// Handle map reset (on logout)
  Future<void> _onMapReset(MapReset event, Emitter<MapState> emit) async {
    // Logger.task('Resetting map state');
    _refreshTimer?.cancel();
    _progressSubscription?.cancel();
    _activeRegion = null;
    _lastCamera = null;
    _lastRefresh = null;
    emit(const MapLoading());
  }

  @override
  Future<void> close() {
    _refreshTimer?.cancel();
    _progressSubscription?.cancel();
    return super.close();
  }
}
