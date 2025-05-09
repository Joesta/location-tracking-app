import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';

import '../../models/daily_summary.dart';
import '../../services/geofence_service.dart';

class LocationTrackerHelper {
  static Future<void> updateSummaryWithLocation() async {
    final pos = await Geolocator.getCurrentPosition();
    final now = DateTime.now();

    final box = Hive.box<DailySummary>('summaries');
    final dateKey = now.toIso8601String().split('T')[0];
    final summary = box.get(dateKey) ?? DailySummary(date: dateKey);

    summary.updateWithLocation(
        pos.latitude, pos.longitude, now, GeoFenceService());
    await box.put(dateKey, summary);
  }
}
