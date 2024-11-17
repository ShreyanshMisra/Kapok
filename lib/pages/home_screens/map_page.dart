import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:kapok_new/pages/home_screens/create_task_page.dart';
import 'package:kapok_new/pages/home_screens/task_list.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      
      appBar: AppBar(
        title: Text("Map Page"),
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

