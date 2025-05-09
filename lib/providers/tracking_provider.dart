import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../models/daily_summary.dart';
import '../services/location_service.dart';

class TrackingProvider extends ChangeNotifier {
  final ValueNotifier<bool> _isTracking = ValueNotifier(false);
  final LocationService _locationService;

  DailySummary todaySummary = DailySummary(date: '');

  TrackingProvider() : _locationService = LocationService() {
    // Set up location update callback
    _locationService.onLocationUpdate = _handleLocationUpdate;
    todaySummary =
        DailySummary(date: DateTime.now().toIso8601String().split('T').first);
  }

  bool get isTracking => _isTracking.value;

  // Start tracking
  Future<void> clockIn() async {
    _isTracking.value = true;
    await _locationService.start();
    notifyListeners();
  }

  // Stop tracking
  Future<void> clockOut() async {
    _isTracking.value = false;
    await _locationService.stop();
    todaySummary.endDay();

    final box = await Hive.openBox<DailySummary>('summaries');
    await box.put(todaySummary.date, todaySummary);

    notifyListeners();
  }

  // Handle location updates from LocationService
  void _handleLocationUpdate(double lat, double lon, DateTime timestamp) {
    todaySummary.updateWithLocation(lat, lon, timestamp);
    notifyListeners();
  }
}
