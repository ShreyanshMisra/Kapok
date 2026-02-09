import 'package:equatable/equatable.dart';
import '../../../data/models/offline_map_region_model.dart';
import '../models/map_camera_state.dart';

/// Map events
abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object?> get props => [];
}

/// Fired when MapPage requests initialization.
class MapStarted extends MapEvent {
  const MapStarted();
}

/// Fired when the user stops interacting and the camera settles.
class MapCameraMoved extends MapEvent {
  final MapCameraState camera;

  const MapCameraMoved(this.camera);

  @override
  List<Object> get props => [camera.latitude, camera.longitude, camera.zoom];
}

/// Asks the repository to recompute/download the offline bubble.
class OfflineBubbleRefreshRequested extends MapEvent {
  final bool force;
  final double? targetLat;
  final double? targetLon;

  const OfflineBubbleRefreshRequested({
    this.force = false,
    this.targetLat,
    this.targetLon,
  });

  @override
  List<Object?> get props => [force, targetLat, targetLon];
}

/// Streams progress updates from the repository download job.
class OfflineBubbleProgressReported extends MapEvent {
  final String regionId;
  final double progress;

  const OfflineBubbleProgressReported({
    required this.regionId,
    required this.progress,
  });

  @override
  List<Object> get props => [regionId, progress];
}

/// Notifies the bloc that a region finished downloading.
class OfflineBubbleDownloadCompleted extends MapEvent {
  final OfflineMapRegion region;

  const OfflineBubbleDownloadCompleted(this.region);

  @override
  List<Object> get props => [region];
}

/// Load tasks to display on map
class LoadTasksOnMap extends MapEvent {
  final List<String> teamIds;
  final String? userId;

  const LoadTasksOnMap({
    required this.teamIds,
    this.userId,
  });

  @override
  List<Object?> get props => [teamIds, userId];
}

/// Reset map state (on logout)
class MapReset extends MapEvent {
  const MapReset();
}
