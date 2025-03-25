import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:serhumano/consts.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Location instance
  Location locationController = Location();

  // Set initial location to the center of the map
  static const LatLng initialLocation = LatLng(37.7749, -122.4194);

  // Another location in map
  static const LatLng anotherLocation = LatLng(37.7599, -122.4148);

  LatLng? currentL;

  GoogleMapController? _mapController; // Controller for GoogleMap

  Map<PolylineId, Polyline> polylines = {};

  @override
  void initState() {
    super.initState();
    currentL = initialLocation; // Set a default location
    getLocationUpdates().then((_) => {
      getPolyLinePoints().then((coordinates) => {
        generatePolyLinesFromPoints(coordinates),
      }),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: currentL == null
          ? const Center(
              child: Text("Loading..."),
            )
          : GoogleMap(
              initialCameraPosition: CameraPosition(
                target: currentL!, // Use the updated currentL value
                zoom: 13,
              ),
              zoomControlsEnabled: true,
              myLocationEnabled: true, // Enable the "My Location" layer
              myLocationButtonEnabled: true, // Enable the "My Location" button
              onMapCreated: (GoogleMapController controller) {
                _mapController = controller; // Assign the controller
              },
              markers: {
                Marker(
                  markerId: MarkerId("currentLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: currentL!, // Use the updated currentL value
                ),
                Marker(
                  markerId: MarkerId("sourceLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: initialLocation,
                ),
                Marker(
                  markerId: MarkerId("destinationLocation"),
                  icon: BitmapDescriptor.defaultMarker,
                  position: anotherLocation,
                ),
              },
              polylines: Set<Polyline>.of(polylines.values),
            ),
    );
  }

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

            // Move the camera to the new location
            _mapController?.animateCamera(
              CameraUpdate.newLatLng(currentL!),
            );
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

  Future<List<LatLng>> getPolyLinePoints() async {
    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    // Use the request object in the function call
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(initialLocation.latitude, initialLocation.longitude),
        destination: PointLatLng(anotherLocation.latitude, anotherLocation.longitude),
        mode: TravelMode.driving,
      ),
    );
    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    }
    else{
      print("Error in getPolyLinePoints: ${result.errorMessage}");
    }

    return polylineCoordinates;
  }

void generatePolyLinesFromPoints(List<LatLng> polylineCoordinates) async{
  PolylineId id = PolylineId("poly");
  Polyline polyline = Polyline(
    polylineId: id, 
    color: Colors.black,
    points: polylineCoordinates,
    width: 8
    );

    setState(() {
      polylines[id] = polyline;
    });
}

}