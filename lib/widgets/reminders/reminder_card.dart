import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/reminder_model.dart';
import '../../theme/app_theme.dart';

/// Single-responsibility widget for displaying an individual reminder item card (SRP).
/// Supports Pending, Overdue, and Completed visual statuses.
class ReminderCard extends StatelessWidget {
  final ReminderModel reminder;
  final ValueChanged<ReminderModel> onToggleCompleted;
  final ValueChanged<ReminderModel> onDelete;
  final ValueChanged<ReminderModel> onTap;
  final Color cardColor;
  final Color primaryBlue;
  final Color textBlue;

  const ReminderCard({
    super.key,
    required this.reminder,
    required this.onToggleCompleted,
    required this.onDelete,
    required this.onTap,
    required this.cardColor,
    required this.primaryBlue,
    required this.textBlue,
  });

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

  @override
  Widget build(BuildContext context) {
    final typeColor = _colorForType(reminder.type);
    final typeIcon = _iconForType(reminder.type);
    final status = reminder.status;
    final isDone = status == ReminderStatus.completed;
    final isOverdue = status == ReminderStatus.overdue;

    final dateStr =
        DateFormat('EEE, MMM d • h:mm a').format(reminder.scheduledDateTime);
    final completedStr = reminder.completedAt != null
        ? DateFormat('MMM d, h:mm a').format(reminder.completedAt!)
        : null;

    Color borderColor;
    if (isDone) {
      borderColor = AquaColors.border;
    } else if (isOverdue) {
      borderColor = AquaColors.error.withValues(alpha: 0.5);
    } else {
      borderColor = typeColor.withValues(alpha: 0.35);
    }

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: borderColor, width: isOverdue ? 1.4 : 1.0),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: () => onTap(reminder),
          borderRadius: BorderRadius.circular(18),
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ─── Category Icon Avatar ───
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isDone
                        ? Colors.white.withValues(alpha: 0.05)
                        : (isOverdue
                            ? AquaColors.error.withValues(alpha: 0.15)
                            : typeColor.withValues(alpha: 0.15)),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(
                    typeIcon,
                    color: isDone
                        ? AquaColors.textMuted
                        : (isOverdue ? AquaColors.error : typeColor),
                    size: 24,
                  ),
                ),
                const SizedBox(width: 14),

                // ─── Details ───
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Status and Category Badges
                      Wrap(
                        spacing: 6,
                        runSpacing: 4,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          // Status Badge
                          _buildStatusBadge(status),
                          // Category Badge
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 6, vertical: 2),
                            decoration: BoxDecoration(
                              color: typeColor.withValues(alpha: 0.12),
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              reminder.type.label,
                              style: TextStyle(
                                color: typeColor,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),

                      // Title
                      Text(
                        reminder.title,
                        style: TextStyle(
                          color: isDone
                              ? AquaColors.textMuted
                              : AquaColors.textPrimary,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          // No strikethrough – green checkmark icon conveys completion
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),

                      // Scheduled Date/Time
                      Row(
                        children: [
                          Icon(
                            isOverdue
                                ? Icons.warning_amber_rounded
                                : Icons.schedule,
                            color: isOverdue ? AquaColors.error : textBlue,
                            size: 13,
                          ),
                          const SizedBox(width: 4),
                          Flexible(
                            child: Text(
                              dateStr,
                              style: TextStyle(
                                color: isOverdue ? AquaColors.error : textBlue,
                                fontSize: 12,
                                fontWeight: isOverdue
                                    ? FontWeight.w600
                                    : FontWeight.normal,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                        ],
                      ),

                      // Completed Timestamp if completed
                      if (isDone && completedStr != null) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Completed: $completedStr',
                          style: TextStyle(
                            color: AquaColors.success,
                            fontSize: 11,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],

                      // Aquarium Name if set
                      if (reminder.aquariumName.isNotEmpty) ...[
                        const SizedBox(height: 2),
                        Text(
                          'Tank: ${reminder.aquariumName}',
                          style: TextStyle(
                            color: AquaColors.textMuted,
                            fontSize: 11,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ],
                  ),
                ),

                // ─── Actions ───
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Mark as Completed toggle
                    IconButton(
                      tooltip: isDone ? 'Mark as Pending' : 'Mark as Completed',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        isDone
                            ? Icons.check_circle_rounded
                            : Icons.radio_button_unchecked_rounded,
                        color: isDone
                            ? AquaColors.success
                            : (isOverdue ? AquaColors.error : textBlue),
                        size: 24,
                      ),
                      onPressed: () => onToggleCompleted(reminder),
                    ),
                    const SizedBox(height: 4),
                    // Delete button
                    IconButton(
                      tooltip: 'Delete Reminder',
                      visualDensity: VisualDensity.compact,
                      padding: const EdgeInsets.all(4),
                      constraints: const BoxConstraints(),
                      icon: Icon(
                        Icons.delete_outline_rounded,
                        color: AquaColors.textMuted,
                        size: 20,
                      ),
                      onPressed: () => onDelete(reminder),
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

  Widget _buildStatusBadge(ReminderStatus status) {
    Color bg;
    Color fg;
    String text;

    switch (status) {
      case ReminderStatus.overdue:
        bg = AquaColors.error.withValues(alpha: 0.18);
        fg = AquaColors.error;
        text = 'OVERDUE';
        break;
      case ReminderStatus.pending:
        bg = AquaColors.accent.withValues(alpha: 0.18);
        fg = AquaColors.accent;
        text = 'UPCOMING';
        break;
      case ReminderStatus.completed:
        bg = AquaColors.success.withValues(alpha: 0.18);
        fg = AquaColors.success;
        text = 'COMPLETED';
        break;
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: fg,
          fontSize: 9.5,
          fontWeight: FontWeight.bold,
          letterSpacing: 0.5,
        ),
      ),
    );
  }
}
