import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/reminder_model.dart';

/// "Schedule Maintenance" form screen.
///
/// Matches the AquaIntel dark‑oceanic design language used across
/// [HomeScreen], [ReminderScreen], and [SignInScreen].
class ReminderFormScreen extends StatefulWidget {
  const ReminderFormScreen({super.key});

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

  // ─── Form state ───
  final TextEditingController _tankNameController = TextEditingController();
  String _selectedTaskType = '';
  DateTime _selectedDate = DateTime.now();
  TimeOfDay _selectedTime = TimeOfDay.now();

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Task types shown as chips (matches the screenshot)
  static const List<String> _taskTypes = [
    'Fish Feed',
    'Water Change',
    'Tank Cleaning',
    'Filter Wash',
  ];

  // Icon + colour mapping per task type
  static final Map<String, _TaskMeta> _taskMeta = {
    'Fish Feed': _TaskMeta(Icons.restaurant, const Color(0xFFFF9800)),
    'Water Change': _TaskMeta(Icons.water_drop, const Color(0xFF42A5F5)),
    'Tank Cleaning': _TaskMeta(Icons.cleaning_services, const Color(0xFF66BB6A)),
    'Filter Wash': _TaskMeta(Icons.settings, const Color(0xFFAB47BC)),
  };

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    _tankNameController.dispose();
    super.dispose();
  }

  // ─── Date / Time pickers ───

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _selectedDate = picked);
    }
  }

  Future<void> _pickTime() async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime,
      builder: (context, child) => _datePickerTheme(child),
    );
    if (picked != null) {
      setState(() => _selectedTime = picked);
    }
  }

  Widget _datePickerTheme(Widget? child) {
    return Theme(
      data: Theme.of(context).copyWith(
        colorScheme: const ColorScheme.dark(
          primary: primaryBlue,
          onPrimary: Colors.white,
          surface: cardColor,
          onSurface: Colors.white,
        ),
        dialogTheme: const DialogThemeData(
          backgroundColor: backgroundColor,
        ),
      ),
      child: child!,
    );
  }

  // ─── Validation & submission ───

  void _submitReminder() {
    if (_tankNameController.text.trim().isEmpty) {
      _showSnack('Please enter a tank name');
      return;
    }
    if (_selectedTaskType.isEmpty) {
      _showSnack('Please select a task type');
      return;
    }

    final reminder = Reminder(
      tankName: _tankNameController.text.trim(),
      taskType: _selectedTaskType,
      scheduledDate: _selectedDate,
      scheduledTime: DateTime(
        _selectedDate.year,
        _selectedDate.month,
        _selectedDate.day,
        _selectedTime.hour,
        _selectedTime.minute,
      ),
      createdAt: DateTime.now(),
    );

    // TODO: Persist reminder via provider / API
    debugPrint('Reminder created: $reminder');

    Navigator.pop(context, reminder);
  }

  void _showSnack(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(msg),
        backgroundColor: cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // BUILD
  // ══════════════════════════════════════════════════

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              // ── Top gradient ──
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

              // ── Main content ──
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── App bar ───
                  SliverToBoxAdapter(child: _buildAppBar()),

                  // ─── Form body ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildFormCard(),
                    ),
                  ),

                  // ─── Action buttons ───
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

  // ══════════════════════════════════════════════════
  // APP BAR
  // ══════════════════════════════════════════════════

  Widget _buildAppBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
      child: Row(
        children: [
          // Back button
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
              child: const Icon(
                Icons.arrow_back_ios_new,
                color: textBlue,
                size: 16,
              ),
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Text(
              'Schedule Maintenance',
              style: TextStyle(
                color: Colors.white,
                fontSize: 20,
                fontWeight: FontWeight.bold,
                letterSpacing: -0.3,
              ),
            ),
          ),
          // Decorative water‑drop icon
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.alarm_add_rounded,
              color: primaryBlue,
              size: 20,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // FORM CARD
  // ══════════════════════════════════════════════════

  Widget _buildFormCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 24),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
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
          // ─── Tank Name ───
          _buildSectionLabel('Tank Name'),
          const SizedBox(height: 10),
          _buildTankNameField(),

          const SizedBox(height: 24),

          // ─── Task Type ───
          _buildSectionLabel('Select Task Type'),
          const SizedBox(height: 12),
          _buildTaskTypeChips(),

          const SizedBox(height: 24),

          // ─── Date & Time ───
          _buildSectionLabel('Schedule Date & Time'),
          const SizedBox(height: 12),
          _buildDateSelector(),
          const SizedBox(height: 12),
          _buildTimeSelector(),
        ],
      ),
    );
  }

  // ── Section label ──
  Widget _buildSectionLabel(String text) {
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

  // ── Tank name input ──
  Widget _buildTankNameField() {
    return TextField(
      controller: _tankNameController,
      style: const TextStyle(color: Colors.white, fontSize: 14),
      decoration: InputDecoration(
        hintText: 'e.g., Main 55 Gallon Reef',
        hintStyle: TextStyle(
          color: textBlue.withValues(alpha: 0.45),
          fontSize: 13,
        ),
        filled: true,
        fillColor: inputColor,
        prefixIcon: Icon(
          Icons.water,
          color: primaryBlue.withValues(alpha: 0.6),
          size: 20,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryBlue, width: 1.5),
        ),
        contentPadding: const EdgeInsets.symmetric(vertical: 15),
      ),
    );
  }

  // ── Task‑type chips ──
  Widget _buildTaskTypeChips() {
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      children: _taskTypes.map((type) {
        final isSelected = _selectedTaskType == type;
        final meta = _taskMeta[type]!;

        return GestureDetector(
          onTap: () => setState(() => _selectedTaskType = type),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 220),
            curve: Curves.easeInOut,
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              color: isSelected
                  ? meta.color.withValues(alpha: 0.18)
                  : inputColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? meta.color.withValues(alpha: 0.55)
                    : primaryBlue.withValues(alpha: 0.1),
                width: 1.5,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: meta.color.withValues(alpha: 0.15),
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
                  meta.icon,
                  color: isSelected
                      ? meta.color
                      : textBlue.withValues(alpha: 0.6),
                  size: 16,
                ),
                const SizedBox(width: 7),
                Text(
                  type,
                  style: TextStyle(
                    color: isSelected ? Colors.white : textBlue,
                    fontSize: 13,
                    fontWeight:
                        isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ── Date selector row ──
  Widget _buildDateSelector() {
    return GestureDetector(
      onTap: _pickDate,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primaryBlue.withValues(alpha: 0.1),
            width: 1,
          ),
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
              child: Icon(
                Icons.calendar_today_rounded,
                color: primaryBlue.withValues(alpha: 0.8),
                size: 17,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Date: ${DateFormat('MM/dd/yyyy').format(_selectedDate)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: textBlue.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ── Time selector row ──
  Widget _buildTimeSelector() {
    final now = DateTime.now();
    final timeAsDateTime = DateTime(
      now.year,
      now.month,
      now.day,
      _selectedTime.hour,
      _selectedTime.minute,
    );

    return GestureDetector(
      onTap: _pickTime,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        decoration: BoxDecoration(
          color: inputColor,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: primaryBlue.withValues(alpha: 0.1),
            width: 1,
          ),
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
              child: Icon(
                Icons.access_time_rounded,
                color: primaryBlue.withValues(alpha: 0.8),
                size: 17,
              ),
            ),
            const SizedBox(width: 14),
            Text(
              'Time: ${DateFormat('HH:mm').format(timeAsDateTime)}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 14,
                fontWeight: FontWeight.w500,
              ),
            ),
            const Spacer(),
            Icon(
              Icons.chevron_right,
              color: textBlue.withValues(alpha: 0.5),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════════
  // ACTION BUTTONS (Cancel / Set Reminder)
  // ══════════════════════════════════════════════════

  Widget _buildActionButtons() {
    return Row(
      children: [
        // Cancel
        Expanded(
          child: SizedBox(
            height: 50,
            child: OutlinedButton(
              onPressed: () => Navigator.pop(context),
              style: OutlinedButton.styleFrom(
                side: BorderSide(
                  color: primaryBlue.withValues(alpha: 0.35),
                  width: 1.5,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: const Text(
                'Cancel',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ),
        const SizedBox(width: 14),

        // Set Reminder
        Expanded(
          child: SizedBox(
            height: 50,
            child: ElevatedButton(
              onPressed: _submitReminder,
              style: ElevatedButton.styleFrom(
                backgroundColor: accentGreen,
                foregroundColor: Colors.white,
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
                shadowColor: accentGreen.withValues(alpha: 0.4),
              ),
              child: const Text(
                'Set Reminder',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 0.3,
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ─── Helper class for task‑type metadata ───
class _TaskMeta {
  final IconData icon;
  final Color color;

  const _TaskMeta(this.icon, this.color);
}
