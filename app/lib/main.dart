import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kapok_app/injection_container.dart';
import 'firebase_options.dart';
import 'app/kapok_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables from .env file
  try {
    await dotenv.load(fileName: '.env');
    print("✅ Environment variables loaded");
  } catch (e) {
    print("⚠️ Warning: Could not load .env file: $e");
    print("⚠️ Make sure .env file exists in the app root directory");
  }

  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await initializeDependencies();
  await initializeCoreServices();
  print("✅ Firebase initialized");
  runApp(const KapokApp());
}
