import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/home_screens/create_task_page.dart';
import 'package:kapok_new/pages/home_screens/task_list.dart';
import 'package:mapbox_maps_flutter/mapbox_maps_flutter.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  late MapboxMap mapboxMap;

  @override
  void initState() {
    super.initState();
    MapboxOptions.setAccessToken('pk.eyJ1IjoiZW1tZXRoYW1lbGwiLCJhIjoiY201NWhtOWFxMzYxczJqcHRueHNpNG40NiJ9.mANCSDfoAA9Xtr2oAqM0EQ');
  }

  @override
  Widget build(BuildContext context) {
    CameraOptions camera = CameraOptions(
    center: Point(coordinates: Position(-98.0, 39.5)),
    zoom: 2,
    bearing: 0,
    pitch: 0,
    );

    return Scaffold(
      appBar: AppBar(
        title: Text("Map Page"),
      ),
      
      body: MapWidget(
        mapOptions: MapOptions(
          pixelRatio: MediaQuery.of(context).devicePixelRatio, 
        ),
        cameraOptions: camera,
        onMapCreated: (MapboxMap map) {
          mapboxMap = map;
        },
      ),

      bottomNavigationBar: BottomAppBar(
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
                onPressed: (){
                  Get.to(TaskListPage());
                },
                icon: Icon(Icons.list)),
            IconButton(
                onPressed: (){
                  Get.to(CreateTaskPage());
                },
                icon: Icon(Icons.create)),
          ],
        ),
      ),
    );
  }
}

