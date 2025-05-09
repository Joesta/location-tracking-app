import 'package:flutter/cupertino.dart';
import 'package:hive/hive.dart';

import '../services/geofence_service.dart';

part 'daily_summary.g.dart';

@HiveType(typeId: 0)
class DailySummary extends HiveObject {
  @HiveField(0)
  final String date;

  @HiveField(1)
  int homeSeconds;

  @HiveField(2)
  int officeSeconds;

  @HiveField(3)
  int travelingSeconds;

  @HiveField(4)
  DateTime? startTime;

  @HiveField(5)
  DateTime? endTime;

  DailySummary({
    required this.date,
    this.homeSeconds = 0,
    this.officeSeconds = 0,
    this.travelingSeconds = 0,
    this.startTime,
    this.endTime,
  });

  /// Converts seconds to a formatted string like "2h 35m"
  String formatTime(int seconds) {
    final hours = seconds ~/ 3600;
    final minutes = (seconds % 3600) ~/ 60;
    return '${hours}h ${minutes}m';
  }

  /// Updates the summary with new location data using GeoFenceService
  void updateWithLocation(
      double lat, double lon, DateTime timestamp, GeoFenceService geoService) {
    startTime ??= timestamp;

    final now = timestamp;
    final delta = startTime != null ? now.difference(startTime!).inSeconds : 0;

    final locationType = geoService.classifyLocation(lat, lon);
    switch (locationType) {
      case 'home':
        homeSeconds += delta;
        break;
      case 'office':
        officeSeconds += delta;
        break;
      default:
        travelingSeconds += delta;
    }

    startTime = now;
  }

  /// Marks the end of the tracking day
  void endDay() {
    endTime = DateTime.now();
  }
}
