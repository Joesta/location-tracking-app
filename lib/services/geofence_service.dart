import 'package:geolocator/geolocator.dart';

class GeoFence {
  final String name;
  final double lat;
  final double lon;

  GeoFence(this.name, this.lat, this.lon);
}

class GeoFenceService {
  final List<GeoFence> fences = [
    GeoFence("Home", 28.2102213, -25.7456269),
    GeoFence("Office", 28.15123237829154, -25.9169722),
  ];

  List<String> getCurrentFences(double lat, double lon) {
    List<String> result = [];
    for (var fence in fences) {
      final dist = Geolocator.distanceBetween(lat, lon, fence.lat, fence.lon);
      if (dist <= 50) result.add(fence.name);
    }
    return result;
  }
}
