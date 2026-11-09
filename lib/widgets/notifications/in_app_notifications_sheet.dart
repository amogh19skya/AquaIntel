import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminder_model.dart';
import '../../services/reminder_service.dart';
import '../../services/notification_service.dart';
import '../../theme/app_theme.dart';
import '../../screens/reminder.dart';

/// In-app notification bottom sheet displaying notifications generated
/// from user-created reminders (due, overdue, or upcoming).
class InAppNotificationsSheet extends StatelessWidget {
  final List<ReminderModel> reminders;
  final IReminderService _reminderService = ReminderService();
  final INotificationService _notificationService = NotificationService();

  InAppNotificationsSheet({super.key, required this.reminders});

  /// Displays the notifications bottom sheet.
  static void show(BuildContext context, List<ReminderModel> reminders) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => InAppNotificationsSheet(reminders: reminders),
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

  @override
  Widget build(BuildContext context) {
    // Filter active notifications: overdue or pending
    final active = reminders.where((r) => !r.isCompleted).toList()
      ..sort((a, b) => a.scheduledDateTime.compareTo(b.scheduledDateTime));

    return Container(
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.75,
      ),
      decoration: const BoxDecoration(
        color: AquaColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        border: Border(
          top: BorderSide(color: AquaColors.border, width: 1),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Drag handle
          Center(
            child: Container(
              margin: const EdgeInsets.only(top: 12, bottom: 8),
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: AquaColors.border,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),

          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            child: Row(
              children: [
                const Icon(
                  Icons.notifications_active_outlined,
                  color: AquaColors.accent,
                  size: 22,
                ),
                const SizedBox(width: 10),
                const Text(
                  'Reminder Notifications',
                  style: TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                if (active.isNotEmpty) ...[
                  const SizedBox(width: 8),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 8, vertical: 2),
                    decoration: BoxDecoration(
                      color: AquaColors.accent.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${active.length}',
                      style: const TextStyle(
                        color: AquaColors.accent,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
                const Spacer(),
                TextButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ReminderScreen()),
                    );
                  },
                  child: const Text('View All'),
                ),
              ],
            ),
          ),

          const Divider(color: AquaColors.border, height: 1),

          // Notification List
          Flexible(
            child: active.isEmpty
                ? Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 24, vertical: 48),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            color: AquaColors.card,
                            shape: BoxShape.circle,
                            border: Border.all(color: AquaColors.border),
                          ),
                          child: const Icon(
                            Icons.notifications_off_outlined,
                            color: AquaColors.textMuted,
                            size: 28,
                          ),
                        ),
                        const SizedBox(height: 16),
                        const Text(
                          'No Active Notifications',
                          style: TextStyle(
                            color: AquaColors.textPrimary,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 6),
                        const Text(
                          'You are all caught up with your aquarium tasks! 🐠',
                          style: TextStyle(
                            color: AquaColors.textSecondary,
                            fontSize: 13,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    shrinkWrap: true,
                    padding: const EdgeInsets.fromLTRB(16, 16, 16, 32),
                    itemCount: active.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 10),
                    itemBuilder: (context, index) {
                      final reminder = active[index];
                      final isOverdue = reminder.isOverdue;
                      final typeColor = _colorForType(reminder.type);
                      final typeIcon = _iconForType(reminder.type);
                      final timeStr = DateFormat('EEE, MMM d • h:mm a')
                          .format(reminder.scheduledDateTime);
                      final message = _formatNotificationMessage(reminder);

                      return Container(
                        padding: const EdgeInsets.all(14),
                        decoration: BoxDecoration(
                          color: AquaColors.card,
                          borderRadius: BorderRadius.circular(16),
                          border: Border.all(
                            color: isOverdue
                                ? AquaColors.error.withValues(alpha: 0.4)
                                : AquaColors.border,
                          ),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Category Icon
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: isOverdue
                                    ? AquaColors.error.withValues(alpha: 0.15)
                                    : typeColor.withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Icon(
                                typeIcon,
                                color: isOverdue
                                    ? AquaColors.error
                                    : typeColor,
                                size: 20,
                              ),
                            ),
                            const SizedBox(width: 12),

                            // Notification Content
                            Expanded(
                              child: InkWell(
                                onTap: () {
                                  Navigator.pop(context);
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (_) => const ReminderScreen()),
                                  );
                                },
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      children: [
                                        // Category Badge
                                        Container(
                                          padding: const EdgeInsets.symmetric(
                                              horizontal: 6, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: typeColor
                                                .withValues(alpha: 0.15),
                                            borderRadius:
                                                BorderRadius.circular(6),
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
                                        // Overdue tag
                                        if (isOverdue)
                                          Container(
                                            padding:
                                                const EdgeInsets.symmetric(
                                                    horizontal: 6,
                                                    vertical: 2),
                                            decoration: BoxDecoration(
                                              color: AquaColors.error
                                                  .withValues(alpha: 0.15),
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                            ),
                                            child: const Text(
                                              'OVERDUE',
                                              style: TextStyle(
                                                color: AquaColors.error,
                                                fontSize: 9.5,
                                                fontWeight: FontWeight.bold,
                                              ),
                                            ),
                                          ),
                                      ],
                                    ),
                                    const SizedBox(height: 5),

                                    // Title
                                    Text(
                                      reminder.title,
                                      style: const TextStyle(
                                        color: AquaColors.textPrimary,
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    const SizedBox(height: 3),

                                    // Message
                                    Text(
                                      message,
                                      style: const TextStyle(
                                        color: AquaColors.textSecondary,
                                        fontSize: 13,
                                        height: 1.3,
                                      ),
                                    ),
                                    const SizedBox(height: 6),

                                    // Scheduled Time
                                    Row(
                                      children: [
                                        Icon(
                                          isOverdue
                                              ? Icons.warning_amber_rounded
                                              : Icons.schedule,
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
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),

                            // Mark Completed Action Button
                            IconButton(
                              tooltip: 'Mark as Completed',
                              icon: const Icon(
                                Icons.check_circle_outline_rounded,
                                color: AquaColors.accent,
                                size: 24,
                              ),
                              onPressed: () async {
                                await _notificationService.cancelNotification(
                                    reminder.notificationId);
                                await _reminderService.toggleReminderCompleted(
                                    reminder.id!, true);
                              },
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

