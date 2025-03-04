import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:kapok_new/pages/home_screens/create_task_page.dart';
import 'package:kapok_new/pages/home_screens/task_list.dart';
import 'package:location/location.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  LocationData? currentLocation;
  GoogleMapController? mapController; // Make nullable
  final Set<Polyline> _polylines = {};
  bool _isLoading = true; // Add loading state

  Future<void> getCurrentLocation() async {
    Location location = Location();
    bool serviceEnabled;
    PermissionStatus permissionGranted;

    try {
      // Check if location service is enabled
      serviceEnabled = await location.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await location.requestService();
        if (!serviceEnabled) {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Check location permission
      permissionGranted = await location.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await location.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          setState(() => _isLoading = false);
          return;
        }
      }

      // Get location
      final locationData = await location.getLocation();
      setState(() {
        currentLocation = locationData;
        _isLoading = false;
      });

      // Listen to location changes
      location.onLocationChanged.listen((newLocation) {
        if (mounted) {
          setState(() => currentLocation = newLocation);
        }
      });
    } catch (e) {
      print("Error getting location: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    getCurrentLocation();
  }

  @override
  void dispose() {
    mapController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
            "Map Page",
          style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
              color: Colors.white
          ),
        ),
        automaticallyImplyLeading: false,
        backgroundColor: Color(0xFF083677),
      ),
      body: Stack(
        children: [
          SizedBox(
            height: MediaQuery.of(context).size.height,
            width: MediaQuery.of(context).size.width,
            child: GoogleMap(
              initialCameraPosition: CameraPosition(
                  target: LatLng(
                    42.3909,
                    -72.5257,
                  ),
                  zoom: 18
              ),
              myLocationEnabled: true,
              myLocationButtonEnabled: true,
              onMapCreated: (GoogleMapController controller) {
                if (mounted) {
                  setState(() => mapController = controller);
                }
                print("Map Controller created");
              },
              markers: {
                Marker(
                  markerId: const MarkerId("CurrentLocation"),
                  position: LatLng(
                    42.3909,
                    -72.5257,
                  ),
                ),
              },
              polylines: _polylines,
            ),
          ),
        ],
      ),
      bottomNavigationBar: BottomAppBar(
        height: 60,
        color: Color(0xFF083677),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            IconButton(
                onPressed: () => Get.to(() => TaskListPage()),
                icon: const Icon(Icons.list, size: 30, color: Colors.white,)
            ),
            IconButton(
                onPressed: () => Get.to(() => CreateTaskPage()),
                icon: const Icon(Icons.create, size: 30, color: Colors.white,)
            ),
          ],
        ),
      ),
    );
  }
}
