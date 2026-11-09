import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/timezone.dart' as tz;
import 'package:timezone/data/latest_all.dart' as tz;
import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';
import '../main.dart' show navigatorKey;

/// Abstract contract for Notification operations (DIP).
abstract class INotificationService {
  Future<void> initialize();
  Future<bool> requestPermission();
  Future<void> scheduleFeedingReminder({
    required int id,
    required String aquariumName,
    required DateTime scheduledAt,
    required bool soundEnabled,
    String? reminderId,
  });
  Future<void> scheduleWaterChangeReminder({
    required int id,
    required String aquariumName,
    required DateTime scheduledAt,
    required bool soundEnabled,
    String? reminderId,
  });
  Future<void> scheduleGenericReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool soundEnabled,
    String? reminderId,
  });
  Future<void> scheduleReminder(
    ReminderModel reminder, {
    bool soundEnabled = true,
  });
  Future<void> cancelNotification(int id);
  Future<void> cancelAllNotifications();
}

/// Singleton notification service for AquaIntel.
///
/// Manages two Android notification channels:
///   • aquaintel_reminders_sound  – channel with sound enabled
///   • aquaintel_reminders_silent – channel with sound disabled
///
/// Switching the sound preference at runtime swaps which channel is used for
/// newly scheduled notifications.
class NotificationService implements INotificationService {
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
  @override
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

    // Check if the app was launched by tapping a notification (cold start)
    try {
      final launchDetails =
          await _plugin.getNotificationAppLaunchDetails();
      if (launchDetails != null && launchDetails.didNotificationLaunchApp) {
        final resp = launchDetails.notificationResponse;
        if (resp != null) {
          debugPrint('NotificationService: app launched from notification payload=${resp.payload}');
          _onNotificationTap(resp);
        }
      }
    } catch (e) {
      debugPrint('NotificationService: launch details error: $e');
    }

    _initialized = true;
    debugPrint('NotificationService: initialized');
  }

  void _onNotificationTap(NotificationResponse response) {
    debugPrint('NotificationService: tapped payload=${response.payload}');
    lastTappedPayload = response.payload;

    try {
      final reminderId = _parseReminderId(response.payload);
      _navigateToReminders(reminderId);
    } catch (e) {
      debugPrint('NotificationService: navigation failed: $e');
    }
  }

  String? _parseReminderId(String? payload) {
    if (payload == null || payload.isEmpty) return null;
    return payload
        .replaceFirst('reminder_', '')
        .replaceFirst('feeding_', '')
        .replaceFirst('waterChange_', '')
        .replaceFirst('reminder:', '');
  }

  void _navigateToReminders(String? reminderId) {
    _pendingNavigation = '/reminders';
    _pendingReminderId = reminderId;
    try {
      navigatorKey.currentState?.pushNamed('/reminders', arguments: reminderId);
    } catch (e) {
      debugPrint('NotificationService: navigatorKey push failed: $e');
    }
  }

  String? _pendingNavigation;
  String? _pendingReminderId;

  ({String route, String? reminderId})? consumePendingNavigation() {
    final nav = _pendingNavigation;
    final rId = _pendingReminderId;
    _pendingNavigation = null;
    _pendingReminderId = null;
    if (nav == null) return null;
    return (route: nav, reminderId: rId);
  }

  String? lastTappedPayload;

  // ─── Permission ──────────────────────────────────────────

  @override
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

  @override
  Future<void> scheduleFeedingReminder({
    required int id,
    required String aquariumName,
    required DateTime scheduledAt,
    required bool soundEnabled,
    String? reminderId,
  }) async {
    final body = aquariumName.isNotEmpty
        ? 'It is time to feed your aquarium fish ($aquariumName).'
        : 'It is time to feed your aquarium fish.';
    await _scheduleNotification(
      id: id,
      title: 'AquaIntel – Feeding Reminder',
      body: body,
      scheduledAt: scheduledAt,
      soundEnabled: soundEnabled,
      payload: reminderId != null ? 'reminder_$reminderId' : 'feeding_$id',
    );
  }

  @override
  Future<void> scheduleWaterChangeReminder({
    required int id,
    required String aquariumName,
    required DateTime scheduledAt,
    required bool soundEnabled,
    String? reminderId,
  }) async {
    final body = aquariumName.isNotEmpty
        ? 'It is time for your scheduled aquarium water change ($aquariumName).'
        : 'It is time for your scheduled aquarium water change.';
    await _scheduleNotification(
      id: id,
      title: 'AquaIntel – Water Change Reminder',
      body: body,
      scheduledAt: scheduledAt,
      soundEnabled: soundEnabled,
      payload: reminderId != null ? 'reminder_$reminderId' : 'waterChange_$id',
    );
  }

  @override
  Future<void> scheduleGenericReminder({
    required int id,
    required String title,
    required String body,
    required DateTime scheduledAt,
    required bool soundEnabled,
    String? reminderId,
  }) async {
    final displayTitle =
        title.startsWith('AquaIntel') ? title : 'AquaIntel – $title';
    await _scheduleNotification(
      id: id,
      title: displayTitle,
      body: body,
      scheduledAt: scheduledAt,
      soundEnabled: soundEnabled,
      payload: reminderId != null ? 'reminder_$reminderId' : 'reminder_$id',
    );
  }

  /// High-level method to schedule an Android local notification directly
  /// from a [ReminderModel]. Respects completion, schedule time, and toggle.
  @override
  Future<void> scheduleReminder(
    ReminderModel reminder, {
    bool soundEnabled = true,
  }) async {
    if (!reminder.notificationEnabled) {
      debugPrint('NotificationService: reminder "${reminder.title}" notifications disabled');
      return;
    }
    if (reminder.isCompleted) {
      debugPrint('NotificationService: reminder "${reminder.title}" already completed');
      return;
    }
    if (reminder.scheduledDateTime.isBefore(DateTime.now())) {
      debugPrint('NotificationService: reminder "${reminder.title}" scheduled time is past');
      return;
    }

    final String rawTitle = reminder.title.isNotEmpty
        ? reminder.title
        : '${reminder.type.label} Reminder';
    final String displayTitle = rawTitle.startsWith('AquaIntel')
        ? rawTitle
        : 'AquaIntel – $rawTitle';

    final String body = reminder.description.isNotEmpty
        ? reminder.description
        : (reminder.type == ReminderType.feeding
            ? 'It is time to feed your aquarium fish.'
            : (reminder.type == ReminderType.waterChange
                ? 'It is time for your scheduled aquarium water change.'
                : 'It is time for your scheduled ${reminder.type.label.toLowerCase()}.'));

    await _scheduleNotification(
      id: reminder.notificationId,
      title: displayTitle,
      body: body,
      scheduledAt: reminder.scheduledDateTime,
      soundEnabled: soundEnabled,
      payload: 'reminder_${reminder.id ?? reminder.notificationId}',
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

  @override
  Future<void> cancelNotification(int id) async {
    await _plugin.cancel(id);
    debugPrint('NotificationService: cancelled id=$id');
  }

  Future<void> cancelFeedingReminder(int id) => cancelNotification(id);

  Future<void> cancelWaterChangeReminder(int id) => cancelNotification(id);

  @override
  Future<void> cancelAllNotifications() async {
    await _plugin.cancelAll();
    debugPrint('NotificationService: cancelled ALL notifications');
  }
}
