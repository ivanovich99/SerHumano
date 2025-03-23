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
    // View of widget Google Maps API
    return Scaffold(
      body: GoogleMap(
        initialCameraPosition: CameraPosition(
          target: initialLocation,
          zoom: 13,
        ),
        zoomControlsEnabled: true, // Enable zoom in/out buttons
        markers: {
          Marker(
            markerId: MarkerId("currentLocation"),
            icon: BitmapDescriptor.defaultMarker,
            position: initialLocation,
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
          return; // Exit if the user denies enabling location services
        }
      }

      // Check for location permissions
      PermissionStatus permissionGranted = await locationController.hasPermission();
      if (permissionGranted == PermissionStatus.denied) {
        permissionGranted = await locationController.requestPermission();
        if (permissionGranted != PermissionStatus.granted) {
          print("Location permissions are denied.");
          return; // Exit if the user denies permissions
        }
      }

      // Listen for location updates
      locationController.onLocationChanged.listen((LocationData currentLocation) {
        if (currentLocation.latitude != null && currentLocation.longitude != null) {
          setState(() {
            currentL = LatLng(currentLocation.latitude!, currentLocation.longitude!);
            print("Current location: $currentL");
          });
        }
      });
    } catch (e) {
      print("Error in getLocationUpdates: $e");
    }
  }
}