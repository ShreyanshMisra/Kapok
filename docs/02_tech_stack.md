# Tech Stack

## Flutter & Dart

- **Dart SDK**: ^3.9.2
- **Flutter**: Uses Material Design 3

## Key Dependencies

### Firebase Services
| Package | Version | Purpose |
|---------|---------|---------|
| `firebase_core` | ^4.2.0 | Firebase initialization |
| `firebase_auth` | ^6.1.1 | User authentication |
| `cloud_firestore` | ^6.0.3 | NoSQL database |
| `firebase_storage` | ^13.0.3 | File storage |
| `firebase_crashlytics` | ^5.0.3 | Crash reporting |
| `firebase_analytics` | ^12.0.3 | Usage analytics |

### State Management
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_bloc` | ^9.0.0 | BLoC pattern implementation |
| `equatable` | ^2.0.5 | Value equality for states/events |
| `provider` | ^6.1.1 | Theme and language providers |

### Local Storage
| Package | Version | Purpose |
|---------|---------|---------|
| `hive` | ^2.2.3 | Local NoSQL database |
| `hive_flutter` | ^1.1.0 | Flutter bindings for Hive |
| `path_provider` | ^2.1.2 | File system paths |

### Maps & Location
| Package | Version | Purpose |
|---------|---------|---------|
| `mapbox_maps_flutter` | ^2.3.0 | Interactive maps |
| `geolocator` | ^14.0.2 | GPS location services |
| `geocoding` | ^4.0.0 | Address/coordinate conversion |

### Network & Permissions
| Package | Version | Purpose |
|---------|---------|---------|
| `connectivity_plus` | ^6.0.5 | Network status monitoring |
| `permission_handler` | ^11.3.1 | Runtime permissions |
| `http` | ^1.2.2 | HTTP client |

### Localization
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_localizations` | SDK | Flutter localization support |
| `intl` | ^0.20.2 | Internationalization utilities |
| `translator` | ^1.0.4 | Dynamic text translation |

### Dependency Injection
| Package | Version | Purpose |
|---------|---------|---------|
| `get_it` | ^8.0.0 | Service locator |

### UI & Utilities
| Package | Version | Purpose |
|---------|---------|---------|
| `cupertino_icons` | ^1.0.8 | iOS-style icons |
| `cached_network_image` | ^3.4.1 | Image caching |
| `flutter_spinkit` | ^5.1.0 | Loading animations |
| `share_plus` | ^10.1.1 | Share functionality |
| `url_launcher` | ^6.2.5 | Open URLs |
| `flutter_dotenv` | ^5.1.0 | Environment variables |

### Development Dependencies
| Package | Version | Purpose |
|---------|---------|---------|
| `flutter_test` | SDK | Testing framework |
| `flutter_lints` | ^6.0.0 | Code linting |
| `bloc_test` | ^10.0.0 | BLoC testing utilities |
| `mocktail` | ^1.0.3 | Mocking for tests |
| `build_runner` | ^2.4.9 | Code generation |
| `json_serializable` | ^6.9.0 | JSON serialization |
| `flutter_launcher_icons` | ^0.14.4 | App icon generation |

## Platform Support

### iOS
- Full native support via Mapbox Maps Flutter SDK
- Native location services via Geolocator
- Push notifications capability (not yet implemented)

### Android
- Full native support via Mapbox Maps Flutter SDK
- Native location services via Geolocator
- Push notifications capability (not yet implemented)

### Web
- Mapbox GL JS integration via HtmlElementView
- Limited offline functionality
- JavaScript interop for map controls

## External Services

### Firebase
- Authentication (email/password)
- Firestore for data persistence
- Storage for file uploads
- Crashlytics for error tracking
- Analytics for usage tracking

### Mapbox
- Interactive map rendering
- Tile caching for offline use
- Geocoding and reverse geocoding
- Requires API access token configured in `.env`
