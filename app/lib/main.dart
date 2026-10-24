import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_crashlytics/firebase_crashlytics.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kapok_app/injection_container.dart';
import 'package:kapok_app/core/constants/mapbox_constants.dart';
import 'package:kapok_app/core/services/analytics_service.dart';
import 'package:kapok_app/core/utils/logger.dart';
import 'firebase_options.dart';
import 'features/splash/splash_wrapper.dart';

Future<void> main() async {
  runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    try {
      await dotenv.load(fileName: '.env');
      Logger.startup('Environment variables loaded');

      MapboxConstants.validateConfiguration();
      Logger.startup('Environment configuration validated');
    } catch (e, stack) {
      Logger.error(
        'Configuration error. Ensure .env exists (copy from .env.example) and contains a Mapbox token.',
        error: e,
        stackTrace: stack,
      );
      rethrow;
    }

    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

    // Crashlytics has no web implementation; calling it there throws an
    // assertion on every reported error, so keep Flutter's default handlers.
    if (!kIsWeb) {
      FlutterError.onError = (errorDetails) {
        FirebaseCrashlytics.instance.recordFlutterFatalError(errorDetails);
      };

      PlatformDispatcher.instance.onError = (error, stack) {
        FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
        return true;
      };
    }

    await initializeDependencies();
    await initializeCoreServices();

    await AnalyticsService.instance.initialize();

    Logger.startup('Firebase, Crashlytics, and Analytics initialized');

    runApp(const SplashWrapper());
  }, (error, stack) {
    if (kIsWeb) {
      Logger.error('Uncaught error', error: error, stackTrace: stack);
      return;
    }
    FirebaseCrashlytics.instance.recordError(error, stack, fatal: true);
  });
}
