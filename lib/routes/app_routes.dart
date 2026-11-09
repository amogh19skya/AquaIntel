import 'package:flutter/material.dart';
import '../onboarding/splashscreen.dart';
import '../auth/sign_in.dart';
import '../auth/sign_up.dart';
import '../screens/home.dart';
import '../screens/reminder.dart';
import '../screens/notifications/notification_centre_screen.dart';
import '../screens/community/community_feed_screen.dart';

class AppRoutes {
  // Route constants
  static const String splash = '/';
  static const String signIn = '/sign_in';
  static const String signUp = '/signup';
  static const String home = '/home';
  static const String addAquarium = '/add-aquarium';
  static const String reminders = '/reminders';
  static const String notifications = '/notifications';
  static const String community = '/community';

  // Route map for MaterialApp
  static Map<String, WidgetBuilder> get routes => {
        splash: (context) => const SplashScreen(),
        signIn: (context) => const SignInScreen(),
        signUp: (context) => const SignupPage(),
        home: (context) => const HomeScreen(),
        reminders: (context) {
          final args = ModalRoute.of(context)?.settings.arguments;
          final reminderId = args is String ? args : null;
          return ReminderScreen(highlightReminderId: reminderId);
        },
        notifications: (context) => const NotificationCentreScreen(),
        community: (context) => const CommunityFeedScreen(),
      };
}
