import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:serhumano/consts.dart';
import 'package:serhumano/hospitals_list.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Location instance
  Location locationController = Location();

  // Set initial location to the center of the map
  static const LatLng initialLocation = LatLng(32.507443817279736, -116.92798845463564);

  // Destination location
  LatLng destinationLocation = LatLng(32.50761951262851, -116.92793826234407);

  LatLng? currentL;

  GoogleMapController? _mapController; // Controller for GoogleMap

  Map<PolylineId, Polyline> polylines = {};

  bool isCameraMoving = false;

  String? selectedHospitalId;

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Select a Hospital"),
      ),
      body: Column(
        children: [
          // Dropdown for hospital selection
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: DropdownButton<String>(
              value: selectedHospitalId,
              hint: const Text("Select a Hospital"),
              items: hospitals.map((hospital) {
                return DropdownMenuItem<String>(
                  value: hospital.id,
                  child: Text(hospital.name),
                );
              }).toList(),
              onChanged: (String? newHospitalId) {
                if (currentL == null) {
    print("Ubicación actual aún no disponible.");
    return;
  }
                setState(() {
                  selectedHospitalId = newHospitalId;

                  // Update destinationLocation based on the selected hospital
                  Hospital selectedHospital = hospitals.firstWhere((hospital) => hospital.id == newHospitalId!);
                  destinationLocation = LatLng(selectedHospital.latitude, selectedHospital.longitude);

                  // Recalculate the route
                  getPolyLinePoints();
                });
              },
            ),
          ),
          Expanded(
            child: currentL == null
                ? const Center(
                    child: Text("Loading..."),
                  )
                : GoogleMap(
                    initialCameraPosition: CameraPosition(
                      target: currentL!, // Use the updated currentL value
                      zoom: 15,
                    ),
                    zoomControlsEnabled: true,
                    myLocationEnabled: true, // Enable the "My Location" layer
                    myLocationButtonEnabled: true, // Enable the "My Location" button
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller; // Assign the controller
                    },
                    onCameraMove: (CameraPosition position) {
                      isCameraMoving = true; // User is manually moving the camera
                    },
                    onCameraIdle: () {
                      isCameraMoving = false; // User has stopped moving the camera
                    },
                    markers: hospitalMarkers, // List of all hospitals
                    polylines: Set<Polyline>.of(polylines.values),
                  ),
          ),
        ],
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

            // Only move the camera if the user is not manually moving it
            if (!isCameraMoving) {
              _mapController?.animateCamera(
                CameraUpdate.newLatLng(currentL!),
              );
            }

            // Update the route dynamically
            getPolyLinePoints();
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

  Future<void> getPolyLinePoints() async {
    if (currentL == null) {
      print("Current location is not available yet.");
      return; // Exit if currentL is not ready
    }

    List<LatLng> polylineCoordinates = [];
    PolylinePoints polylinePoints = PolylinePoints();

    // Use the current location as the origin
    PolylineResult result = await polylinePoints.getRouteBetweenCoordinates(
      googleApiKey: GOOGLE_MAPS_API_KEY,
      request: PolylineRequest(
        origin: PointLatLng(currentL!.latitude, currentL!.longitude), // Use real-time location
        destination: PointLatLng(destinationLocation.latitude, destinationLocation.longitude),
        mode: TravelMode.walking,
      ),
    );

    if (result.points.isNotEmpty) {
      for (var point in result.points) {
        polylineCoordinates.add(LatLng(point.latitude, point.longitude));
      }
    } else {
      print("Error in getPolyLinePoints: ${result.errorMessage}");
    }

    generatePolyLinesFromPoints(polylineCoordinates);
  }

  void generatePolyLinesFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepOrange,
      points: polylineCoordinates,
      width: 8,
    );

    setState(() {
      polylines[id] = polyline;
    });
  }
}