import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Service managing user notification read and cleared states in the
/// Notification Centre. Operates independently of Firestore reminder records
/// so marking as read or clearing notifications never modifies or deletes
/// reminders.
class NotificationCentreService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String get _uid => _auth.currentUser?.uid ?? 'guest';

  String get _readKey => 'aquaintel_read_notifs_$_uid';
  String get _clearedKey => 'aquaintel_cleared_notifs_$_uid';

  /// Returns the set of notification (reminder) IDs that have been marked read.
  Future<Set<String>> getReadNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_readKey) ?? [];
    return list.toSet();
  }

  /// Marks a specific notification as read.
  Future<void> markAsRead(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_readKey) ?? []).toSet();
    set.add(id);
    await prefs.setStringList(_readKey, set.toList());
  }

  /// Marks multiple notifications as read.
  Future<void> markAllAsRead(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_readKey) ?? []).toSet();
    set.addAll(ids);
    await prefs.setStringList(_readKey, set.toList());
  }

  /// Returns the set of notification (reminder) IDs that have been cleared/dismissed.
  Future<Set<String>> getClearedNotificationIds() async {
    final prefs = await SharedPreferences.getInstance();
    final list = prefs.getStringList(_clearedKey) ?? [];
    return list.toSet();
  }

  /// Dismisses a single notification from the Notification Centre.
  /// Does NOT delete the reminder from Firestore.
  Future<void> clearNotification(String id) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_clearedKey) ?? []).toSet();
    set.add(id);
    await prefs.setStringList(_clearedKey, set.toList());
  }

  /// Dismisses all given notifications from the Notification Centre.
  /// Does NOT delete reminders from Firestore.
  Future<void> clearAllNotifications(Iterable<String> ids) async {
    final prefs = await SharedPreferences.getInstance();
    final set = (prefs.getStringList(_clearedKey) ?? []).toSet();
    set.addAll(ids);
    await prefs.setStringList(_clearedKey, set.toList());
  }
}

