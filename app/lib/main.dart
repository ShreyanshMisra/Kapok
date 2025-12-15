import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kapok_app/injection_container.dart';
import 'package:kapok_app/core/constants/mapbox_constants.dart';
import 'package:kapok_app/core/services/analytics_service.dart';
import 'firebase_options.dart';
import 'features/splash/splash_wrapper.dart';

Future<void> main() async {
  // Run the app in a zone to catch all errors
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Load environment variables from .env file
    try {
      await dotenv.load(fileName: '.env');
      print("✅ Environment variables loaded");

      // Validate required configuration
      MapboxConstants.validateConfiguration();
      print("✅ Environment configuration validated");
    } catch (e) {
      print("❌ Configuration error: $e");
      print("\nPlease ensure you have:");
      print("1. Created a .env file (copy from .env.example)");
      print("2. Added your Mapbox API token");
      print("3. See .env.example for setup instructions");
      rethrow; // Fail loudly on startup if config is invalid
    }

    // Initialize Firebase
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Initialize Firebase Crashlytics
    FlutterError.onError = (errorDetails) {
      FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
    };

    // Pass all uncaught asynchronous errors to Crashlytics
    PlatformDispatcher.instance.onError = (error, stack) {
      FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
      return true;
    };

    await initializeDependencies();
    await initializeCoreServices();

    // Initialize analytics service with privacy preferences
    await AnalyticsService.instance.initialize();

    print("✅ Firebase initialized");
    print("✅ Crashlytics initialized");
    print("✅ Analytics initialized");

    runApp(const SplashWrapper());
  }, (error, stack) {
    // Catch errors that occur outside of Flutter
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
