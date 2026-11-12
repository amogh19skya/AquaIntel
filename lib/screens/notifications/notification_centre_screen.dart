import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminder_model.dart';
import '../../services/reminder_service.dart';
import '../../services/notification_centre_service.dart';
import '../../theme/app_theme.dart';
import '../reminder.dart';

/// Full-screen Notification Centre displaying all reminder notifications.
/// Allows viewing, marking as read, dismissing/clearing notifications,
/// and tapping directly through to the Maintenance Board (with highlighted reminder).
class NotificationCentreScreen extends StatefulWidget {
  const NotificationCentreScreen({super.key});

  @override
  State<NotificationCentreScreen> createState() =>
      _NotificationCentreScreenState();
}

class _NotificationCentreScreenState extends State<NotificationCentreScreen> {
  final ReminderService _reminderService = ReminderService();
  final NotificationCentreService _notifService = NotificationCentreService();

  Set<String> _readIds = {};
  Set<String> _clearedIds = {};
  bool _isLoadingPrefs = true;
  bool _showUnreadOnly = false;

  @override
  void initState() {
    super.initState();
    _loadNotificationPreferences();
  }

  Future<void> _loadNotificationPreferences() async {
    final reads = await _notifService.getReadNotificationIds();
    final cleared = await _notifService.getClearedNotificationIds();
    if (!mounted) return;
    setState(() {
      _readIds = reads;
      _clearedIds = cleared;
      _isLoadingPrefs = false;
    });
  }

  Future<void> _markAsRead(String id) async {
    await _notifService.markAsRead(id);
    setState(() => _readIds.add(id));
  }

  Future<void> _markAllAsRead(List<ReminderModel> notifications) async {
    final ids = notifications
        .where((r) => r.id != null)
        .map((r) => r.id!)
        .toList();
    await _notifService.markAllAsRead(ids);
    setState(() => _readIds.addAll(ids));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('All notifications marked as read'),
        backgroundColor: AquaColors.cardElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  Future<void> _clearNotification(String id) async {
    await _notifService.clearNotification(id);
    setState(() => _clearedIds.add(id));
  }

  Future<void> _confirmClearAll(List<ReminderModel> notifications) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AquaColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text(
          'Clear All Notifications',
          style: TextStyle(
            color: AquaColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to clear all notifications?\n\n'
          'Your reminder tasks and schedules will remain safely preserved.',
          style: TextStyle(color: AquaColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: AquaColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AquaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            ),
            child: const Text('Clear All'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    final ids = notifications
        .where((r) => r.id != null)
        .map((r) => r.id!)
        .toList();
    await _notifService.clearAllNotifications(ids);
    setState(() => _clearedIds.addAll(ids));

    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Notifications cleared'),
        backgroundColor: AquaColors.cardElevated,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  void _onNotificationTap(ReminderModel reminder) async {
    if (reminder.id != null) {
      await _markAsRead(reminder.id!);
    }

    if (!mounted) return;
    // Navigate directly to Maintenance Board with highlighted reminder
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderScreen(highlightReminderId: reminder.id),
      ),
    );
  }

  Color _colorForType(ReminderType t) {
    switch (t) {
      case ReminderType.feeding:
        return const Color(0xFFFF9800);
      case ReminderType.waterChange:
        return const Color(0xFF42A5F5);
      case ReminderType.filterCleaning:
        return const Color(0xFFAB47BC);
      case ReminderType.tankCleaning:
        return const Color(0xFF66BB6A);
      case ReminderType.medication:
        return const Color(0xFFEF5350);
      case ReminderType.maintenance:
        return const Color(0xFF26C6DA);
      case ReminderType.custom:
        return const Color(0xFFBDBDBD);
    }
  }

  IconData _iconForType(ReminderType t) {
    switch (t) {
      case ReminderType.feeding:
        return Icons.restaurant;
      case ReminderType.waterChange:
        return Icons.water_drop;
      case ReminderType.filterCleaning:
        return Icons.tune;
      case ReminderType.tankCleaning:
        return Icons.cleaning_services;
      case ReminderType.medication:
        return Icons.medication;
      case ReminderType.maintenance:
        return Icons.build;
      case ReminderType.custom:
        return Icons.edit_note;
    }
  }

  String _formatNotificationMessage(ReminderModel r) {
    if (r.description.isNotEmpty) return r.description;
    switch (r.type) {
      case ReminderType.feeding:
        return 'It is time to feed your aquarium fish.';
      case ReminderType.waterChange:
        return 'It is time for your scheduled aquarium water change.';
      case ReminderType.filterCleaning:
        return 'Time to clean or inspect your aquarium filter.';
      case ReminderType.tankCleaning:
        return 'Time for scheduled tank glass and substrate cleaning.';
      case ReminderType.medication:
        return 'Time to administer scheduled aquarium medication.';
      case ReminderType.maintenance:
        return 'Time for routine aquarium equipment check.';
      case ReminderType.custom:
        return 'Scheduled maintenance task is due.';
    }
  }

  String _formatNotificationTime(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final reminderDay =
        DateTime(dateTime.year, dateTime.month, dateTime.day);

    final timeStr = DateFormat('h:mm a').format(dateTime);

    if (reminderDay == today) {
      return 'Today, $timeStr';
    } else if (reminderDay == today.subtract(const Duration(days: 1))) {
      return 'Yesterday, $timeStr';
    } else if (reminderDay == today.add(const Duration(days: 1))) {
      return 'Tomorrow, $timeStr';
    } else {
      return DateFormat('EEE, MMM d • h:mm a').format(dateTime);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.bg,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new,
              color: AquaColors.textPrimary, size: 18),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Notifications',
          style: TextStyle(
            color: AquaColors.textPrimary,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      body: _isLoadingPrefs
          ? const Center(
              child: CircularProgressIndicator(color: AquaColors.accent),
            )
          : StreamBuilder<List<ReminderModel>>(
              stream: _reminderService.getReminders(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    snapshot.data == null) {
                  return const Center(
                    child:
                        CircularProgressIndicator(color: AquaColors.accent),
                  );
                }

                if (snapshot.hasError) {
                  return Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24.0),
                      child: Text(
                        'Failed to load notifications: ${snapshot.error}',
                        style: TextStyle(color: AquaColors.error),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  );
                }

                final allReminders = snapshot.data ?? [];

                // Exclude dismissed/cleared notifications
                final visibleNotifs = allReminders
                    .where((r) => r.id != null && !_clearedIds.contains(r.id))
                    .toList()
                  // Sort newest/imminent first
                  ..sort(
                      (a, b) => b.scheduledDateTime.compareTo(a.scheduledDateTime));

                final unreadNotifs = visibleNotifs
                    .where((r) => !_readIds.contains(r.id))
                    .toList();

                final displayed =
                    _showUnreadOnly ? unreadNotifs : visibleNotifs;

                if (visibleNotifs.isEmpty) {
                  return _buildEmptyState();
                }

                return Column(
                  children: [
                    // Filter bar & actions
                    Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 12),
                      child: Row(
                        children: [
                          // All filter chip
                          _buildFilterChip(
                            label: 'All (${visibleNotifs.length})',
                            isSelected: !_showUnreadOnly,
                            onTap: () =>
                                setState(() => _showUnreadOnly = false),
                          ),
                          const SizedBox(width: 8),
                          // Unread filter chip
                          _buildFilterChip(
                            label: 'Unread (${unreadNotifs.length})',
                            isSelected: _showUnreadOnly,
                            color: unreadNotifs.isNotEmpty
                                ? AquaColors.accent
                                : null,
                            onTap: () =>
                                setState(() => _showUnreadOnly = true),
                          ),
                          const Spacer(),
                          // Mark all read button
                          if (unreadNotifs.isNotEmpty)
                            IconButton(
                              tooltip: 'Mark all as read',
                              icon: Icon(
                                Icons.done_all_rounded,
                                color: AquaColors.accent,
                                size: 20,
                              ),
                              onPressed: () => _markAllAsRead(unreadNotifs),
                            ),
                          // Clear all button
                          IconButton(
                            tooltip: 'Clear all notifications',
                            icon: Icon(
                              Icons.delete_sweep_outlined,
                              color: AquaColors.textMuted,
                              size: 20,
                            ),
                            onPressed: () =>
                                _confirmClearAll(visibleNotifs),
                          ),
                        ],
                      ),
                    ),

                    Divider(color: AquaColors.border, height: 1),

                    // Notification list
                    Expanded(
                      child: displayed.isEmpty
                          ? Center(
                              child: Text(
                                _showUnreadOnly
                                    ? 'No unread notifications'
                                    : 'No notifications',
                                style: TextStyle(
                                  color: AquaColors.textSecondary,
                                  fontSize: 14,
                                ),
                              ),
                            )
                          : ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              padding: const EdgeInsets.fromLTRB(
                                  18, 14, 18, 30),
                              itemCount: displayed.length,
                              itemBuilder: (context, index) {
                                final reminder = displayed[index];
                                final isRead =
                                    _readIds.contains(reminder.id);
                                return _buildNotificationTile(
                                    reminder, isRead);
                              },
                            ),
                    ),
                  ],
                );
              },
            ),
    );
  }

  Widget _buildFilterChip({
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
    Color? color,
  }) {
    final chipColor = color ?? AquaColors.accent;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: isSelected
              ? chipColor.withValues(alpha: 0.18)
              : AquaColors.card,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected ? chipColor : AquaColors.border,
            width: isSelected ? 1.3 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? chipColor : AquaColors.textSecondary,
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  Widget _buildNotificationTile(ReminderModel reminder, bool isRead) {
    final typeColor = _colorForType(reminder.type);
    final typeIcon = _iconForType(reminder.type);
    final isOverdue = reminder.isOverdue;
    final isCompleted = reminder.isCompleted;
    final timeStr = _formatNotificationTime(reminder.scheduledDateTime);
    final message = _formatNotificationMessage(reminder);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: isRead
            ? AquaColors.card
            : AquaColors.cardElevated,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isRead
              ? AquaColors.border
              : (isOverdue
                  ? AquaColors.error.withValues(alpha: 0.5)
                  : AquaColors.accent.withValues(alpha: 0.35)),
          width: isRead ? 1.0 : 1.3,
        ),
        boxShadow: isRead
            ? []
            : [
                BoxShadow(
                  color: (isOverdue ? AquaColors.error : AquaColors.accent)
                      .withValues(alpha: 0.08),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => _onNotificationTap(reminder),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Unread blue dot indicator
                if (!isRead)
                  Container(
                    margin: const EdgeInsets.only(top: 6, right: 10),
                    width: 8,
                    height: 8,
                    decoration: BoxDecoration(
                      color: AquaColors.accent,
                      shape: BoxShape.circle,
                    ),
                  ),

                // Category Icon Avatar
                Container(
                  padding: const EdgeInsets.all(11),
                  decoration: BoxDecoration(
                    color: isOverdue
                        ? AquaColors.error.withValues(alpha: 0.15)
                        : (isCompleted
                            ? AquaColors.success.withValues(alpha: 0.15)
                            : typeColor.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    typeIcon,
                    color: isOverdue
                        ? AquaColors.error
                        : (isCompleted ? AquaColors.success : typeColor),
                    size: 22,
                  ),
                ),
                const SizedBox(width: 14),

                // Content
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header badges row
                      Row(
                        children: [
                          // Category badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reminder.type.label,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                          const SizedBox(width: 6),

                          // Status badge
                          if (isOverdue)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color:
                                    AquaColors.error.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'OVERDUE',
                                style: TextStyle(
                                  color: AquaColors.error,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            )
                          else if (isCompleted)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: AquaColors.success
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                'COMPLETED',
                                style: TextStyle(
                                  color: AquaColors.success,
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        reminder.title,
                        style: TextStyle(
                          color: isRead
                              ? AquaColors.textSecondary
                              : AquaColors.textPrimary,
                          fontSize: 15,
                          fontWeight:
                              isRead ? FontWeight.w600 : FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 4),

                      // Message
                      Text(
                        message,
                        style: TextStyle(
                          color: isRead
                              ? AquaColors.textMuted
                              : AquaColors.textSecondary,
                          fontSize: 13,
                          height: 1.35,
                        ),
                      ),
                      const SizedBox(height: 8),

                      // Time & Tank Name
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.access_time_rounded,
                            color: isOverdue
                                ? AquaColors.error
                                : AquaColors.textMuted,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            timeStr,
                            style: TextStyle(
                              color: isOverdue
                                  ? AquaColors.error
                                  : AquaColors.textMuted,
                              fontSize: 11.5,
                              fontWeight: isOverdue
                                  ? FontWeight.w600
                                  : FontWeight.normal,
                            ),
                          ),
                          if (reminder.aquariumName.isNotEmpty) ...[
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                '• ${reminder.aquariumName}',
                                style: TextStyle(
                                  color: AquaColors.textMuted,
                                  fontSize: 11.5,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                          ],
                        ],
                      ),
                    ],
                  ),
                ),

                // Trailing actions: Read / Clear
                Column(
                  children: [
                    if (!isRead)
                      IconButton(
                        tooltip: 'Mark as read',
                        icon: Icon(
                          Icons.mark_chat_read_outlined,
                          color: AquaColors.accent,
                          size: 18,
                        ),
                        onPressed: () => _markAsRead(reminder.id!),
                      ),
                    IconButton(
                      tooltip: 'Dismiss notification',
                      icon: Icon(
                        Icons.close_rounded,
                        color: AquaColors.textMuted,
                        size: 18,
                      ),
                      onPressed: () => _clearNotification(reminder.id!),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AquaColors.card,
                shape: BoxShape.circle,
                border: Border.all(color: AquaColors.border),
              ),
              child: Icon(
                Icons.notifications_none_rounded,
                color: AquaColors.textMuted,
                size: 38,
              ),
            ),
            const SizedBox(height: 20),
            Text(
              'No Notifications',
              style: TextStyle(
                color: AquaColors.textPrimary,
                fontSize: 19,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'You are all caught up! When scheduled aquarium maintenance is due, reminder notifications will appear here.',
              style: TextStyle(
                color: AquaColors.textSecondary,
                fontSize: 13.5,
                height: 1.45,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}

