import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'notification_service.dart';

/// Singleton settings service for AquaIntel.
///
/// Persists all user preferences to SharedPreferences (fast, local, offline-safe).
/// The master notification toggle is also mirrored to Firestore so it can be
/// read from other devices or the backend.
///
/// Stored keys:
///   notifications_enabled  – master push-notification switch
///   feeding_alerts         – feeding reminders switch
///   water_change_alerts    – water-change reminders switch
///   sound_enabled          – notification sound switch
///   haptic_feedback        – haptic feedback switch
///   dark_mode              – dark-mode switch
///   auto_backup            – auto-backup switch
///   temperature_unit       – 0 = Celsius, 1 = Fahrenheit
class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  // ─── SharedPreferences keys ───────────────────────────────
  static const String _kNotifications = 'notifications_enabled';
  static const String _kFeeding = 'feeding_alerts';
  static const String _kWaterChange = 'water_change_alerts';
  static const String _kSound = 'sound_enabled';
  static const String _kHaptic = 'haptic_feedback';
  static const String _kDarkMode = 'dark_mode';
  static const String _kAutoBackup = 'auto_backup';
  static const String _kTempUnit = 'temperature_unit';

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String? get _uid => _auth.currentUser?.uid;

  DocumentReference<Map<String, dynamic>>? get _settingsDoc {
    final uid = _uid;
    if (uid == null) return null;
    return _firestore
        .collection('users')
        .doc(uid)
        .collection('settings')
        .doc('notifications');
  }

  // ─── Getters ──────────────────────────────────────────────

  Future<bool> getNotificationsEnabled() async {
    // Try Firestore first (syncs across devices), fallback to local prefs.
    try {
      final doc = _settingsDoc;
      if (doc != null) {
        final snap = await doc.get();
        if (snap.exists) {
          return snap.data()?['notificationsEnabled'] as bool? ?? true;
        }
      }
    } catch (_) {}
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kNotifications) ?? true;
  }

  Future<bool> getFeedingAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kFeeding) ?? true;
  }

  Future<bool> getWaterChangeAlerts() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kWaterChange) ?? true;
  }

  Future<bool> getSoundEnabled() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kSound) ?? false;
  }

  Future<bool> getHapticFeedback() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kHaptic) ?? true;
  }

  Future<bool> getDarkMode() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kDarkMode) ?? true;
  }

  Future<bool> getAutoBackup() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_kAutoBackup) ?? false;
  }

  /// Returns temperature unit index: 0 = Celsius, 1 = Fahrenheit.
  Future<int> getTemperatureUnit() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_kTempUnit) ?? 0;
  }

  // ─── Setters ──────────────────────────────────────────────

  /// Persists the master notification toggle.
  /// When turned OFF, cancels all scheduled notifications.
  Future<void> setNotificationsEnabled(bool enabled) async {
    // Mirror to Firestore (best-effort).
    try {
      final doc = _settingsDoc;
      if (doc != null) {
        await doc.set(
          {
            'notificationsEnabled': enabled,
            'updatedAt': Timestamp.fromDate(DateTime.now()),
          },
          SetOptions(merge: true),
        );
      }
    } catch (_) {}

    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kNotifications, enabled);

    if (!enabled) {
      await NotificationService().cancelAllNotifications();
    }
  }

  Future<void> setFeedingAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kFeeding, enabled);
  }

  Future<void> setWaterChangeAlerts(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kWaterChange, enabled);
  }

  Future<void> setSoundEnabled(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kSound, enabled);
  }

  Future<void> setHapticFeedback(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kHaptic, enabled);
  }

  Future<void> setDarkMode(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kDarkMode, enabled);
  }

  Future<void> setAutoBackup(bool enabled) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_kAutoBackup, enabled);
  }

  Future<void> setTemperatureUnit(int index) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_kTempUnit, index);
  }

  // ─── Real-time stream ─────────────────────────────────────

  /// Streams the master notification setting from Firestore in real time.
  Stream<bool> notificationsEnabledStream() {
    final doc = _settingsDoc;
    if (doc == null) return Stream.value(true);
    return doc.snapshots().map(
          (snap) => snap.data()?['notificationsEnabled'] as bool? ?? true,
        );
  }
}
