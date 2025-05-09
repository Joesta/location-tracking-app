import 'package:flutter/material.dart';
import 'package:location_tracking_app/screens/summary_screen.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:provider/provider.dart';

import '../providers/tracking_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool isTracking = false;

  @override
  void initState() {
    super.initState();
    Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<TrackingProvider>(context);
    return Scaffold(
      appBar: AppBar(title: const Text("Location Tracker")),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: provider.isTracking ? null : provider.clockIn,
              child: const Text("Clock In"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: provider.isTracking ? provider.clockOut : null,
              child: const Text("Clock Out"),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const SummaryScreen()),
                );
              },
              child: const Text("View Summary"),
            ),
          ],
        ),
      ),
    );
  }
}
