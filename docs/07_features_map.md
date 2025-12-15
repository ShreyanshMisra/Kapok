# Map Feature

## Overview

The map feature provides location-based task visualization using Mapbox. It implements an offline-first approach with automatic region caching around the user's current location.

## Key Capabilities

- Interactive Mapbox map with task markers
- Automatic offline region caching (~3 mile radius)
- Task markers color-coded by priority
- Click-to-view task details
- Network status indicator
- Platform-specific implementations (web vs mobile)

## Pages

### MapPage (`lib/features/map/pages/map_page.dart`)

The primary map interface displayed in the home navigation.

**UI Components:**

1. **Map View**
   - Full-screen Mapbox map
   - Extends behind app bar
   - Initial position: user's current location (or fallback coordinates)

2. **Status Card** (top-left)
   - Region name
   - Online/offline indicator
   - Download progress during region updates

3. **Controls** (top-right)
   - Cache view button → navigates to `/map-cache`
   - Tasks list button → navigates to `/tasks`
   - Test offline mode toggle (for development)
   - Cache overlay toggle (shows cached region boundary)

4. **Task Markers**
   - Custom pin design with priority-based colors:
     - High: Red
     - Medium: Orange/Yellow
     - Low: Green
     - Completed: Gray
   - Hover tooltip showing task title and ID (web)
   - Tap to navigate to task detail

5. **Cache Overlay** (optional)
   - Circular boundary showing cached region
   - ~3 mile radius visualization
   - Semi-transparent fill with border

### MapTestPage (`lib/features/map/pages/map_test_page.dart`)

Development testing page for map functionality.

### MapCachePage (`lib/features/map/pages/map_cache_page.dart`)

View and manage downloaded offline map regions.

## Offline Region System

### How It Works

1. **Initialization**: On map load, checks for cached region
2. **Location Check**: Gets user's current GPS position
3. **Region Creation**: Downloads map tiles for ~4.8km radius
4. **Periodic Refresh**: Timer checks every 5 minutes
5. **Movement Trigger**: Refreshes if user moves >0.5 miles from center

### Region Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Radius | 4.8 km (~3 miles) | Coverage area |
| Zoom Min | 13 | Minimum zoom level cached |
| Zoom Max | 18 | Maximum zoom level cached |
| Movement Threshold | 804.672 m (~0.5 mile) | Triggers new download |
| Refresh Interval | 5 minutes | Automatic check frequency |

### Offline Region Model

```dart
class OfflineMapRegion {
  final String id;
  final String name;
  final double centerLat;
  final double centerLon;
  final double radiusKm;
  final int zoomMin;
  final int zoomMax;
  final DateTime lastSyncedAt;
  final int tileCount;
  final int downloadedTileCount;
}
```

## BLoC Structure

### Events (`lib/features/map/bloc/map_event.dart`)

| Event | Parameters | Purpose |
|-------|------------|---------|
| `MapStarted` | none | Initialize map, load cached region |
| `MapCameraMoved` | camera | Track camera position changes |
| `OfflineBubbleRefreshRequested` | force? | Request new offline region |
| `OfflineBubbleProgressReported` | regionId, progress | Update download progress |
| `OfflineBubbleDownloadCompleted` | region | Mark download complete |
| `LoadTasksOnMap` | teamIds, userId | Load tasks to display |
| `MapReset` | none | Clear state (on logout) |

### States (`lib/features/map/bloc/map_state.dart`)

| State | Properties | Meaning |
|-------|------------|---------|
| `MapLoading` | none | Loading region |
| `MapReady` | region, isOfflineMode, lastCamera | Map ready to display |
| `OfflineRegionUpdating` | region, progress, isOfflineMode | Downloading tiles |
| `MapWithTasks` | tasks, region, isOfflineMode, lastCamera | Map with task markers |
| `MapError` | message | Error occurred |

### Camera State

```dart
class MapCameraState {
  final double latitude;
  final double longitude;
  final double zoom;
  final double? bearing;
  final double? pitch;
}
```

## Repository (`lib/data/repositories/map_repository.dart`)

### Interface Methods

```dart
abstract class MapRepository {
  // Check network status
  Future<bool> isOfflineMode();

  // Load region for current location
  Future<OfflineRegionResult> loadRegionForCurrentLocation({
    double radiusKm,
    int zoomMin,
    int zoomMax,
  });

  // Get all downloaded regions
  Future<List<OfflineMapRegion>> getDownloadedRegions();

  // Delete a region
  Future<void> deleteRegion(String regionId);

  // Stream download progress
  Stream<double> streamRegionStatus(String regionId);
}
```

### Implementation

`MapRepositoryImpl` coordinates:
- `NetworkChecker` for connectivity status
- `MapboxRemoteDataSource` for tile downloads
- `OfflineMapCache` for local storage
- `OfflineMapRegionRepository` for region metadata
- `GeolocationService` for current position
- `FirebaseMapSnapshotSource` for snapshot storage

## Platform-Specific Controllers

### Web Controller (`lib/features/map/web/mapbox_web_controller.dart`)

- JavaScript interop with Mapbox GL JS
- Screen coordinate projection for marker positioning
- Handles web-specific map events

### Mobile Controller (`lib/features/map/mobile/mapbox_mobile_controller.dart`)

- Native Mapbox SDK integration
- Native marker support
- Platform-specific gesture handling

## Map View Widget

`MapboxMapView` (`lib/features/map/widgets/mapbox_map_view.dart`) abstracts platform differences:

```dart
MapboxMapView({
  required double initialLatitude,
  required double initialLongitude,
  required double initialZoom,
  OfflineMapRegion? offlineBubble,
  required bool isOfflineMode,
  List<TaskModel>? tasks,
  Function(TaskModel)? onTaskMarkerTap,
  Function(MapCameraState)? onCameraIdle,
  Function(MapboxWebController)? onControllerReady,
  Function(MapboxMobileController)? onMobileControllerReady,
})
```

## Task Markers

### Marker Design

Custom painted markers with:
- Circular head with icon
- Pin point at bottom
- Drop shadow
- Hover scale animation (web)
- White border for visibility

### Priority Colors

| Priority | Color | Icon |
|----------|-------|------|
| High | Red (#F44336) | Warning |
| Medium | Orange (#FFC107) | Info |
| Low | Green (#4CAF50) | Check Circle |
| Completed | Gray | Check Circle |

### Marker Interaction

1. **Hover** (web): Shows tooltip with task title, ID, priority label
2. **Tap**: Navigates to task detail page with task data

## Data Sources

### MapboxRemoteDataSource

Handles Mapbox API communication:
- Style URL construction
- Tile URL generation
- Access token management

### OfflineMapCache

Local tile storage using Hive:
- Store/retrieve cached tiles
- Manage cache size
- Clear expired data

### FirebaseMapSnapshotSource

Firebase integration for map snapshots (configured but minimal usage).

## Authentication Integration

The map listens to `AuthBloc` state:
- On logout (`AuthUnauthenticated`): Disposes map controllers immediately
- On `MapReset` event: Clears all map state, cancels timers

## Network Behavior

| Connectivity | Behavior |
|--------------|----------|
| Online | Live tiles + offline cache updates |
| Offline | Cached tiles only, no new downloads |
| Transitioning | Automatic sync when connection restored |

## Limitations

- Map filters for tasks are not implemented (deferred; tasks have filtering in TasksPage)
- Offline region downloads require initial online connection
- Web markers use overlay positioning (may shift slightly on zoom)
