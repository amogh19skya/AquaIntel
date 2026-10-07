import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';

/// Global navigator key – used by NotificationService to navigate on tap.
final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Initialize Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // 2. Initialize local notification plugin
  await NotificationService().initialize();

  // 3. Request notification permission only on first launch.
  //    Re-requesting every cold start is unnecessary and can annoy users.
  final prefs = await SharedPreferences.getInstance();
  final permissionRequested = prefs.getBool('notification_permission_requested') ?? false;
  if (!permissionRequested) {
    await NotificationService().requestPermission();
    await prefs.setBool('notification_permission_requested', true);
  }

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaIntel',
      navigatorKey: navigatorKey,
      theme: ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: const Color(0xFF0A2236),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A2236),
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      // Directs to the splash screen as the initial route
      initialRoute: AppRoutes.splash,
      routes: AppRoutes.routes,
    );
  }
}

