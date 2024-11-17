import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/auth_page/login_page.dart';
import 'package:kapok_new/pages/auth_page/sign_up_page.dart';
import 'package:kapok_new/pages/home_screens/create_task_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'Flutter Demo',
      debugShowCheckedModeBanner: false,
      home: LoginPage(),  //change MyApp to your page name to see your page output
    );
  }
}