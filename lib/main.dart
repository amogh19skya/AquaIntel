import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'routes/app_routes.dart';
import 'firebase_options.dart';
import 'services/notification_service.dart';
import 'theme/app_theme.dart';

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
  final prefs = await SharedPreferences.getInstance();
  final permissionRequested =
      prefs.getBool('notification_permission_requested') ?? false;
  if (!permissionRequested) {
    await NotificationService().requestPermission();
    await prefs.setBool('notification_permission_requested', true);
  }

  // 4. Load saved theme preference (default = light / false)
  final isDark = prefs.getBool('dark_mode') ?? false;
  themeNotifier.value = isDark ? ThemeMode.dark : ThemeMode.light;

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (context, currentMode, _) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'AquaIntel',
          navigatorKey: navigatorKey,
          theme: AquaTheme.lightTheme,
          darkTheme: AquaTheme.darkTheme,
          themeMode: currentMode,
          initialRoute: AppRoutes.splash,
          routes: AppRoutes.routes,
        );
      },
    );
  }
}
