import 'dart:async';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import '../models/daily_summary.dart';

class LocationService {
  Timer? _timer;
  DateTime? _lastUpdate;
  void Function(double, double, DateTime)? onLocationUpdate;

  // home and office coordinates and radius for tracking
  static const home = (28.2102213, -25.7456269);
  static const office = (28.15123237829154, -25.9169722);
  static const radius = 50.0;

  // Start tracking the user's location and send updates to TrackingProvider
  Future<void> start() async {
    _lastUpdate = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 30), (_) async {
      final pos = await Geolocator.getCurrentPosition();
      final now = DateTime.now();
      final delta = now.difference(_lastUpdate!);
      _lastUpdate = now;

      final homeDist = Geolocator.distanceBetween(pos.latitude, pos.longitude, home.$1, home.$2);
      final officeDist = Geolocator.distanceBetween(pos.latitude, pos.longitude, office.$1, office.$2);

      // Determine whether the user is home, at the office, or traveling
      String locationType = 'traveling';
      if (homeDist <= radius) {
        locationType = 'home';
      } else if (officeDist <= radius) {
        locationType = 'office';
      }

      // Trigger location update in the provider
      onLocationUpdate?.call(pos.latitude, pos.longitude, now);

      // Update the daily summary in Hive
      final box = await Hive.openBox<DailySummary>('summaries');
      final dateKey = now.toIso8601String().split('T')[0];
      final summary = box.get(dateKey) ?? DailySummary(date: dateKey);

      if (locationType == 'home') {
        summary.homeSeconds += delta.inSeconds;
      } else if (locationType == 'office') {
        summary.officeSeconds += delta.inSeconds;
      } else {
        summary.travelingSeconds += delta.inSeconds;
      }

      // Save the updated summary to Hive
      await box.put(dateKey, summary);
    });
  }

  // Stop location tracking
  Future<void> stop() async {
    _timer?.cancel();
  }
}

