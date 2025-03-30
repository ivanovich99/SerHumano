import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location/location.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:serhumano/consts.dart';
import 'package:serhumano/hospitals_list.dart';
import 'package:serhumano/hospitals_choice.dart';
import 'package:serhumano/helpers/permissions_helper.dart';

class MapPage extends StatefulWidget {
  const MapPage({super.key});

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  // Location instance
  Location locationController = Location();
  late PermissionsHelper permissionsHelper;

  // Set initial location to the center of the map
  static const LatLng initialLocation = LatLng(32.507443817279736, -116.92798845463564);

  // Destination location
  LatLng destinationLocation = LatLng(32.50761951262851, -116.92793826234407);

  LatLng? currentL;

  GoogleMapController? _mapController; // Controller for GoogleMap

  Map<PolylineId, Polyline> polylines = {};

  bool isCameraMoving = false;

  String? selectedHospitalId;

  // Add a variable to track the selected sector filter
  String? selectedSectorFilter; // "Public" or "Private" or null (no filter)

  @override
  void initState() {
    super.initState();
    permissionsHelper = PermissionsHelper(locationController);
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: currentL == null
                    ? const Center(
                        child: Text("Loading..."),
                      )
                    : GoogleMap(
                        initialCameraPosition: CameraPosition(
                          target: currentL!,
                          zoom: 15,
                        ),
                        zoomControlsEnabled: true,
                        myLocationEnabled: true,
                        myLocationButtonEnabled: true,
                        onMapCreated: (GoogleMapController controller) {
                          _mapController = controller;
                        },
                        onCameraMove: (CameraPosition position) {
                          isCameraMoving = true;
                        },
                        onCameraIdle: () {
                          isCameraMoving = false;
                        },
                        markers: getFilteredMarkers(), // Use filtered markers
                        polylines: Set<Polyline>.of(polylines.values),
                      ),
              ),
            ],
          ),
          // Top center UI for current location and destination
          Positioned(
            top: 60,
            left: 16,
            right: 16,
            child: Column(
              children: [
                // Current location text field
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Solid background color
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50), // Slight shadow
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: TextField(
                    readOnly: true,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold, // Bold text
                    ),
                    decoration: InputDecoration(
                      hintText: "Current Location",
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                      prefixIcon: const Icon(Icons.my_location),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                // Destination text field with a "Clear" button
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white, // Solid background color
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withAlpha(50), // Slight shadow
                        offset: const Offset(0, 2),
                        blurRadius: 4,
                      ),
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextField(
                          readOnly: true,
                          onTap: () async {
                            final selectedHospital = await showModalBottomSheet(
                              context: context,
                              isScrollControlled: true,
                              shape: const RoundedRectangleBorder(
                                borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                              ),
                              builder: (context) {
                                return SizedBox(
                                  height: MediaQuery.of(context).size.height * 0.8,
                                  child: const HospitalListScreen(),
                                );
                              },
                            );

                            if (selectedHospital != null) {
                              setState(() {
                                destinationLocation = LatLng(
                                  selectedHospital.latitude,
                                  selectedHospital.longitude,
                                );
                                getPolyLinePoints(); // Generate the polyline only after a hospital is selected
                                selectedHospitalId = selectedHospital.name; // Update the destination label
                              });
                            }
                          },
                          style: const TextStyle(
                            fontWeight: FontWeight.bold, // Bold text
                          ),
                          decoration: InputDecoration(
                            labelText: "Destination",
                            hintText: selectedHospitalId ?? "Choose a hospital...", // Dynamically update the hint
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            prefixIcon: const Icon(Icons.local_hospital),
                            suffixIcon: selectedHospitalId != null
                                ? IconButton(
                                    icon: const Icon(Icons.clear, color: Colors.red),
                                    onPressed: () {
                                      setState(() {
                                        destinationLocation = initialLocation; // Reset destination
                                        polylines.clear(); // Remove the polyline
                                        selectedHospitalId = null; // Clear the selected hospital
                                      });
                                    },
                                  )
                                : null, // Show the clear button only if a hospital is selected
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Filter buttons
          Positioned(
            bottom: 80,
            right: 8, // Adjusted to align with the default Google Maps location button
            child: Column(
              children: [
                FloatingActionButton(
                  heroTag: "public",
                  onPressed: () {
                    setState(() {
                      selectedSectorFilter = "Public";
                    });
                  },
                  backgroundColor: selectedSectorFilter == "Public"
                      ? Colors.green
                      : Colors.grey,
                  child: const Icon(Icons.public),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "private",
                  onPressed: () {
                    setState(() {
                      selectedSectorFilter = "Private";
                    });
                  },
                  backgroundColor: selectedSectorFilter == "Private"
                      ? Colors.blue
                      : Colors.grey,
                  child: const Icon(Icons.lock),
                ),
                const SizedBox(height: 8),
                FloatingActionButton(
                  heroTag: "clear",
                  onPressed: () {
                    setState(() {
                      selectedSectorFilter = null; // Clear the filter
                    });
                  },
                  backgroundColor: selectedSectorFilter == null
                      ? Colors.red
                      : Colors.grey,
                  child: const Icon(Icons.clear),
                ),
              ],
            ),
          ),
          // Floating action button for hospital list
          Positioned(
            bottom: 16,
            left: MediaQuery.of(context).size.width / 2 - 28,
            child: FloatingActionButton(
              onPressed: () async {
                final selectedHospital = await showModalBottomSheet(
                  context: context,
                  isScrollControlled: true,
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  builder: (context) {
                    return SizedBox(
                      height: MediaQuery.of(context).size.height * 0.78,
                      child: const HospitalListScreen(),
                    );
                  },
                );

                if (selectedHospital != null) {
                  setState(() {
                    destinationLocation = LatLng(
                      selectedHospital.latitude,
                      selectedHospital.longitude,
                    );
                    selectedHospitalId = selectedHospital.name; // Update the destination label
                    getPolyLinePoints();
                  });
                }
              },
              backgroundColor: Colors.deepOrange,
              child: const Icon(Icons.assistant_navigation, color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> getLocationUpdates() async {
    try {
      // Use the PermissionsHelper to check and request permissions
      bool permissionsGranted = await permissionsHelper.checkAndRequestPermissions();
      if (!permissionsGranted) {
        setState(() {
          currentL = initialLocation; // Fallback to initial location
        });
        return;
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
    }
  }

  Future<void> getPolyLinePoints() async {
    if (currentL == null) {
      print("Current location is not available yet.");
      return; // Exit if currentL is not ready
    }

    PolylinePoints polylinePoints = PolylinePoints();
    List<LatLng> polylineCoordinates = [];

    // Use the current location as the origin
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
      generatePolyLinesFromPoints(polylineCoordinates);
    } else {
      print("Error in getPolyLinePoints: ${result.errorMessage}");
    }
  }

  void generatePolyLinesFromPoints(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("poly");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.deepOrange,
      width: 8,
      points: polylineCoordinates,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  // Filter markers based on the selected sector
  Set<Marker> getFilteredMarkers() {
    if (selectedSectorFilter == null) {
      return hospitalMarkers; // Show all markers if no filter is selected
    }
    return hospitals
        .where((hospital) => hospital.sector == selectedSectorFilter)
        .map((hospital) => hospital.createMarker())
        .toSet();
  }
}