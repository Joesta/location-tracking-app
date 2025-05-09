import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:hive/hive.dart';

import '../models/daily_summary.dart';
import '../services/geofence_service.dart';
import '../services/location_service.dart';

class TrackingProvider extends ChangeNotifier with WidgetsBindingObserver {
  final ValueNotifier<bool> _isTracking = ValueNotifier(false);
  final GeoFenceService _geoService = GeoFenceService();
  final LocationService _locationService;

  late DailySummary todaySummary;
  late Box<DailySummary> _box;

  String get today => DateTime.now().toIso8601String().split('T').first;

  TrackingProvider() : _locationService = LocationService() {
    _initialize();
  }

  Future<void> _initialize() async {
    _locationService.onLocationUpdate = _handleLocationUpdate;
    WidgetsBinding.instance.addObserver(this);
    await _initializeSummary();

  }

  bool get isTracking => _isTracking.value;

  Future<void> _initializeSummary() async {
    final today = DateTime.now().toIso8601String().split('T').first;
    _box = await Hive.openBox<DailySummary>('summaries');
    print("Hive keys: ${_box.keys}");
    todaySummary = _box.get(today) ?? DailySummary(date: today);
    await _box.put(today, todaySummary);
  }

  Future<void> clockIn() async {
    _isTracking.value = true;
    await _locationService.start();
    notifyListeners();
  }

  Future<void> clockOut() async {
    _isTracking.value = false;
    await _locationService.stop();
    todaySummary.endDay();
    await _saveSummary();
    notifyListeners();
  }

  void _handleLocationUpdate(double lat, double lon, DateTime timestamp) async {
    todaySummary.updateWithLocation(lat, lon, timestamp, _geoService);
    await todaySummary.save();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.paused) {
      _saveSummary();
    }

    if (state == AppLifecycleState.resumed) {
      debugPrint('Resuming: reloading summary');
      await _initializeSummary(); // Reload from Hive
      if (_isTracking.value) {
        await _locationService.start(); // Restart tracking
      }
    }
  }


  Future<void> _saveSummary() async {
    await _box.put(today, todaySummary);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}
