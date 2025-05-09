import 'package:geolocator/geolocator.dart';
import 'package:location_tracking_app/utils/constants.dart';

class GeoFenceService {
  /// Returns distance from home in meters
  double distanceFromHome(double lat, double lon) {
    return Geolocator.distanceBetween(
        lat, lon, Constants.homeLat, Constants.homeLon);
  }

  /// Returns distance from office in meters
  double distanceFromOffice(double lat, double lon) {
    return Geolocator.distanceBetween(
        lat, lon, Constants.officeLat, Constants.officeLon);
  }

  /// Checks if the location is within the home geofence
  bool isAtHome(double lat, double lon) {
    return distanceFromHome(lat, lon) <= Constants.radius;
  }

  /// Checks if the location is within the office geofence
  bool isAtOffice(double lat, double lon) {
    return distanceFromOffice(lat, lon) <= Constants.radius;
  }

  /// Determines location category: 'home', 'office', or 'traveling'
  String classifyLocation(double lat, double lon) {
    if (isAtHome(lat, lon)) return 'home';
    if (isAtOffice(lat, lon)) return 'office';
    return 'traveling';
  }
}
