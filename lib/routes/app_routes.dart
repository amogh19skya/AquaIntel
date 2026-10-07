import 'package:flutter/material.dart';
import '../onboarding/splashscreen.dart';
import '../auth/sign_in.dart';
import '../auth/sign_up.dart';
import '../screens/home.dart';
import '../screens/reminder.dart';

class AppRoutes {
  // Route constants
  static const String splash = '/';
  static const String signIn = '/sign_in';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String addAquarium = '/add-aquarium';
  static const String reminders = '/reminders';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        signIn: (context) => const SignInScreen(),
        signUp: (context) => const SignupPage(),
        home: (context) => const HomeScreen(),
        reminders: (context) => const ReminderScreen(),
      };
}
