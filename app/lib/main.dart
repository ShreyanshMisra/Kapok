import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:kapok_app/injection_container.dart';
import 'firebase_options.dart';
import 'app/kapok_app.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  await initializeDependencies();
  await initializeCoreServices();
  print("✅ Firebase initialized");
  runApp(const KapokApp());
}