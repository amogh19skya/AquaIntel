import 'package:flutter/material.dart';
import 'routes/app_routes.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'AquaIntel',
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