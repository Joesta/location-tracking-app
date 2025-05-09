import 'dart:async';

import '../utils/service/location_tracker_helper.dart';

class LocationService {
  Timer? _timer;

  void Function(double lat, double lon, DateTime timestamp)? onLocationUpdate;

  Future<void> start() async {
    Timer.periodic(const Duration(seconds: 30), (timer) async {
      await LocationTrackerHelper.updateSummaryWithLocation();
    });
  }

  // Stop periodic updates
  Future<void> stop() async {
    _timer?.cancel();
  }
}
