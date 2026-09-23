import 'package:flutter/material.dart';
import '../onboarding/splashscreen.dart';
import '../screens/sign_in.dart';

class AppRoutes {
  // Route constants
  static const String splash = '/';
  static const String login = '/login';
  static const String signIn = '/sign_in';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const SignInScreen(),
        signIn: (context) => const SignInScreen(),
      };
}
