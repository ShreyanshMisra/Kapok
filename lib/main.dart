import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/auth_page/login_page.dart';
import 'package:kapok_new/pages/home_screens/create_task_page.dart';
import 'package:kapok_new/pages/home_screens/map_page.dart';
import 'package:kapok_new/pages/home_screens/task_list.dart';
import 'controllers/authentication_controller.dart';

void main() async {
  // Make sure to add async here
  // Ensure Flutter is initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Firebase first
  await Firebase.initializeApp(
    options: const FirebaseOptions(
      apiKey: 'AIzaSyCFnRLnhX5DPOuNPoxOXYTutSwmPHStKF4',
      appId: '1:460785395316:ios:c0faa8798b7f865a8e1321',
      messagingSenderId: '460785395316',
      projectId: 'kapok-3dee3',
      storageBucket: 'kapok-3dee3.firebasestorage.app',
    ),
  );

  // Initialize AuthenticationController
  Get.put(AuthenticationController());

  // Run the app
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: LoginPage(), //revert to LoginPage() again
    );
  }
}
