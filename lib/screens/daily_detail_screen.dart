import 'package:flutter/material.dart';

import '../models/daily_summary.dart';

class DailyDetailScreen extends StatelessWidget {
  final DailySummary summary;

  const DailyDetailScreen({super.key, required this.summary});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Details - ${summary.date}")),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            ListTile(leading: Icon(Icons.directions_car_filled), title: Text("Home: ${summary.formatTime(summary.homeSeconds)}"),),
            const SizedBox(height: 8),
            ListTile(leading: Icon(Icons.work_outline_outlined), title: Text("Office: ${summary.formatTime(summary.officeSeconds)}"),),
            const SizedBox(height: 8),
            ListTile(leading: Icon(Icons.add_road_outlined), title: Text("Traveling: ${summary.formatTime(summary.travelingSeconds)}"),),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }
}
