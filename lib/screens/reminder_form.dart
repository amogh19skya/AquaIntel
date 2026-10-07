import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';
import '../models/aquarium_model.dart';
import '../services/reminder_service.dart';
import '../services/notification_service.dart';
import '../services/settings_service.dart';
import '../services/aquarium_service.dart';

/// Schedule Maintenance form screen.
/// Supports creating a new reminder or editing an existing one.
class ReminderFormScreen extends StatefulWidget {
  /// Pass an existing reminder to enter edit mode.
  final ReminderModel? existingReminder;

  const ReminderFormScreen({super.key, this.existingReminder});

  @override
  State<ReminderFormScreen> createState() => _ReminderFormScreenState();
}

class _ReminderFormScreenState extends State<ReminderFormScreen>
    with SingleTickerProviderStateMixin {
  // ─── AquaIntel colour palette ───
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);
  static const Color accentGreen = Color(0xFF4CD964);

  // ─── Services ───
  final _reminderService = ReminderService();
  final _notificationService = NotificationService();
  final _settingsService = SettingsService();
  final _aquariumService = AquariumService();

  // ─── Form state ───
  final _titleController = TextEditingController();
  final _descriptionController = TextEditingController();
  ReminderType _selectedType = ReminderType.feeding;
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();
  AquariumModel? _selectedAquarium;
  List<AquariumModel> _aquariums = [];
  bool _isLoading = false;
  bool _isLoadingAquariums = true;

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  bool get _isEditMode => widget.existingReminder != null;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(parent: _animController, curve: Curves.easeOut);
    _animController.forward();
    _loadAquariums();

    // Pre-fill form if editing
    if (_isEditMode) {
      final r = widget.existingReminder!;
      _titleController.text = r.title;
      _descriptionController.text = r.description;
      _selectedType = r.type;
      _selectedDate = r.scheduledDateTime;
      _selectedTime = TimeOfDay.fromDateTime(r.scheduledDateTime);
    }
  }

  Future<void> _loadAquariums() async {
    try {
      final list = await _aquariumService.getAquariums().first;
      if (!mounted) return;
      setState(() {
        _aquariums = list;
        _isLoadingAquariums = false;
        // Pre-select aquarium in edit mode
        if (_isEditMode && widget.existingReminder!.aquariumId != null) {
          final match = list.cast<AquariumModel?>().firstWhere(
            (a) => a?.id == widget.existingReminder!.aquariumId,
            orElse: () => null,
          );
          _selectedAquarium = match ?? (list.isNotEmpty ? list.first : null);
        } else if (list.isNotEmpty) {
          _selectedAquarium = list.first;
        }
      });
    } catch (e, st) {
      debugPrint('AQUARIUM LOAD ERROR: $e');
      debugPrintStack(stackTrace: st);
      if (mounted) setState(() => _isLoadingAquariums = false);
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    _titleController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  // ─── Pickers ─────────────────────────────────────────────

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
      builder: (context, child) => _pickerTheme(child),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => _pickerTheme(child),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  Widget _pickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: primaryBlue,
          onPrimary: Colors.white,
          surface: cardColor,
          onSurface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(backgroundColor: backgroundColor),
      ),
      child: child!,
    );
  }

  // ─── Submit ──────────────────────────────────────────────

  Future<void> _submitReminder() async {
    // ── Validation ────────────────────────────────────────
    if (_titleController.text.trim().isEmpty) {
      _showSnack('Please enter a reminder title');
      return;
    }
    if (_aquariums.isNotEmpty && _selectedAquarium == null) {
      _showSnack('Please select an aquarium');
      return;
    }

    final scheduledDT = DateTime(
      _selectedDate.year,
      _selectedDate.month,
      _selectedDate.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    if (scheduledDT.isBefore(DateTime.now())) {
      _showSnack('Please select a future date and time');
      return;
    }

    setState(() => _isLoading = true);

    // ── Step 1: Read all relevant notification settings ──
    bool notificationsOn = true;
    bool feedingAlertsOn = true;
    bool waterChangeAlertsOn = true;
    bool soundOn = false;

    try {
      notificationsOn = await _settingsService.getNotificationsEnabled();
      feedingAlertsOn = await _settingsService.getFeedingAlerts();
      waterChangeAlertsOn = await _settingsService.getWaterChangeAlerts();
      soundOn = await _settingsService.getSoundEnabled();
    } catch (e) {
      debugPrint('REMINDER: could not read settings, using defaults: $e');
    }

    final now = DateTime.now();
    final notificationId = _isEditMode
        ? widget.existingReminder!.notificationId
        : scheduledDT.millisecondsSinceEpoch.remainder(2147483647);

    final reminder = ReminderModel(
      id: _isEditMode ? widget.existingReminder!.id : null,
      title: _titleController.text.trim(),
      description: _descriptionController.text.trim(),
      type: _selectedType,
      aquariumId: _selectedAquarium?.id,
      aquariumName: _selectedAquarium?.name ?? 'My Aquarium',
      scheduledDateTime: scheduledDT,
      isCompleted: false,
      notificationEnabled: notificationsOn,
      createdAt: _isEditMode ? widget.existingReminder!.createdAt : now,
      updatedAt: now,
      notificationId: notificationId,
    );

    // ── Step 2: Save to Firestore ─────────────────────────
    try {
      if (_isEditMode) {
        await _notificationService.cancelNotification(
            widget.existingReminder!.notificationId);
        await _reminderService.updateReminder(reminder);
        debugPrint('REMINDER: updated successfully id=${reminder.id}');
      } else {
        final docId = await _reminderService.addReminder(reminder);
        debugPrint('REMINDER: saved successfully docId=$docId');
      }
    } catch (e, st) {
      debugPrint('REMINDER SAVE FAILED BECAUSE: $e');
      debugPrintStack(stackTrace: st);
      if (!mounted) return;
      setState(() => _isLoading = false);
      _showSnack('Failed to save reminder: $e');
      return;
    }

    // ── Step 3: Schedule local notification (non-fatal) ──
    // Decision tree:
    //   Push Notifications ON
    //     Feeding    → also check feedingAlerts switch
    //     WaterChange → also check waterChangeAlerts switch
    //     Others     → schedule if master is ON
    if (notificationsOn) {
      try {
        final aquariumName = reminder.aquariumName;

        if (reminder.type == ReminderType.feeding && feedingAlertsOn) {
          await _notificationService.scheduleFeedingReminder(
            id: notificationId,
            aquariumName: aquariumName,
            scheduledAt: scheduledDT,
            soundEnabled: soundOn,
          );
        } else if (reminder.type == ReminderType.waterChange &&
            waterChangeAlertsOn) {
          await _notificationService.scheduleWaterChangeReminder(
            id: notificationId,
            aquariumName: aquariumName,
            scheduledAt: scheduledDT,
            soundEnabled: soundOn,
          );
        } else if (reminder.type != ReminderType.feeding &&
            reminder.type != ReminderType.waterChange) {
          // Other types (filter, medication, maintenance, custom, tank cleaning)
          await _notificationService.scheduleGenericReminder(
            id: notificationId,
            title: 'AquaIntel – ${reminder.type.label}',
            body: _buildNotificationBody(reminder),
            scheduledAt: scheduledDT,
            soundEnabled: soundOn,
          );
        } else {
          debugPrint(
              'REMINDER: notification skipped – type-specific switch is OFF');
        }
        debugPrint(
            'REMINDER: notification scheduled id=$notificationId at $scheduledDT');
      } catch (e, st) {
        // Notification failure is non-fatal; reminder is already saved.
        debugPrint(
            'REMINDER: notification scheduling failed (reminder still saved): $e');
        debugPrintStack(stackTrace: st);
      }
    } else {
      debugPrint(
          'REMINDER: notification skipped – Push Notifications master switch is OFF');
    }

    // ── Step 4: Success ───────────────────────────────────
    if (!mounted) return;
    setState(() => _isLoading = false);
    _showSnack(
      _isEditMode ? 'Reminder updated successfully!' : 'Reminder set successfully!',
      isSuccess: true,
    );
    Navigator.pop(context, true);
  }

  String _buildNotificationBody(ReminderModel r) {
    final aquarium = r.aquariumName.isNotEmpty ? r.aquariumName : 'your aquarium';
    switch (r.type) {
      case ReminderType.feeding:
        return 'Time to feed the fish in $aquarium.';
      case ReminderType.waterChange:
        return 'Time for a water change in $aquarium.';
      case ReminderType.filterCleaning:
        return 'Time to clean the filter in $aquarium.';
      case ReminderType.tankCleaning:
        return 'Time to clean $aquarium.';
      case ReminderType.medication:
        return 'Time to add medication to $aquarium.';
      case ReminderType.maintenance:
        return 'Maintenance due for $aquarium.';
      case ReminderType.custom:
        return r.title;
    }
  }

  void _showSnack(String msg, {bool isSuccess = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: isSuccess ? accentGreen.withValues(alpha: 0.9) : cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
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
                  height: 180,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [topColor, Color(0xFF174A6A), backgroundColor],
                      stops: [0.0, 0.7, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),

              // Main content
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  SliverToBoxAdapter(child: _buildAppBar()),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildFormCard(),
                    ),
                  ),
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 40),
                      child: _buildActionButtons(),
                    ),
                  ),
                ],
              ),
            ],
          ),
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
          const SizedBox(width: 14),
          Expanded(
            child: Text(
              _isEditMode ? 'Edit Reminder' : 'Schedule Maintenance',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.alarm_add_rounded, color: primaryBlue, size: 20),
          ),
        ],
      ),
    );
  }

  // ─── Form Card ───────────────────────────────────────────

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1), width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Title field
          _buildLabel('Reminder Title'),
          const SizedBox(height: 10),
          _buildTextField(_titleController, 'e.g., Feed the clownfish'),

          const SizedBox(height: 20),

          // Description field
          _buildLabel('Description (optional)'),
          const SizedBox(height: 10),
          _buildTextField(_descriptionController, 'Additional notes...', maxLines: 2),

          const SizedBox(height: 20),

          // Aquarium selector
          _buildLabel('Aquarium'),
          const SizedBox(height: 10),
          _buildAquariumSelector(),

          const SizedBox(height: 20),

          // Task type
          _buildLabel('Task Type'),
          const SizedBox(height: 12),
          _buildTypeChips(),

          const SizedBox(height: 20),

          // Date & time
          _buildLabel('Schedule Date & Time'),
          const SizedBox(height: 12),
          _buildDateRow(),
          const SizedBox(height: 12),
          _buildTimeRow(),
        ],
      ),
    );
  }

  Widget _buildLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: textBlue.withValues(alpha: 0.9),
        fontSize: 14,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.2,
      ),
    );
  }

  Widget _buildTextField(
    TextEditingController controller,
    String hint, {
    int maxLines = 1,
  }) {
    return TextField(
      controller: controller,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: TextStyle(color: textBlue.withValues(alpha: 0.45), fontSize: 13),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      ),
    );
  }

  Widget _buildAquariumSelector() {
    if (_isLoadingAquariums) {
      return Container(
        height: 52,
        decoration: BoxDecoration(
          color: inputColor,
          borderRadius: BorderRadius.circular(14),
        ),
        child: const Center(
          child: SizedBox(
            width: 20,
            height: 20,
            child: CircularProgressIndicator(strokeWidth: 2, color: primaryBlue),
          ),
        ),
      );
    }

    if (_aquariums.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
        ),
        child: Text(
          'No aquariums found. Add one first.',
          style: TextStyle(color: textBlue.withValues(alpha: 0.6), fontSize: 13),
        ),
      );
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1)),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<AquariumModel>(
          value: _selectedAquarium,
          isExpanded: true,
          dropdownColor: cardColor,
          icon: Icon(Icons.keyboard_arrow_down, color: textBlue.withValues(alpha: 0.6)),
          items: _aquariums.map((a) {
            return DropdownMenuItem<AquariumModel>(
              value: a,
              child: Text(
                a.name,
                style: const TextStyle(color: Colors.white, fontSize: 14),
              ),
            );
          }).toList(),
          onChanged: (val) => setState(() => _selectedAquarium = val),
        ),
      ),
    );
  }

  Widget _buildTypeChips() {
    final types = [
      (ReminderType.feeding, Icons.restaurant, const Color(0xFFFF9800)),
      (ReminderType.waterChange, Icons.water_drop, const Color(0xFF42A5F5)),
      (ReminderType.filterCleaning, Icons.settings, const Color(0xFFAB47BC)),
      (ReminderType.tankCleaning, Icons.cleaning_services, const Color(0xFF66BB6A)),
      (ReminderType.medication, Icons.medication, const Color(0xFFEF5350)),
      (ReminderType.maintenance, Icons.build, const Color(0xFF26C6DA)),
      (ReminderType.custom, Icons.edit_note, const Color(0xFFBDBDBD)),
    ];

    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: types.map((t) {
        final type = t.$1;
        final icon = t.$2;
        final color = t.$3;
        final isSelected = _selectedType == type;

        return GestureDetector(
          onTap: () => setState(() => _selectedType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? color.withValues(alpha: 0.18) : inputColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? color.withValues(alpha: 0.55)
                    : primaryBlue.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: color.withValues(alpha: 0.15),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ]
                  : [],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(
                  icon,
                  color: isSelected ? color : textBlue.withValues(alpha: 0.6),
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  type.label,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textBlue,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDateRow() {
    return GestureDetector(
      onTap: _pickDate,
      child: _buildPickerRow(
        icon: Icons.calendar_today_rounded,
        label: 'Date: ${DateFormat('MMM dd, yyyy').format(_selectedDate)}',
      ),
    );
  }

  Widget _buildTimeRow() {
    final hour = _selectedTime.hour.toString().padLeft(2, '0');
    final minute = _selectedTime.minute.toString().padLeft(2, '0');
    return GestureDetector(
      onTap: _pickTime,
      child: _buildPickerRow(
        icon: Icons.access_time_rounded,
        label: 'Time: $hour:$minute',
      ),
    );
  }

  Widget _buildPickerRow({required IconData icon, required String label}) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: inputColor,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryBlue.withValues(alpha: 0.1), width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: primaryBlue.withValues(alpha: 0.8), size: 17),
          ),
          const SizedBox(width: 14),
          Text(
            label,
            style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w500),
          ),
          const Spacer(),
          Icon(Icons.chevron_right, color: textBlue.withValues(alpha: 0.5), size: 20),
        ],
      ),
    );
  }

  // ─── Action Buttons ──────────────────────────────────────

  Widget _buildActionButtons() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: _isLoading ? null : () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(color: primaryBlue.withValues(alpha: 0.35), width: 1.5),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(color: primaryBlue, fontSize: 15, fontWeight: FontWeight.w600),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _submitReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 22,
                      height: 22,
                      child: CircularProgressIndicator(
                        strokeWidth: 2.5,
                        color: Colors.white,
                      ),
                    )
                  : Text(
                      _isEditMode ? 'Update Reminder' : 'Set Reminder',
                      style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                    ),
            ),
          ),
        ),
      ],
    );
  }
}
