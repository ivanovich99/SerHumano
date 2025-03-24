import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';


class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Location instance
  Location locationController = new Location();

  // Set initial location to the center of the map
  static const LatLng initialLocation = LatLng(37.7749, -122.4194);

  // Another location in map
  static const LatLng anotherLocation = LatLng(37.7599, -122.4148);

  LatLng? currentL = null;

  @override
  void initState() {
    super.initState();

    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // If current position is null, show loading; otherwise, show the map
      body: currentL == null
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentL!, // Use the updated currentL value
                zoom: 13,
              ),
              zoomControlsEnabled: true, // Enable zoom in/out buttons
              markers: {
                Marker(
                  markerId: MarkerId("currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentL!, // Use the updated currentL value
                ),
                Marker(
                  markerId: MarkerId("anotherLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: anotherLocation,
                ),
              },
            ),
    );
  }

  // Add a method to get the current location
  Future<void> getLocationUpdates() async {
    try {
      // Check if location services are enabled
      bool serviceEnabled = await locationController.serviceEnabled();
      if (!serviceEnabled) {
        serviceEnabled = await locationController.requestService();
        if (!serviceEnabled) {
          print("Location services are disabled.");
          setState(() {
            currentL = initialLocation; // Fallback to initial location
          });
          return;
        }
      }

      // Check for location permissions
      PermissionStatus permissionGranted = await locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print("Location permissions are denied.");
          setState(() {
            currentL = initialLocation; // Fallback to initial location
          });
          return;
        }
      }

      // Listen for location updates
      locationController.onLocationChanged.listen((LocationData currentLocation) {
        print("Location update received: ${currentLocation.latitude}, ${currentLocation.longitude}");
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          setState(() {
            currentL = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            print("Current location: $currentL");
          });
        }
      });
    } catch (e) {
      print("Error in getLocationUpdates: $e");
      setState(() {
        currentL = initialLocation; // Fallback to initial location
      });
    }
  }
}