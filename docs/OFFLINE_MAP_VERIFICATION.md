# Offline Map System Verification & Improvements

## Implementation Verification

After reviewing the codebase, the offline map system **largely matches** the described behavior:

### ✅ Verified Components

1. **Initialization Flow**
   - ✅ `MapPage` dispatches `MapStarted` event on init
   - ✅ `MapBloc` checks Hive for cached `OfflineMapRegion`
   - ✅ If found, emits `MapReady` immediately
   - ✅ If not found, triggers `OfflineBubbleRefreshRequested`

2. **Region Loading**
   - ✅ `loadRegionForCurrentLocation()` gets GPS position
   - ✅ Computes 3-mile radius (4.8 km) bounding box
   - ✅ Creates `OfflineMapRegion` covering zoom levels 13-18
   - ✅ Phase 1: Primes center tile + 3×3 grid at zoom 18
   - ✅ Phase 2: Background download of all tiles with progress updates

3. **Tile Fetching Logic**
   - ✅ `getTile()` follows offline-first pattern:
     - Checks Hive cache first
     - Then in-memory LRU cache (max 500 tiles)
     - Then Mapbox if online
   - ✅ `_isTileInOfflineBubble()` checks if tile should be persisted
   - ✅ Tiles inside bubble → persisted to Hive
   - ✅ Tiles outside bubble → only in-memory LRU cache

4. **Offline Enforcement**
   - ✅ `MapboxWebController` uses `transformRequest` callback
   - ✅ `_shouldBlockUrl()` checks if tile is outside bubble when offline
   - ✅ Returns empty `data:,` URI for blocked tiles

5. **Auto-Refresh Mechanism**
   - ✅ 5-minute Timer in `MapBloc`
   - ✅ GPS movement threshold check (~0.5 miles / 804.672 meters)
   - ✅ `_startNewBubble()` computes new bubble
   - ✅ `clearOutside()` purges tiles outside new bubble

### ⚠️ Potential Issues

1. **Web Tile Caching**
   - The `MapboxWebController` uses `transformRequest` to block URLs when offline, but it doesn't actually serve tiles from the Hive cache. Mapbox GL JS fetches tiles directly, bypassing the repository's `getTile()` method.
   - **Impact**: On web, tiles may not be served from cache even when available. The blocking mechanism works, but cached tiles aren't being utilized.
   - **Recommendation**: Consider implementing a custom tile source that serves from Hive cache for web platform.

2. **Bounding Box Visualization**
   - The current overlay painters use simplified rectangles rather than accurate lat/lon-to-screen coordinate conversion.
   - **Impact**: Visual indicators show approximate regions, not exact boundaries.
   - **Recommendation**: Implement proper map projection calculations for accurate rendering.

## Improvements Implemented

### 1. Visual Cached Region Preview in Cache Tab
   - Added a map preview widget in `MapCachePage` showing the cached region
   - Displays center point and approximate bounding box
   - Shows region metadata overlay

### 2. Offline Mode Test Toggle
   - Added test mode override to `NetworkChecker` for testing offline functionality
   - Added toggle button in `MapPage` to simulate offline mode
   - Allows visual testing without disconnecting from network

### 3. Cached Region Overlay
   - Added overlay toggle button in `MapPage`
   - Shows visual indicator of cached region bounds
   - Displays different styling when in offline mode
   - Shows zoom level range and status

### 4. Enhanced Status Indicators
   - Improved `MapStatusCard` to show offline status
   - Added visual feedback for test mode
   - Clear indication of cached vs live tiles

## Testing Instructions

### To Test Offline Functionality:

1. **Enable Test Offline Mode**:
   - Open the Map page
   - Click the "Test Offline" toggle in the top-right corner
   - The map should now block tiles outside the cached bubble

2. **View Cached Region**:
   - Click the layers icon to show the cached region overlay
   - The overlay shows the approximate bounds of cached tiles
   - Pan the map to see which areas are cached vs live

3. **Check Cache Tab**:
   - Navigate to the Cache tab (storage icon in app bar)
   - View the map preview showing the cached region
   - See detailed region information including:
     - Center coordinates
     - Bounding box
     - Zoom range
     - Tile count
     - Last sync time

### Visual Indicators:

- **Green/Blue overlay**: Cached region (online mode)
- **Orange/Red overlay**: Offline mode - only cached region available
- **Center marker**: Region center point
- **Border**: Approximate bounding box

## Notes

- The bounding box visualization is simplified and shows approximate regions. For production use, implement proper map projection calculations.
- The web platform may not fully utilize cached tiles due to Mapbox GL JS's direct tile fetching. Consider implementing a custom tile source for better cache utilization.
- The test offline mode override is useful for development but should be removed or protected in production builds.

