import 'package:flutter/material.dart';

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

  // ─── Sample reminder data ───
  final List<Map<String, dynamic>> _urgentTasks = [
    {
      'title': 'Fish Feed - Aqua Aura',
      'dateTime': '12 Dec, 01:43 AM',
      'icon': Icons.restaurant,
      'iconBg': const Color(0xFFFF9800),
      'completed': true,
    },
    {
      'title': 'Water Change - 25%',
      'dateTime': '12 Dec, 08:00 AM',
      'icon': Icons.water_drop,
      'iconBg': const Color(0xFF42A5F5),
      'completed': false,
    },
  ];

  final List<Map<String, dynamic>> _upcomingTasks = [
    {
      'title': 'Tank Cleaning - Aqua Aura',
      'dateTime': '13 Dec, 01:42 AM',
      'icon': Icons.cleaning_services,
      'iconBg': const Color(0xFF66BB6A),
      'completed': false,
    },
    {
      'title': 'Filter Maintenance',
      'dateTime': '14 Dec, 10:00 AM',
      'icon': Icons.settings,
      'iconBg': const Color(0xFFAB47BC),
      'completed': false,
    },
    {
      'title': 'Water Test - pH & Ammonia',
      'dateTime': '15 Dec, 09:00 AM',
      'icon': Icons.science,
      'iconBg': const Color(0xFFEF5350),
      'completed': false,
    },
  ];

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
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              // ═══════════════════════════════════════
              // TOP GRADIENT BACKGROUND
              // ═══════════════════════════════════════
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

              // ═══════════════════════════════════════
              // MAIN SCROLLABLE CONTENT
              // ═══════════════════════════════════════
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── APP BAR ───
                  SliverToBoxAdapter(
                    child: Padding(
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
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: textBlue,
                                size: 16,
                              ),
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
                            child: const Icon(
                              Icons.water_drop,
                              color: primaryBlue,
                              size: 20,
                            ),
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
                          _buildHeaderIcon(Icons.notifications_outlined),
                        ],
                      ),
                    ),
                  ),

                  // ─── HEADER SECTION ───
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
                              fontWeight: FontWeight.w400,
                              height: 1.5,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── URGENT TASKS SECTION ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 30, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: const Color(0xFFFF9800),
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Urgent Tasks (${_urgentTasks.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── URGENT TASKS LIST ───
                  SliverPadding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTaskCard(
                              _urgentTasks[index],
                              isUrgent: true,
                              onToggle: () {
                                setState(() {
                                  _urgentTasks[index]['completed'] =
                                      !_urgentTasks[index]['completed'];
                                });
                              },
                            ),
                          );
                        },
                        childCount: _urgentTasks.length,
                      ),
                    ),
                  ),

                  // ─── UPCOMING TASKS SECTION ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                      child: Row(
                        children: [
                          Container(
                            width: 4,
                            height: 20,
                            decoration: BoxDecoration(
                              color: primaryBlue,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            'Upcoming Tasks (${_upcomingTasks.length})',
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── UPCOMING TASKS LIST ───
                  SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: _buildTaskCard(
                              _upcomingTasks[index],
                              isUrgent: false,
                              onToggle: () {
                                setState(() {
                                  _upcomingTasks[index]['completed'] =
                                      !_upcomingTasks[index]['completed'];
                                });
                              },
                            ),
                          );
                        },
                        childCount: _upcomingTasks.length,
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),

      // ═══════════════════════════════════════
      // FLOATING ACTION BUTTON
      // ═══════════════════════════════════════
      floatingActionButton: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF29A8DF),
              Color(0xFF1B8FC4),
            ],
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
          onPressed: () {
            _showAddReminderSheet(context);
          },
          backgroundColor: Colors.transparent,
          elevation: 0,
          highlightElevation: 0,
          child: const Icon(
            Icons.add,
            color: Colors.white,
            size: 28,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // HEADER ICON BUTTON
  // ══════════════════════════════════════════════
  Widget _buildHeaderIcon(IconData icon) {
    return Container(
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
      child: Icon(
        icon,
        color: textBlue,
        size: 20,
      ),
    );
  }

  // ══════════════════════════════════════════════
  // TASK CARD
  // ══════════════════════════════════════════════
  Widget _buildTaskCard(
    Map<String, dynamic> task, {
    required bool isUrgent,
    required VoidCallback onToggle,
  }) {
    final bool completed = task['completed'] as bool;
    final Color iconBg = task['iconBg'] as Color;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: completed
            ? cardColor.withValues(alpha: 0.5)
            : cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isUrgent && !completed
              ? const Color(0xFFFF9800).withValues(alpha: 0.2)
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
          // ─── Task Icon ───
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: completed
                  ? iconBg.withValues(alpha: 0.1)
                  : iconBg.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              task['icon'] as IconData,
              color: completed
                  ? iconBg.withValues(alpha: 0.5)
                  : iconBg,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),

          // ─── Task Details ───
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  task['title'] as String,
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
                const SizedBox(height: 4),
                Row(
                  children: [
                    Icon(
                      Icons.access_time,
                      color: textBlue.withValues(alpha: 0.6),
                      size: 13,
                    ),
                    const SizedBox(width: 4),
                    Text(
                      task['dateTime'] as String,
                      style: TextStyle(
                        color: textBlue.withValues(alpha: 0.7),
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ─── Completion Toggle ───
          GestureDetector(
            onTap: onToggle,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              width: 30,
              height: 30,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: completed
                    ? primaryBlue
                    : Colors.transparent,
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
                  ? const Icon(
                      Icons.check,
                      color: Colors.white,
                      size: 18,
                    )
                  : null,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ADD REMINDER BOTTOM SHEET
  // ══════════════════════════════════════════════
  void _showAddReminderSheet(BuildContext context) {
    final titleController = TextEditingController();
    String selectedCategory = 'Feeding';

    final categories = [
      {'label': 'Feeding', 'icon': Icons.restaurant, 'color': const Color(0xFFFF9800)},
      {'label': 'Cleaning', 'icon': Icons.cleaning_services, 'color': const Color(0xFF66BB6A)},
      {'label': 'Water Change', 'icon': Icons.water_drop, 'color': const Color(0xFF42A5F5)},
      {'label': 'Filter', 'icon': Icons.settings, 'color': const Color(0xFFAB47BC)},
      {'label': 'Testing', 'icon': Icons.science, 'color': const Color(0xFFEF5350)},
    ];

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setSheetState) {
            return Container(
              padding: EdgeInsets.only(
                bottom: MediaQuery.of(context).viewInsets.bottom,
              ),
              decoration: const BoxDecoration(
                color: Color(0xFF142F45),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(24),
                  topRight: Radius.circular(24),
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // ─── Handle ───
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: textBlue.withValues(alpha: 0.3),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Title ───
                    const Text(
                      'New Reminder',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 20),

                    // ─── Task Name Field ───
                    TextField(
                      controller: titleController,
                      style: const TextStyle(color: Colors.white),
                      decoration: InputDecoration(
                        hintText: 'Task name...',
                        hintStyle: TextStyle(
                          color: textBlue.withValues(alpha: 0.5),
                        ),
                        filled: true,
                        fillColor: cardColor,
                        prefixIcon: Icon(
                          Icons.edit_outlined,
                          color: primaryBlue.withValues(alpha: 0.7),
                          size: 20,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: BorderSide.none,
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(14),
                          borderSide: const BorderSide(
                            color: primaryBlue,
                            width: 1.5,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 18),

                    // ─── Category Selection ───
                    Text(
                      'Category',
                      style: TextStyle(
                        color: textBlue.withValues(alpha: 0.8),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 8,
                      runSpacing: 8,
                      children: categories.map((cat) {
                        final isSelected =
                            selectedCategory == cat['label'];
                        return GestureDetector(
                          onTap: () {
                            setSheetState(() {
                              selectedCategory =
                                  cat['label'] as String;
                            });
                          },
                          child: AnimatedContainer(
                            duration:
                                const Duration(milliseconds: 200),
                            padding: const EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? (cat['color'] as Color)
                                      .withValues(alpha: 0.2)
                                  : cardColor,
                              borderRadius:
                                  BorderRadius.circular(10),
                              border: Border.all(
                                color: isSelected
                                    ? (cat['color'] as Color)
                                        .withValues(alpha: 0.5)
                                    : primaryBlue
                                        .withValues(alpha: 0.1),
                                width: 1.5,
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  cat['icon'] as IconData,
                                  color: cat['color'] as Color,
                                  size: 16,
                                ),
                                const SizedBox(width: 6),
                                Text(
                                  cat['label'] as String,
                                  style: TextStyle(
                                    color: isSelected
                                        ? Colors.white
                                        : textBlue,
                                    fontSize: 13,
                                    fontWeight: isSelected
                                        ? FontWeight.w600
                                        : FontWeight.w400,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 24),

                    // ─── Save Button ───
                    SizedBox(
                      width: double.infinity,
                      height: 50,
                      child: ElevatedButton(
                        onPressed: () {
                          if (titleController.text.isNotEmpty) {
                            Navigator.pop(context);
                            // TODO: Save reminder
                          }
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryBlue,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(14),
                          ),
                          elevation: 0,
                        ),
                        child: const Text(
                          'Save Reminder',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }
}
