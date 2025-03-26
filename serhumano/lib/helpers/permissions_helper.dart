import 'package:location/location.dart';

class PermissionsHelper {
  final Location locationController;

  PermissionsHelper(this.locationController);

  Future<bool> checkAndRequestPermissions() async {
    // Check if location services are enabled
    bool serviceEnabled = await locationController.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await locationController.requestService();
      if (!serviceEnabled) {
        print("Location services are disabled.");
        return false;
      }
    }

    // Check for location permissions
    PermissionStatus permissionGranted = await locationController.hasPermission();
    if (permissionGranted == PermissionStatus.denied) {
      permissionGranted = await locationController.requestPermission();
      if (permissionGranted != PermissionStatus.granted) {
        print("Location permissions are denied.");
        return false;
      }
    }

    return true;
  }
}