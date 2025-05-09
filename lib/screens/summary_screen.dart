import 'package:flutter/material.dart';
import 'package:hive/hive.dart';
import '../models/daily_summary.dart';
import 'daily_detail_screen.dart';

class SummaryScreen extends StatelessWidget {
  const SummaryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final box = Hive.box<DailySummary>('summaries');
    final entries = box.values.toList()
      ..sort((a, b) => b.date.compareTo(a.date));

    return Scaffold(
      appBar: AppBar(title: const Text("Daily Summaries")),
      body: entries.isEmpty
          ? const Center(child: Text("No summaries yet."))
          : ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: entries.length,
        itemBuilder: (context, index) {
          final summary = entries[index];
          return Card(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
            elevation: 3,
            margin: const EdgeInsets.only(bottom: 12),
            child: ListTile(
              contentPadding: const EdgeInsets.all(16),
              leading: const Icon(Icons.calendar_today_rounded, size: 32),
              title: Text(summary.date, style: const TextStyle(fontWeight: FontWeight.bold)),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 8),
                  Text("🏠 Home: ${summary.formatTime(summary.homeSeconds)}"),
                  Text("🏢 Office: ${summary.formatTime(summary.officeSeconds)}"),
                  Text("🚗 Traveling: ${summary.formatTime(summary.travelingSeconds)}"),
                ],
              ),
              trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 16),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => DailyDetailScreen(summary: summary),
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}