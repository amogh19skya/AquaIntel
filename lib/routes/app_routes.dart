import 'package:flutter/material.dart';
import '../onboarding/splashscreen.dart';
import '../auth/sign_in.dart';
import '../auth/sign_up.dart';
import '../screens/home.dart';

class AppRoutes {
  // Route constants
  static const String splash = '/';
  static const String login = '/login';
  static const String signIn = '/sign_in';
  static const String signUp = '/signup';
  static const String home = '/home';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        login: (context) => const SignInScreen(),
        signIn: (context) => const SignInScreen(),
        signUp: (context) => const SignupPage(),
        home: (context) => const HomeScreen(),
      };
}

