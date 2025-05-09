import 'package:flutter/material.dart';
import 'package:flutter_background_service/flutter_background_service.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:location_tracking_app/providers/tracking_provider.dart';
import 'package:provider/provider.dart';
import 'models/daily_summary.dart';
import 'screens/home_screen.dart';
import 'services/service_initializer.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  Hive.registerAdapter(DailySummaryAdapter());
  await Hive.openBox<DailySummary>('summaries');

  await initializeService();

  runApp(
    ChangeNotifierProvider(
      create: (_) => TrackingProvider(),
      builder: (context, child) {
        return const MyApp();
      },
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp>  with WidgetsBindingObserver {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Location Tracker',
      theme: ThemeData(primarySwatch: Colors.indigo),
      home: const HomeScreen(),
    );
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused) {
      FlutterBackgroundService().invoke("startService"); // the service continues running when the app is paused.
    }
    if (state == AppLifecycleState.resumed) {
      FlutterBackgroundService().invoke("startService");
    }
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }
}