# Map Feature

_Last verified against the codebase: 2026-10-24._

## Overview

The map feature provides location-based task visualization using Mapbox. It implements an offline-first approach with automatic region caching around the user's current location, and it keeps working when location permission is denied.

## Key Capabilities

- Interactive Mapbox map with task markers (blue = active, grey = completed, stars = priority)
- Automatic offline region caching (~3 mile radius)
- Address search (Mapbox Geocoding API) and a "current location" button
- Marker filters by status and priority
- Tap a marker for a preview sheet, then open the task
- Platform-specific implementations (native SDK on mobile, Mapbox GL JS on web)

## Pages

### MapPage (`lib/features/map/pages/map_page.dart`)

The first tab of the home screen.

**UI Components:**

1. **App bar**: title, **View Cache** button (→ `/map-cache`), Kapok logo
2. **Map View**: full-screen Mapbox map. Initial camera, in order of preference: last camera position → user's current location → cached region center → default center (UMass Amherst, `MapboxConstants.defaultLatitude/defaultLongitude`)
3. **Current-location button** (top-left): flies to the device position; shows a snackbar if location is unavailable
4. **Search bar** (top): forward-geocodes an address; selecting a result moves the map and refreshes the offline region around that point (`OfflineBubbleRefreshRequested` with target coordinates)
5. **Filter button** (bottom-right, above the Create Task `+`): filter markers by status and/or priority; a red badge shows how many filters are active
6. **Task Markers**
   - Single blue color (`AppColors.primary`) for active tasks, grey for completed
   - Priority is conveyed via star count on the marker, not pin color
   - Tap → preview bottom sheet (title, stars, status, category, description) with **Open Task**

The global **+** button (from `HomePage`) opens `/create-task`.

### MapCachePage (`lib/features/map/pages/map_cache_page.dart`)

View and manage downloaded offline map regions.

### MapTestPage (`lib/features/map/pages/map_test_page.dart`)

Development testing page. Registered as `/map-test` but not linked from any UI.

## Offline Region System

### How It Works

1. **Initialization**: `MapStarted` loads the most recent cached region (if any) and starts a 5-minute refresh timer
2. **Location Check**: Gets the user's current GPS position. If location is denied or unavailable, the region is centered on the default center instead of failing.
3. **Region Creation**: Downloads map tiles for a ~4.8 km radius
4. **Periodic Refresh**: Timer checks every 5 minutes
5. **Movement Trigger**: Refreshes if the user moves >0.5 miles from the region center (no position = treated as "not moved")

### Region Parameters

| Parameter | Value | Description |
|-----------|-------|-------------|
| Radius | 4.8 km (~3 miles) | Coverage area |
| Zoom Min | 13 | Minimum zoom level cached |
| Zoom Max | 18 | Maximum zoom level cached (also the initial zoom when centering on a fresh region) |
| Movement Threshold | 804.672 m (~0.5 mile) | Triggers new download |
| Refresh Interval | 5 minutes | Automatic check frequency |

### Offline Region Model (`lib/data/models/offline_map_region_model.dart`)

```dart
class OfflineMapRegion {
  final String id;
  final double centerLat;
  final double centerLon;
  final int zoomMin;
  final int zoomMax;
  final double northEastLat;
  final double northEastLon;
  final double southWestLat;
  final double southWestLon;
  final String name;
  final DateTime lastSyncedAt;
  final int totalTiles;
  final int downloadedTiles;
  final String status; // e.g. 'downloading'
}
```

## BLoC Structure

### Events (`lib/features/map/bloc/map_event.dart`)

| Event | Parameters | Purpose |
|-------|------------|---------|
| `MapStarted` | none | Initialize map, load cached region |
| `MapCameraMoved` | camera | Track camera position changes |
| `OfflineBubbleRefreshRequested` | force?, targetLat?, targetLon? | Request new offline region (optionally around a searched point) |
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

`MapWithTasks` is the only state that carries tasks, and tile progress replaces it with `MapReady`/`OfflineRegionUpdating`. `MapPage` therefore keeps the last task list (`_mapTasks`) and renders it in every state. Map tasks are reloaded when teams load (`TeamLoaded`) and whenever `TaskBloc` emits `TaskCreated`, `TaskUpdated`, or `TaskDeleted`.

### Camera State (`lib/features/map/models/map_camera_state.dart`)

```dart
class MapCameraState {
  final double latitude;
  final double longitude;
  final double zoom;
}
```

## Repository (`lib/data/repositories/map_repository.dart`)

### Interface Methods

```dart
abstract class MapRepository {
  Future<bool> isOfflineMode();

  Future<OfflineRegionResult> loadRegionForCurrentLocation({
    double radiusKm,
    int zoomMin,
    int zoomMax,
    double? targetLat, // center on these instead of GPS when provided
    double? targetLon,
  });

  Future<List<OfflineMapRegion>> getDownloadedRegions();
  Future<void> deleteRegion(String regionId);
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

- Embeds Mapbox GL JS (v3.4.0, injected at runtime) in an `HtmlElementView`
- A `ResizeObserver` calls `map.resize()` whenever the container changes size. Without it, maps created mid-route-transition render at Mapbox's 400×300 fallback size.
- `projectLatLonToScreen()` for positioning Flutter marker overlays
- Single-tap (`onTap`) and double-click handlers with lat/lng
- Flutter widgets that sit over the map and take taps must be wrapped in `PointerInterceptor` on web, or the click also reaches the map. The Create Task form sheet does this.

### Mobile Controller (`lib/features/map/mobile/mapbox_mobile_controller.dart`)

- Native Mapbox SDK integration (`MapboxOptions.setAccessToken` from `.env`)
- Native marker support (`updateTaskMarkers`)
- Platform-specific gesture handling

## Map View Widget

`MapboxMapView` (`lib/features/map/widgets/mapbox_map_view.dart`) abstracts platform differences:

```dart
MapboxMapView({
  required double initialLatitude,
  required double initialLongitude,
  double initialZoom = 16,
  OfflineMapRegion? offlineBubble,
  bool isOfflineMode = false,
  List<TaskModel>? tasks,                       // native markers on mobile
  void Function(TaskModel)? onTaskMarkerTap,
  void Function(MapCameraState)? onCameraIdle,
  void Function(MapboxWebController)? onControllerReady,
  void Function(MapboxMobileController)? onMobileControllerReady,
  VoidCallback? onMapReady,
  bool interactive = true,
  void Function(double lat, double lon)? onDoubleClick,
  void Function(double lat, double lon)? onTap,
})
```

On web, `onControllerReady` fires once the map loads; `MapPage` stores the controller with `setState` so the marker overlay can render.

## Task Markers

### Marker Design

Custom pin widget (`_MapPin`) with:
- Circular head showing the priority stars
- Pin point at bottom
- Drop shadow and white border for visibility
- Hover scale effect and tooltip (web)

### Marker Colors

| State | Color |
|-------|-------|
| Active (any priority) | Blue (`AppColors.primary`, `#013576`) |
| Completed | Gray |

### Task Detail Map Pin

The task detail page embeds `MapboxMapView` with `tasks: [widget.task]` and centers the map on the task location via `onMobileControllerReady`. A blue pin is rendered at the task coordinates.

## Data Sources

### MapboxRemoteDataSource

Handles Mapbox API communication: style URL construction, tile URL generation, access token management.

### OfflineMapCache

Local tile storage using Hive: store/retrieve cached tiles, manage cache size.

### FirebaseMapSnapshotSource

Writes the current region's metadata to `mapSnapshots/{uid}` after each refresh. The repo's `firebase/firestore.rules` has an owner-only rule for this collection. Until those rules are deployed, the write fails with `permission-denied`, which is caught and logged; the map is unaffected.

### MapboxSource (`lib/data/sources/mapbox_source.dart`)

Dead code: stub methods with placeholder values, not registered in DI or imported anywhere. Safe to delete.

## Authentication Integration

The map listens to `AuthBloc` state:
- On logout (`AuthUnauthenticated`): disposes map controllers immediately
- On `MapReset`: clears all map state, cancels timers

## Network Behavior

| Connectivity | Behavior |
|--------------|----------|
| Online | Live tiles + offline cache updates |
| Offline | Cached tiles only, no new downloads |
| Transitioning | Automatic sync when connection restored |

## Limitations

- Offline region downloads require an initial online connection
- On a fresh region the map opens at zoom 18 (street level)
- Web markers use overlay positioning (may shift slightly while zooming)
