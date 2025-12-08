import 'package:equatable/equatable.dart';
import '../../../data/models/offline_map_region_model.dart';
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

/// Error state
class MapError extends MapState {
  final String message;

  const MapError({required this.message});

  @override
  List<Object> get props => [message];
}
