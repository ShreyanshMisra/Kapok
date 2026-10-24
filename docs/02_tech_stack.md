# Tech Stack

_Last verified against the codebase: 2026-10-24 (`app/pubspec.yaml`, version `1.0.0+2`)._

## Flutter & Dart

- **Flutter**: 3.35.x (stable), Material Design 3
- **Dart SDK**: ^3.9.2

The FlutterFire packages are capped below the releases that adopted the iOS UIScene API, which needs Flutter ≥ 3.38. Lift the caps in `pubspec.yaml` after upgrading the Flutter SDK.

## Key Dependencies

### Firebase Services
| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | >=4.2.0 <4.6.0 | Firebase initialization |
| `firebase_auth` | >=6.1.1 <6.3.0 | Email/password authentication |
| `cloud_firestore` | >=6.1.3 <6.2.0 | NoSQL database |
| `firebase_storage` | >=13.1.0 <13.2.0 | File storage (wired in `FirebaseService`; no upload UI yet) |
| `firebase_crashlytics` | >=5.0.8 <5.1.0 | Crash reporting (iOS/Android only; skipped on web) |
| `firebase_analytics` | >=12.0.3 <12.2.0 | Usage analytics |

### State Management
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.1.1 | BLoC pattern implementation |
| `equatable` | ^2.1.0 | Value equality for states/events |
| `provider` | ^6.1.5+1 | Theme and language providers |

### Local Storage
| Package | Version | Purpose |
|---------|---------|---------|
| `hive` | ^2.2.3 | Local NoSQL database (offline cache, sync queue, settings) |
| `hive_flutter` | ^1.1.0 | Flutter bindings for Hive |
| `path_provider` | ^2.1.5 | File system paths |

### Maps & Location
| Package | Version | Purpose |
|---------|---------|---------|
| `mapbox_maps_flutter` | ^2.31.1 | Interactive maps (iOS/Android) |
| `pointer_interceptor` | ^0.10.1+2 | Stops taps on Flutter overlays from reaching the Mapbox GL JS view on web |
| `geolocator` | ^14.0.2 | GPS location and permission requests |
| `geocoding` | ^4.0.0 | Platform address/coordinate conversion |

### Network
| Package | Version | Purpose |
|---------|---------|---------|
| `connectivity_plus` | ^6.1.5 | Network status monitoring |
| `http` | ^1.6.0 | HTTP client (Mapbox Geocoding API) |

### Localization
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_localizations` | SDK | Flutter localization support |
| `intl` | ^0.20.2 | Date formatting / i18n utilities |
| `translator` | ^1.0.4+1 | `LanguageService.translateText` (machine translation); not currently called from any UI |

### Dependency Injection
| Package | Version | Purpose |
|---------|---------|---------|
| `get_it` | ^8.3.0 | Service locator (`lib/injection_container.dart`) |

### UI & Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| `cupertino_icons` | ^1.0.9 | iOS-style icons |
| `share_plus` | ^10.1.4 | Share team codes and tasks |
| `flutter_dotenv` | ^5.2.1 | Loads `app/.env` (bundled as an asset) |
| `json_annotation` | ^4.9.0 | JSON serialization annotations |
| `fl_chart` | ^0.69.2 | Charts on the Analytics page |
| `badges` | ^3.2.0 | Pending-task count badge on the Tasks tab |
| `confetti` | ^0.7.0 | Celebration animation when a task is completed |

### Development Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Unit and widget testing |
| `integration_test` | SDK | On-device integration tests |
| `flutter_lints` | ^6.0.0 | Lint rules |
| `bloc_test` | ^10.0.0 | BLoC testing utilities |
| `mocktail` | ^1.0.5 | Mocking for tests |
| `build_runner` | ^2.7.1 | Code generation |
| `json_serializable` | ^6.11.2 | JSON serialization codegen |
| `flutter_launcher_icons` | ^0.14.4 | App icon generation |
| `flutter_native_splash` | ^2.4.7 | Android splash screen generation |

## Platform Support

### iOS
- **iPhone only** (`TARGETED_DEVICE_FAMILY = 1`), portrait only, minimum iOS 15.0
- Bundle ID `com.afairresolution.kapok`, Apple team `9M48UX3QW7`, automatic signing
- Native maps via the Mapbox Maps SDK; location via Geolocator (while-in-use only)
- App privacy manifest at `ios/Runner/PrivacyInfo.xcprivacy`
- Build with Xcode 26+ (required by App Store Connect)

### Android
- Application ID / namespace `com.afairresolution.kapok`
- `minSdk` 24, `compileSdk`/`targetSdk` 36 (Flutter 3.35 defaults)
- Release signing from `android/key.properties` (gitignored); Mapbox token injected at build time
- Branded splash via `flutter_native_splash`

### Web (limited, used for development/QA)
- Mapbox GL JS embedded via `HtmlElementView` (`lib/features/map/web/`)
- Task pins are Flutter overlays positioned with `map.project()`
- No Crashlytics; reverse geocoding falls back to coordinates
- Not a supported release target

## External Services

### Firebase (project `build-kapok`)
- Authentication (email/password)
- Firestore for data persistence (rules in `firebase/firestore.rules`)
- Storage (configured, not yet used by any UI)
- Crashlytics for crash reporting
- Analytics for usage tracking

### Mapbox
- Interactive map rendering (native SDK on mobile, GL JS on web)
- Offline tile caching around the user's location
- Forward/reverse geocoding via the Mapbox Geocoding API (`GeocodeService`)
- Requires a public access token (`pk.*`) in `app/.env` as `MAPBOX_ACCESS_TOKEN`, and for Android release builds also in `key.properties` or the environment
