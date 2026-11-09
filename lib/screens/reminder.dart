import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import '../theme/app_theme.dart';
import 'reminder_form.dart';
import 'notifications/notification_centre_screen.dart';

enum ReminderFilterTab {
  all,
  upcoming,
  overdue,
  completed,
}

class ReminderScreen extends StatefulWidget {
  /// Optional reminder ID to highlight when navigated from a notification.
  final String? highlightReminderId;

  const ReminderScreen({super.key, this.highlightReminderId});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  static const Color backgroundColor = AquaColors.bg;
  static const Color cardColor = AquaColors.card;
  static const Color primaryBlue = AquaColors.accent;
  static const Color textBlue = AquaColors.textSecondary;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final IReminderService _reminderService;
  final INotificationService _notificationService;

  ReminderFilterTab _activeFilter = ReminderFilterTab.all;
  bool _didCheckHighlight = false;

  _ReminderScreenState({
    IReminderService? reminderService,
    INotificationService? notificationService,
  })  : _reminderService = reminderService ?? ReminderService(),
        _notificationService = notificationService ?? NotificationService();

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─── Type helpers ─────────────────────────────────────────

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

  // ─── Actions ─────────────────────────────────────────────

  Future<void> _toggleCompleted(ReminderModel reminder) async {
    try {
      final newValue = !reminder.isCompleted;
      await _reminderService.toggleReminderCompleted(reminder.id!, newValue);

      if (newValue) {
        // Cancel notification when completing
        await _notificationService.cancelNotification(reminder.notificationId);
      } else {
        // Re-schedule notification if un-completing and date is in future
        if (reminder.scheduledDateTime.isAfter(DateTime.now())) {
          await _notificationService.scheduleReminder(reminder);
        }
      }

      if (!mounted) return;
      _showSnack(
        newValue ? 'Reminder marked as completed! ✅' : 'Reminder restored to pending',
        isSuccess: newValue,
      );
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to update reminder');
    }
  }

  Future<void> _deleteReminder(ReminderModel reminder) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Reminder',
          style: TextStyle(
            color: AquaColors.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Permanently delete "${reminder.title}"?\nThis action cannot be undone.',
          style: const TextStyle(color: AquaColors.textSecondary, height: 1.4),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text(
              'Cancel',
              style: TextStyle(color: AquaColors.textMuted),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AquaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete'),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _notificationService.cancelNotification(reminder.notificationId);
      await _reminderService.deleteReminder(reminder.id!);
      if (!mounted) return;
      _showSnack('Reminder permanently deleted', isSuccess: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to delete reminder');
    }
  }

  Future<void> _openForm({ReminderModel? reminder}) async {
    await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderFormScreen(existingReminder: reminder),
      ),
    );
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess
            ? AquaColors.success.withValues(alpha: 0.95)
            : AquaColors.cardElevated,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  // ──────────────────────────────────────────────────────────
  // BUILD
  // ──────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              // Top subtle header background
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 180,
                  decoration: const BoxDecoration(
                    color: AquaColors.bgSecondary,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(24),
                      bottomRight: Radius.circular(24),
                    ),
                  ),
                ),
              ),

              // Main content via Firestore stream
              StreamBuilder<List<ReminderModel>>(
                stream: _reminderService.getReminders(),
                builder: (context, snapshot) {
                  if (snapshot.hasError) {
                    return _buildError(snapshot.error.toString());
                  }

                  final reminders = snapshot.data ?? [];

                  // Handle highlight reminder from notification
                  if (snapshot.hasData &&
                      !_didCheckHighlight &&
                      widget.highlightReminderId != null) {
                    _didCheckHighlight = true;
                    final match = reminders.cast<ReminderModel?>().firstWhere(
                          (r) => r?.id == widget.highlightReminderId,
                          orElse: () => null,
                        );
                    if (match == null) {
                      WidgetsBinding.instance.addPostFrameCallback((_) {
                        if (mounted) {
                          _showSnack('The selected reminder was deleted or not found.');
                        }
                      });
                    }
                  }

                  // Categorize by status
                  final overdue = reminders.where((r) => r.isOverdue).toList();
                  final upcoming = reminders.where((r) => r.isPending).toList();
                  final completed = reminders.where((r) => r.isCompleted).toList();

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // App bar
                      SliverToBoxAdapter(child: _buildAppBar()),

                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Maintenance',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const Text(
                                'Dashboard',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 28,
                                  fontWeight: FontWeight.bold,
                                  letterSpacing: -0.5,
                                ),
                              ),
                              const SizedBox(height: 8),
                              Text(
                                'Keep your aquarium healthy and thriving\nwith timely reminders.',
                                style: TextStyle(
                                  color: textBlue.withValues(alpha: 0.85),
                                  fontSize: 14,
                                  height: 1.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Filter Chips Bar
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                          child: SingleChildScrollView(
                            scrollDirection: Axis.horizontal,
                            child: Row(
                              children: [
                                _buildFilterChip(
                                  label: 'All (${reminders.length})',
                                  tab: ReminderFilterTab.all,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  label: 'Upcoming (${upcoming.length})',
                                  tab: ReminderFilterTab.upcoming,
                                  color: primaryBlue,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  label: 'Overdue (${overdue.length})',
                                  tab: ReminderFilterTab.overdue,
                                  color: AquaColors.error,
                                ),
                                const SizedBox(width: 8),
                                _buildFilterChip(
                                  label: 'Completed (${completed.length})',
                                  tab: ReminderFilterTab.completed,
                                  color: AquaColors.success,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),

                      // Loading indicator
                      if (snapshot.connectionState == ConnectionState.waiting &&
                          snapshot.data == null)
                        const SliverToBoxAdapter(
                          child: Padding(
                            padding: EdgeInsets.all(40),
                            child: Center(
                              child: CircularProgressIndicator(color: primaryBlue),
                            ),
                          ),
                        )
                      else if (reminders.isEmpty)
                        _buildEmptyState()
                      else ..._buildFilteredSections(
                          overdue: overdue,
                          upcoming: upcoming,
                          completed: completed,
                        ),

                      const SliverToBoxAdapter(child: SizedBox(height: 100)),
                    ],
                  );
                },
              ),
            ],
          ),
        ),
      ),

      // FAB
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: primaryBlue,
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: FloatingActionButton(
          onPressed: () => _openForm(),
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(Icons.add, color: Colors.white, size: 28),
        ),
      ),
    );
  }

  // ─── App Bar ─────────────────────────────────────────────

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          GestureDetector(
            onTap: () => Navigator.pop(context),
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: const Icon(Icons.arrow_back_ios_new, color: textBlue, size: 16),
            ),
          ),
          const SizedBox(width: 12),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.water_drop, color: primaryBlue, size: 20),
          ),
          const SizedBox(width: 10),
          const Text(
            'AquaIntel',
            style: TextStyle(
              color: Colors.white,
              fontSize: 20,
              fontWeight: FontWeight.bold,
              letterSpacing: 0.5,
            ),
          ),
          const Spacer(),
          GestureDetector(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (_) => const NotificationCentreScreen()),
              );
            },
            child: Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: cardColor.withValues(alpha: 0.6),
                shape: BoxShape.circle,
                border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.15), width: 1),
              ),
              child: const Icon(Icons.notifications_outlined,
                  color: textBlue, size: 20),
            ),
          ),
        ],
      ),
    );
  }

  // ─── Filter Chip ──────────────────────────────────────────

  Widget _buildFilterChip({
    required String label,
    required ReminderFilterTab tab,
    Color? color,
  }) {
    final isSelected = _activeFilter == tab;
    final activeColor = color ?? primaryBlue;

    return GestureDetector(
      onTap: () => setState(() => _activeFilter = tab),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
        decoration: BoxDecoration(
          color: isSelected
              ? activeColor.withValues(alpha: 0.2)
              : cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: isSelected
                ? activeColor
                : AquaColors.border,
            width: isSelected ? 1.4 : 1.0,
          ),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? activeColor : AquaColors.textSecondary,
            fontSize: 12.5,
            fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
          ),
        ),
      ),
    );
  }

  // ─── Sections Builder ─────────────────────────────────────

  List<Widget> _buildFilteredSections({
    required List<ReminderModel> overdue,
    required List<ReminderModel> upcoming,
    required List<ReminderModel> completed,
  }) {
    final widgets = <Widget>[];

    // Filter: Overdue only
    if (_activeFilter == ReminderFilterTab.overdue) {
      if (overdue.isEmpty) {
        return [_buildFilteredEmptyState('No overdue reminders! Your tank is on track. 🐠')];
      }
      widgets.add(_buildSectionHeader('Overdue Tasks (${overdue.length})', AquaColors.error));
      widgets.add(_buildReminderList(overdue));
      return widgets;
    }

    // Filter: Upcoming only
    if (_activeFilter == ReminderFilterTab.upcoming) {
      if (upcoming.isEmpty) {
        return [_buildFilteredEmptyState('No upcoming reminders scheduled.')];
      }
      widgets.add(_buildSectionHeader('Upcoming Tasks (${upcoming.length})', primaryBlue));
      widgets.add(_buildReminderList(upcoming));
      return widgets;
    }

    // Filter: Completed only
    if (_activeFilter == ReminderFilterTab.completed) {
      if (completed.isEmpty) {
        return [_buildFilteredEmptyState('No completed reminders yet.')];
      }
      widgets.add(_buildSectionHeader('Completed History (${completed.length})', AquaColors.success));
      widgets.add(_buildReminderList(completed));
      return widgets;
    }

    // Filter: All (Display Overdue, Upcoming, Completed in 3 distinct sections)
    if (overdue.isNotEmpty) {
      widgets.add(_buildSectionHeader('Overdue (${overdue.length})', AquaColors.error));
      widgets.add(_buildReminderList(overdue));
    }

    if (upcoming.isNotEmpty) {
      widgets.add(_buildSectionHeader('Upcoming (${upcoming.length})', primaryBlue));
      widgets.add(_buildReminderList(upcoming));
    }

    if (completed.isNotEmpty) {
      widgets.add(_buildSectionHeader('Completed (${completed.length})', AquaColors.success));
      widgets.add(_buildReminderList(completed));
    }

    return widgets;
  }

  // ─── Section Header ──────────────────────────────────────

  SliverToBoxAdapter _buildSectionHeader(String label, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 18,
              decoration: BoxDecoration(
                color: color,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: color,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Reminder List ───────────────────────────────────────

  SliverPadding _buildReminderList(List<ReminderModel> reminders) {
    return SliverPadding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
          (context, index) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: _buildTaskCard(reminders[index]),
            );
          },
          childCount: reminders.length,
        ),
      ),
    );
  }

  // ─── Task Card ───────────────────────────────────────────

  Widget _buildTaskCard(ReminderModel reminder) {
    final completed = reminder.isCompleted;
    final isOverdue = reminder.isOverdue;
    final isHighlighted = widget.highlightReminderId != null &&
        reminder.id == widget.highlightReminderId;
    final color = _colorForType(reminder.type);
    final icon = _iconForType(reminder.type);

    Color borderColor;
    if (isHighlighted) {
      borderColor = AquaColors.accent;
    } else if (completed) {
      borderColor = AquaColors.border;
    } else if (isOverdue) {
      borderColor = AquaColors.error.withValues(alpha: 0.45);
    } else {
      borderColor = primaryBlue.withValues(alpha: 0.2);
    }

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: AquaColors.error.withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        await _deleteReminder(reminder);
        return false; // Stream update handles UI refresh
      },
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isHighlighted
              ? AquaColors.cardElevated
              : (completed ? cardColor.withValues(alpha: 0.6) : cardColor),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: borderColor,
            width: isHighlighted ? 2.0 : (isOverdue ? 1.4 : 1.0),
          ),
          boxShadow: [
            BoxShadow(
              color: isHighlighted
                  ? AquaColors.accent.withValues(alpha: 0.3)
                  : Colors.black.withValues(alpha: 0.12),
              blurRadius: isHighlighted ? 14 : 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Icon
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: completed
                    ? Colors.white.withValues(alpha: 0.05)
                    : (isOverdue
                        ? AquaColors.error.withValues(alpha: 0.15)
                        : color.withValues(alpha: 0.18)),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: completed
                    ? AquaColors.textMuted
                    : (isOverdue ? AquaColors.error : color),
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Badges: Status + Category + Highlight
                  Row(
                    children: [
                      // Status Badge
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: completed
                              ? AquaColors.success.withValues(alpha: 0.15)
                              : (isOverdue
                                  ? AquaColors.error.withValues(alpha: 0.15)
                                  : primaryBlue.withValues(alpha: 0.15)),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reminder.status.label.toUpperCase(),
                          style: TextStyle(
                            color: completed
                                ? AquaColors.success
                                : (isOverdue
                                    ? AquaColors.error
                                    : primaryBlue),
                            fontSize: 9.5,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      // Category Tag
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: color.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          reminder.type.label,
                          style: TextStyle(
                            color: color,
                            fontSize: 9.5,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      if (isHighlighted) ...[
                        const SizedBox(width: 6),
                        Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 6, vertical: 2),
                          decoration: BoxDecoration(
                            color: AquaColors.accent,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: const Text(
                            'SELECTED',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 9.0,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ],
                  ),
                  const SizedBox(height: 5),

                  // Title
                  Text(
                    reminder.title,
                    style: TextStyle(
                      color: completed
                          ? AquaColors.textMuted
                          : AquaColors.textPrimary,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      decoration: completed
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      decorationColor: textBlue.withValues(alpha: 0.5),
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 3),

                  if (reminder.aquariumName.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 2),
                      child: Text(
                        reminder.aquariumName,
                        style: TextStyle(
                          color: primaryBlue.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),

                  // Scheduled Date / Overdue Date
                  Row(
                    children: [
                      Icon(
                        isOverdue
                            ? Icons.warning_amber_rounded
                            : Icons.access_time,
                        color: isOverdue ? AquaColors.error : textBlue.withValues(alpha: 0.6),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, hh:mm a')
                            .format(reminder.scheduledDateTime),
                        style: TextStyle(
                          color: isOverdue
                              ? AquaColors.error
                              : textBlue.withValues(alpha: 0.7),
                          fontSize: 12,
                          fontWeight: isOverdue
                              ? FontWeight.w600
                              : FontWeight.normal,
                        ),
                      ),
                    ],
                  ),

                  // Completed timestamp if completed
                  if (completed && reminder.completedAt != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      'Completed: ${DateFormat('MMM dd, hh:mm a').format(reminder.completedAt!)}',
                      style: const TextStyle(
                        color: AquaColors.success,
                        fontSize: 11,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ],
              ),
            ),

            // Edit button (for pending & overdue)
            if (!completed)
              GestureDetector(
                onTap: () => _openForm(reminder: reminder),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 6),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: primaryBlue.withValues(alpha: 0.85),
                    size: 16,
                  ),
                ),
              ),

            // Complete toggle button
            GestureDetector(
              onTap: () => _toggleCompleted(reminder),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 32,
                height: 32,
                margin: const EdgeInsets.only(right: 4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? AquaColors.success : Colors.transparent,
                  border: Border.all(
                    color: completed
                        ? AquaColors.success
                        : (isOverdue ? AquaColors.error : textBlue.withValues(alpha: 0.5)),
                    width: 2,
                  ),
                  boxShadow: completed
                      ? [
                          BoxShadow(
                            color: AquaColors.success.withValues(alpha: 0.35),
                            blurRadius: 8,
                            offset: const Offset(0, 2),
                          ),
                        ]
                      : [],
                ),
                child: completed
                    ? const Icon(Icons.check, color: Colors.white, size: 18)
                    : null,
              ),
            ),

            // Delete button
            GestureDetector(
              onTap: () => _deleteReminder(reminder),
              child: Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AquaColors.cardElevated,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.delete_outline_rounded,
                  color: AquaColors.textMuted,
                  size: 18,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Empty States ─────────────────────────────────────────

  SliverToBoxAdapter _buildEmptyState() {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
        child: Column(
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: AquaColors.border),
              ),
              child: const Icon(
                Icons.event_note_outlined,
                color: AquaColors.textMuted,
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No Reminders Yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Schedule feedings, water changes, and filter cleanings\nto keep your aquariums healthy.',
              style: TextStyle(color: textBlue, fontSize: 14),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => _openForm(),
              icon: const Icon(Icons.add, size: 18),
              label: const Text('Add First Reminder'),
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryBlue,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
              ),
            ),
          ],
        ),
      ),
    );
  }

  SliverToBoxAdapter _buildFilteredEmptyState(String message) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 48, 20, 20),
        child: Column(
          children: [
            Container(
              width: 60,
              height: 60,
              decoration: BoxDecoration(
                color: cardColor,
                shape: BoxShape.circle,
                border: Border.all(color: AquaColors.border),
              ),
              child: const Icon(
                Icons.check_circle_outline,
                color: AquaColors.textMuted,
                size: 30,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              message,
              style: const TextStyle(
                color: AquaColors.textSecondary,
                fontSize: 14,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: AquaColors.error, size: 48),
            const SizedBox(height: 16),
            Text(
              'Failed to load reminders: $error',
              style: const TextStyle(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      ),
    );
  }
}
