import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:kapok_new/pages/auth_page/login_page.dart';
import 'package:kapok_new/pages/auth_page/sign_up_page.dart';
import 'package:kapok_new/pages/home_screens/create_task_page.dart';
import 'package:kapok_new/pages/home_screens/map_page.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();

  await dotenv.load(fileName: ".env");
  MapboxOptions.setAccessToken('pk.eyJ1IjoiZW1tZXRoYW1lbGwiLCJhIjoiY201NWhtOWFxMzYxczJqcHRueHNpNG40NiJ9.mANCSDfoAA9Xtr2oAqM0EQ');
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
      home: const MapPage(),  //change MyApp to your page name to see your page output
    );
  }
}