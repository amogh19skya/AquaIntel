import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import 'reminder_form.dart';

class ReminderScreen extends StatefulWidget {
  const ReminderScreen({super.key});

  @override
  State<ReminderScreen> createState() => _ReminderScreenState();
}

class _ReminderScreenState extends State<ReminderScreen>
    with SingleTickerProviderStateMixin {
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  final _reminderService = ReminderService();
  final _notificationService = NotificationService();

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
        return Icons.settings;
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
      // Cancel notification if marking complete
      if (newValue) {
        await _notificationService.cancelNotification(reminder.notificationId);
      }
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
        title: const Text('Delete Reminder',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        content: Text(
          'Delete "${reminder.title}"?',
          style: TextStyle(color: textBlue.withValues(alpha: 0.8)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text('Cancel',
                style: TextStyle(color: textBlue.withValues(alpha: 0.6))),
          ),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
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
      _showSnack('Reminder deleted', isSuccess: true);
    } catch (_) {
      if (!mounted) return;
      _showSnack('Failed to delete reminder');
    }
  }

  Future<void> _openForm({ReminderModel? reminder}) async {
    final result = await Navigator.push<bool>(
      context,
      MaterialPageRoute(
        builder: (_) => ReminderFormScreen(existingReminder: reminder),
      ),
    );
    if (result == true) {
      // Stream auto-refreshes; nothing needed
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess
            ? const Color(0xFF4CD964).withValues(alpha: 0.9)
            : cardColor,
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
              // Top gradient
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 220,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        topColor,
                        Color(0xFF174A6A),
                        backgroundColor,
                      ],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
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
                  final now = DateTime.now();
                  // Upcoming: not completed and in future (or today)
                  final upcoming = reminders
                      .where((r) =>
                          !r.isCompleted &&
                          r.scheduledDateTime.isAfter(now.subtract(const Duration(seconds: 1))))
                      .toList();
                  // Urgent: due within next 24 hours and not completed
                  final urgent = upcoming
                      .where((r) =>
                          r.scheduledDateTime
                              .isBefore(now.add(const Duration(hours: 24))))
                      .toList();
                  final normal = upcoming
                      .where((r) => !urgent.contains(r))
                      .toList();
                  final completed = reminders.where((r) => r.isCompleted).toList();

                  return CustomScrollView(
                    physics: const BouncingScrollPhysics(),
                    slivers: [
                      // App bar
                      SliverToBoxAdapter(child: _buildAppBar()),

                      // Header
                      SliverToBoxAdapter(
                        child: Padding(
                          padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
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
                      else ...[
                        // Urgent Tasks
                        if (urgent.isNotEmpty) ...[
                          _buildSectionHeader(
                            'Urgent (${urgent.length})',
                            const Color(0xFFFF9800),
                          ),
                          _buildReminderList(urgent),
                        ],

                        // Upcoming Tasks
                        if (normal.isNotEmpty) ...[
                          _buildSectionHeader('Upcoming (${normal.length})', primaryBlue),
                          _buildReminderList(normal),
                        ],

                        // Completed
                        if (completed.isNotEmpty) ...[
                          _buildSectionHeader('Completed (${completed.length})',
                              const Color(0xFF66BB6A)),
                          _buildReminderList(completed),
                        ],
                      ],

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
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF29A8DF), Color(0xFF1B8FC4)],
          ),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
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
          Container(
            width: 38,
            height: 38,
            decoration: BoxDecoration(
              color: cardColor.withValues(alpha: 0.6),
              shape: BoxShape.circle,
              border: Border.all(color: primaryBlue.withValues(alpha: 0.15), width: 1),
            ),
            child: const Icon(Icons.notifications_outlined, color: textBlue, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Section Header ──────────────────────────────────────

  SliverToBoxAdapter _buildSectionHeader(String label, Color color) {
    return SliverToBoxAdapter(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 24, 20, 12),
        child: Row(
          children: [
            Container(
              width: 4,
              height: 20,
              decoration:
                  BoxDecoration(color: color, borderRadius: BorderRadius.circular(2)),
            ),
            const SizedBox(width: 10),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 18,
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
    final color = _colorForType(reminder.type);
    final icon = _iconForType(reminder.type);
    final isUrgent = !completed &&
        reminder.scheduledDateTime
            .isBefore(DateTime.now().add(const Duration(hours: 24)));

    return Dismissible(
      key: ValueKey(reminder.id),
      direction: DismissDirection.endToStart,
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.only(right: 20),
        decoration: BoxDecoration(
          color: const Color(0xFFEF5350).withValues(alpha: 0.8),
          borderRadius: BorderRadius.circular(16),
        ),
        child: const Icon(Icons.delete_outline, color: Colors.white, size: 26),
      ),
      confirmDismiss: (_) async {
        await _deleteReminder(reminder);
        return false; // Stream update handles UI refresh
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: completed ? cardColor.withValues(alpha: 0.5) : cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: isUrgent && !completed
                ? const Color(0xFFFF9800).withValues(alpha: 0.25)
                : primaryBlue.withValues(alpha: 0.1),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.12),
              blurRadius: 10,
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
                    ? color.withValues(alpha: 0.1)
                    : color.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                color: completed ? color.withValues(alpha: 0.4) : color,
                size: 22,
              ),
            ),
            const SizedBox(width: 14),

            // Details
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    reminder.title,
                    style: TextStyle(
                      color: completed
                          ? Colors.white.withValues(alpha: 0.5)
                          : Colors.white,
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
                    Text(
                      reminder.aquariumName,
                      style: TextStyle(
                        color: primaryBlue.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  const SizedBox(height: 2),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time,
                        color: textBlue.withValues(alpha: 0.6),
                        size: 13,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        DateFormat('MMM dd, hh:mm a')
                            .format(reminder.scheduledDateTime),
                        style: TextStyle(
                          color: textBlue.withValues(alpha: 0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            // Edit button
            if (!completed)
              GestureDetector(
                onTap: () => _openForm(reminder: reminder),
                child: Container(
                  width: 32,
                  height: 32,
                  margin: const EdgeInsets.only(right: 8),
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(
                    Icons.edit_outlined,
                    color: primaryBlue.withValues(alpha: 0.8),
                    size: 16,
                  ),
                ),
              ),

            // Complete toggle
            GestureDetector(
              onTap: () => _toggleCompleted(reminder),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 250),
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: completed ? primaryBlue : Colors.transparent,
                  border: Border.all(
                    color: completed
                        ? primaryBlue
                        : textBlue.withValues(alpha: 0.4),
                    width: 2,
                  ),
                  boxShadow: completed
                      ? [
                          BoxShadow(
                            color: primaryBlue.withValues(alpha: 0.3),
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
          ],
        ),
      ),
    );
  }

  // ─── Empty State ─────────────────────────────────────────

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
                color: primaryBlue.withValues(alpha: 0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                Icons.alarm_add_outlined,
                color: primaryBlue.withValues(alpha: 0.6),
                size: 40,
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              'No reminders yet',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Tap the + button to create your\nfirst aquarium reminder.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.7),
                fontSize: 14,
                height: 1.5,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ─── Error State ─────────────────────────────────────────

  Widget _buildError(String error) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.error_outline, color: Color(0xFFEF5350), size: 48),
            const SizedBox(height: 16),
            const Text(
              'Failed to load reminders',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Please check your internet connection.',
              textAlign: TextAlign.center,
              style: TextStyle(color: textBlue.withValues(alpha: 0.7), fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }
}
