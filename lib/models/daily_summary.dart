import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

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

  /// Updates the summary with new location data
  void updateWithLocation(double lat, double lon, DateTime timestamp) {

    startTime ??= timestamp;

    // Coordinates of known places
    const home = (28.2102213, -25.7456269);
    const office = (28.15123237829154, -25.9169722);
    const radius = 50.0;

    final distanceToHome = Geolocator.distanceBetween(lat, lon, home.$1, home.$2);
    final distanceToOffice = Geolocator.distanceBetween(lat, lon, office.$1, office.$2);

    final now = timestamp;
    final delta = startTime != null ? now.difference(startTime!).inSeconds : 0;

    if (distanceToHome <= radius) {
      homeSeconds += delta;
    } else if (distanceToOffice <= radius) {
      officeSeconds += delta;
    } else {
      travelingSeconds += delta;
    }

    // Update last known timestamp as start of next delta
    startTime = now;
  }

  /// Marks the end of the tracking day
  void endDay() {
    endTime = DateTime.now();
  }
}
