import 'dart:async';
import 'dart:ui';

import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:geolocator/geolocator.dart';
import 'package:hive/hive.dart';
import 'package:location_tracking_app/services/geofence_service.dart';

import '../models/daily_summary.dart';

Future<void> initializeService() async {
  final service = FlutterBackgroundService();

  await service.configure(
    androidConfiguration: AndroidConfiguration(
      onStart: onStart,
      isForegroundMode: true,
      autoStart: true,
      initialNotificationTitle: "Location Service",
      initialNotificationContent: "Tracking location...",
    ),
    iosConfiguration: IosConfiguration(
      onBackground: (service) => true,
      autoStart: true,
    ),
  );
}

void onStart(ServiceInstance service) {
  DartPluginRegistrant.ensureInitialized();
  service.invoke(
      "startService"); // Start the location tracking service in the background
  // Start tracking location in the background
  service.invoke("trackLocation");
}

void trackLocation(ServiceInstance service) {
  Timer.periodic(const Duration(seconds: 30), (timer) async {
    final now = DateTime.now();

    final pos = await Geolocator.getCurrentPosition();

    final box = Hive.box<DailySummary>('summaries');
    final dateKey = now.toIso8601String().split('T')[0];
    final summary = box.get(dateKey) ?? DailySummary(date: dateKey);

    summary.updateWithLocation(
        pos.latitude, pos.longitude, now, GeoFenceService());
    summary.save();
  });
}
