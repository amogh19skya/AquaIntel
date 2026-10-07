import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';

/// Singleton notification service for AquaIntel.
///
/// Manages two Android notification channels:
///   • aquaintel_reminders_sound  – channel with sound enabled
///   • aquaintel_reminders_silent – channel with sound disabled
///
/// Switching the sound preference at runtime swaps which channel is used for
/// newly scheduled notifications.
class NotificationService {
  static final NotificationService _instance = NotificationService._internal();
  factory NotificationService() => _instance;
  NotificationService._internal();

  final FlutterLocalNotificationsPlugin _plugin =
      FlutterLocalNotificationsPlugin();

  static const String _soundChannelId = 'aquaintel_reminders_sound';
  static const String _silentChannelId = 'aquaintel_reminders_silent';
  static const String _channelName = 'AquaIntel Reminders';
  static const String _channelDesc = 'Scheduled aquarium maintenance reminders';

  bool _initialized = false;

  // ─── Initialization ──────────────────────────────────────

  /// Call once during [main] before [runApp].
  Future<void> initialize() async {
    if (_initialized) return;

    tz.initializeTimeZones();
    debugPrint('NotificationService: timezone = ${tz.local}');

    const androidSettings =
        AndroidInitializationSettings('@mipmap/ic_launcher');
    const initSettings = InitializationSettings(android: androidSettings);

    await _plugin.initialize(
      initSettings,
      onDidReceiveNotificationResponse: _onNotificationTap,
    );

    _initialized = true;
    debugPrint('NotificationService: initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('NotificationService: tapped payload=${response.payload}');
    lastTappedPayload = response.payload;

    // Navigate to the Reminders screen when a notification is tapped.
    // We import navigatorKey lazily to avoid a circular import at the top level.
    // ignore: avoid_dynamic_calls
    try {
      // Dynamically access the navigator key from main.dart via the import below.
      // Using a simple approach: navigate to '/reminders' if there is a current route.
      _navigateToReminders();
    } catch (e) {
      debugPrint('NotificationService: navigation failed: $e');
    }
  }

  void _navigateToReminders() {
    // Import the global navigator key from main.dart.
    // We use a separate import file to avoid circular imports.
    _pendingNavigation = '/reminders';
  }

  /// Pending navigation path set when a notification is tapped.
  /// HomeScreen reads this on resume to perform the navigation.
  String? _pendingNavigation;

  /// Returns and clears any pending navigation path.
  String? consumePendingNavigation() {
    final nav = _pendingNavigation;
    _pendingNavigation = null;
    return nav;
  }

  /// Last notification payload tapped by the user.
  /// Format: "feeding_[id]", "waterChange_[id]", or "reminder_[id]".
  String? lastTappedPayload;


  // ─── Permission ──────────────────────────────────────────

  /// Requests Android notification permission (Android 13+).
  Future<bool> requestPermission() async {
    final androidPlugin =
        _plugin.resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>();
    if (androidPlugin != null) {
      final granted =
          await androidPlugin.requestNotificationsPermission() ?? false;
      debugPrint('NotificationService: permission granted = $granted');
      return granted;
    }
    return true;
  }

  // ─── Channel helpers ─────────────────────────────────────

  AndroidNotificationDetails _buildAndroidDetails({
    required bool soundEnabled,
  }) {
    final channelId = soundEnabled ? _soundChannelId : _silentChannelId;
    return AndroidNotificationDetails(
      channelId,
      _channelName,
      channelDescription: _channelDesc,
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      playSound: soundEnabled,
      enableVibration: true,
    );
  }

  // ─── Type-specific schedule methods ──────────────────────

  /// Schedules a feeding reminder notification.
  Future<void> scheduleFeedingReminder({
    required int id,
    required String aquariumName,
    required DateTime scheduledAt,
    required bool soundEnabled,
  }) async {
    final body = aquariumName.isNotEmpty
        ? 'It\'s time for your scheduled aquarium feeding ($aquariumName).'
        : 'It\'s time for your scheduled aquarium feeding.';
    await _scheduleNotification(
      id: id,
      title: '🐟 Time to feed your fish',
      body: body,
      scheduledAt: scheduledAt,
      soundEnabled: soundEnabled,
      payload: 'feeding_$id',
    );
  }

  /// Schedules a water-change reminder notification.
  Future<void> scheduleWaterChangeReminder({
    required int id,
    required String aquariumName,
    required DateTime scheduledAt,
    required bool soundEnabled,
  }) async {
    final body = aquariumName.isNotEmpty
        ? 'It\'s time for your scheduled aquarium water change ($aquariumName).'
        : 'It\'s time for your scheduled aquarium water change.';
    await _scheduleNotification(
      id: id,
      title: '💧 Water change reminder',
      body: body,
      scheduledAt: scheduledAt,
      soundEnabled: soundEnabled,
      payload: 'waterChange_$id',
    );
  }

  /// Schedules a generic reminder notification (filter cleaning, medication, etc.).
  Future<void> scheduleGenericReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool soundEnabled,
  }) async {
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledAt,
      soundEnabled: soundEnabled,
      payload: 'reminder_$id',
    );
  }

  // ─── Low-level schedule ──────────────────────────────────

  Future<void> _scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool soundEnabled,
    required String payload,
  }) async {
    if (!_initialized) await initialize();

    if (scheduledAt.isBefore(DateTime.now())) {
      debugPrint(
          'NotificationService: skipping past notification id=$id at $scheduledAt');
      return;
    }

    final tzScheduled = tz.TZDateTime.from(scheduledAt, tz.local);
    final androidDetails = _buildAndroidDetails(soundEnabled: soundEnabled);
    final details = NotificationDetails(android: androidDetails);

    await _plugin.zonedSchedule(
      id,
      title,
      body,
      tzScheduled,
      details,
      androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
      uiLocalNotificationDateInterpretation:
          UILocalNotificationDateInterpretation.absoluteTime,
      payload: payload,
    );

    debugPrint(
        'NotificationService: scheduled id=$id "$title" at $tzScheduled sound=$soundEnabled');
  }

  // ─── Legacy compatibility ─────────────────────────────────

  /// Backward-compatible method. Prefer the type-specific methods for new code.
  Future<void> scheduleNotification({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledDateTime,
    bool soundEnabled = true,
  }) async {
    await _scheduleNotification(
      id: id,
      title: title,
      body: body,
      scheduledAt: scheduledDateTime,
      soundEnabled: soundEnabled,
      payload: 'reminder_$id',
    );
  }

  // ─── Cancellation ────────────────────────────────────────

  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('NotificationService: cancelled id=$id');
  }

  Future<void> cancelFeedingReminder(int id) => cancelNotification(id);

  Future<void> cancelWaterChangeReminder(int id) => cancelNotification(id);

  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('NotificationService: cancelled ALL notifications');
  }
}
