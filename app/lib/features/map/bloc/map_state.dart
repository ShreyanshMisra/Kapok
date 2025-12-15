import 'package:equatable/equatable.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../../../data/models/task_model.dart';
import '../models/map_camera_state.dart';

/// Map states
abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object?> get props => [];
}

class MapLoading extends MapState {
  const MapLoading();
}

/// Map is ready to render with an active offline bubble.
class MapReady extends MapState {
  final OfflineMapRegion region;
  final bool isOfflineMode;
  final MapCameraState? lastCamera;

  const MapReady({
    required this.region,
    required this.isOfflineMode,
    this.lastCamera,
  });

  @override
  List<Object?> get props => [region, isOfflineMode, lastCamera];
}

/// Background job currently refreshing offline tiles.
class OfflineRegionUpdating extends MapState {
  final OfflineMapRegion region;
  final double progress;
  final bool isOfflineMode;

  const OfflineRegionUpdating({
    required this.region,
    required this.progress,
    required this.isOfflineMode,
  });

  @override
  List<Object> get props => [region, progress, isOfflineMode];
}

/// Map with tasks loaded (for displaying task pins)
class MapWithTasks extends MapState {
  final List<TaskModel> tasks;
  final OfflineMapRegion? region;
  final bool isOfflineMode;
  final MapCameraState? lastCamera;

  const MapWithTasks({
    required this.tasks,
    this.region,
    this.isOfflineMode = false,
    this.lastCamera,
  });

  @override
  List<Object?> get props => [tasks, region, isOfflineMode, lastCamera];
}

/// Error state
class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object> get props => [message];
}
