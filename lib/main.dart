import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

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