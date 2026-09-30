import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import '../routes/app_routes.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  // ─── AquaIntel Color Palette ───
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);
  static const Color surfaceDark = Color(0xFF142F45);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ─── Toggle states ───
  bool _notificationsEnabled = true;
  bool _feedingAlerts = true;
  bool _waterChangeAlerts = true;
  bool _darkMode = true;
  bool _soundEnabled = false;
  bool _hapticFeedback = true;
  bool _autoBackup = false;

  // ─── Expandable section states ───
  bool _notificationsExpanded = true;
  bool _appearanceExpanded = false;
  bool _dataExpanded = false;

  // ─── Selected temperature unit ───
  int _selectedTempUnit = 0; // 0 = °C, 1 = °F

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
                  height: 260,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        topColor,
                        Color(0xFF174A6A),
                        backgroundColor,
                      ],
                      stops: [0.0, 0.65, 1.0],
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
                  // ─── TOP BAR ───
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

                  // ─── SETTINGS TITLE ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Settings',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Customize your AquaIntel experience.',
                            style: TextStyle(
                              color: textBlue.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── PROFILE HERO CARD ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildProfileHeroCard(),
                    ),
                  ),

                  // ─── QUICK STATS ROW ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildQuickStatsRow(),
                    ),
                  ),

                  // ─── NOTIFICATIONS SECTION (Expandable) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildExpandableSection(
                        icon: Icons.notifications_active_outlined,
                        title: 'Notifications',
                        subtitle: _notificationsEnabled ? 'Enabled' : 'Disabled',
                        accentColor: const Color(0xFFFF9800),
                        isExpanded: _notificationsExpanded,
                        onToggleExpand: () {
                          setState(() {
                            _notificationsExpanded = !_notificationsExpanded;
                          });
                        },
                        children: [
                          _buildToggleTile(
                            icon: Icons.notifications_outlined,
                            title: 'Push Notifications',
                            subtitle: 'Receive alerts on your device',
                            value: _notificationsEnabled,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _notificationsEnabled = val);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.restaurant_outlined,
                            title: 'Feeding Reminders',
                            subtitle: 'Alerts for scheduled feedings',
                            value: _feedingAlerts,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _feedingAlerts = val);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.water_drop_outlined,
                            title: 'Water Change Alerts',
                            subtitle: 'Reminders for water changes',
                            value: _waterChangeAlerts,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _waterChangeAlerts = val);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.volume_up_outlined,
                            title: 'Sound Effects',
                            subtitle: 'Play sounds for alerts',
                            value: _soundEnabled,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _soundEnabled = val);
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── APPEARANCE SECTION (Expandable) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _buildExpandableSection(
                        icon: Icons.palette_outlined,
                        title: 'Appearance',
                        subtitle: _darkMode ? 'Dark Mode' : 'Light Mode',
                        accentColor: const Color(0xFF7C4DFF),
                        isExpanded: _appearanceExpanded,
                        onToggleExpand: () {
                          setState(() {
                            _appearanceExpanded = !_appearanceExpanded;
                          });
                        },
                        children: [
                          _buildToggleTile(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'Use dark theme throughout',
                            value: _darkMode,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _darkMode = val);
                            },
                          ),
                          _buildToggleTile(
                            icon: Icons.vibration,
                            title: 'Haptic Feedback',
                            subtitle: 'Vibrate on interactions',
                            value: _hapticFeedback,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _hapticFeedback = val);
                            },
                          ),
                          _buildTemperatureUnitSelector(),
                        ],
                      ),
                    ),
                  ),

                  // ─── DATA & STORAGE SECTION (Expandable) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 0),
                      child: _buildExpandableSection(
                        icon: Icons.cloud_outlined,
                        title: 'Data & Storage',
                        subtitle: _autoBackup ? 'Auto-backup on' : 'Manual backup',
                        accentColor: const Color(0xFF00BFA5),
                        isExpanded: _dataExpanded,
                        onToggleExpand: () {
                          setState(() {
                            _dataExpanded = !_dataExpanded;
                          });
                        },
                        children: [
                          _buildToggleTile(
                            icon: Icons.backup_outlined,
                            title: 'Auto Backup',
                            subtitle: 'Sync data to cloud automatically',
                            value: _autoBackup,
                            onChanged: (val) {
                              HapticFeedback.lightImpact();
                              setState(() => _autoBackup = val);
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.download_outlined,
                            title: 'Export Data',
                            subtitle: 'Download your aquarium data',
                            onTap: () {
                              _showSnackBar('Exporting data...');
                            },
                          ),
                          _buildActionTile(
                            icon: Icons.delete_sweep_outlined,
                            title: 'Clear Cache',
                            subtitle: 'Free up storage space',
                            onTap: () {
                              _showClearCacheDialog();
                            },
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── GENERAL ACTIONS (Non-expandable cards) ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                      child: _buildSectionLabel('General'),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _buildActionCard(
                        icon: Icons.info_outline,
                        title: 'About AquaIntel',
                        subtitle: 'Version, licenses & info',
                        onTap: () {
                          _showAboutSheet();
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _buildActionCard(
                        icon: Icons.help_outline,
                        title: 'Help & Support',
                        subtitle: 'FAQs, contact us, report a bug',
                        onTap: () {
                          _showSnackBar('Opening Help Center...');
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _buildActionCard(
                        icon: Icons.star_outline,
                        title: 'Rate AquaIntel',
                        subtitle: 'Love it? Let us know!',
                        onTap: () {
                          _showSnackBar('Opening store...');
                        },
                      ),
                    ),
                  ),

                  // ─── DANGER ZONE ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: _buildSectionLabel('Danger Zone'),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
                      child: _buildDangerCard(
                        icon: Icons.logout_outlined,
                        title: 'Log Out',
                        subtitle: 'Sign out of your account',
                        onTap: () {
                          _showLogoutDialog();
                        },
                      ),
                    ),
                  ),

                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
                      child: _buildDangerCard(
                        icon: Icons.delete_forever_outlined,
                        title: 'Delete Account',
                        subtitle: 'Permanently remove all data',
                        onTap: () {
                          _showDeleteAccountDialog();
                        },
                        isDestructive: true,
                      ),
                    ),
                  ),

                  // ─── FOOTER ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.water_drop,
                              color: primaryBlue.withValues(alpha: 0.4),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'AquaIntel v1.0.0',
                            style: TextStyle(
                              color: textBlue.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Made with 💙 for aquarists',
                            style: TextStyle(
                              color: textBlue.withValues(alpha: 0.3),
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
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

  // ══════════════════════════════════════════════
  // HEADER ICON
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
  // PROFILE HERO CARD
  // ══════════════════════════════════════════════
  Widget _buildProfileHeroCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF1E6B9A),
            Color(0xFF29A8DF),
            Color(0xFF1B8FC4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.25),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          // Avatar
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.4),
                width: 2,
              ),
            ),
            child: const Icon(
              Icons.person,
              color: Colors.white,
              size: 30,
            ),
          ),
          const SizedBox(width: 16),
          // User info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Aquarist',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: -0.3,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'aquarist@aquaintel.app',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.8),
                    fontSize: 13,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 8),
                // Edit Profile button
                GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const EditProfileScreen(),
                      ),
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 6,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.white.withValues(alpha: 0.2),
                      borderRadius: BorderRadius.circular(20),
                      border: Border.all(
                        color: Colors.white.withValues(alpha: 0.3),
                        width: 1,
                      ),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.edit_outlined,
                          color: Colors.white,
                          size: 14,
                        ),
                        SizedBox(width: 6),
                        Text(
                          'Edit Profile',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          // Arrow
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.5),
            size: 16,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // QUICK STATS ROW
  // ══════════════════════════════════════════════
  Widget _buildQuickStatsRow() {
    return Row(
      children: [
        Expanded(
          child: _buildStatChip(
            icon: Icons.water,
            label: 'Tanks',
            value: '1',
            color: primaryBlue,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatChip(
            icon: Icons.alarm,
            label: 'Reminders',
            value: '5',
            color: const Color(0xFFFF9800),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildStatChip(
            icon: Icons.calendar_today,
            label: 'Days Active',
            value: '42',
            color: const Color(0xFF66BB6A),
          ),
        ),
      ],
    );
  }

  Widget _buildStatChip({
    required IconData icon,
    required String label,
    required String value,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: color.withValues(alpha: 0.15),
          width: 1,
        ),
      ),
      child: Column(
        children: [
          Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color.withValues(alpha: 0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: color, size: 18),
          ),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: textBlue.withValues(alpha: 0.6),
              fontSize: 11,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // SECTION LABEL
  // ══════════════════════════════════════════════
  Widget _buildSectionLabel(String title) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 18,
          decoration: BoxDecoration(
            color: title == 'Danger Zone'
                ? const Color(0xFFEF5350)
                : primaryBlue,
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Text(
          title,
          style: TextStyle(
            color: title == 'Danger Zone'
                ? const Color(0xFFEF5350)
                : Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // EXPANDABLE SECTION
  // ══════════════════════════════════════════════
  Widget _buildExpandableSection({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color accentColor,
    required bool isExpanded,
    required VoidCallback onToggleExpand,
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: isExpanded
              ? accentColor.withValues(alpha: 0.25)
              : primaryBlue.withValues(alpha: 0.08),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.12),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          GestureDetector(
            onTap: onToggleExpand,
            behavior: HitTestBehavior.opaque,
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: accentColor.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(icon, color: accentColor, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: textBlue.withValues(alpha: 0.6),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                  AnimatedRotation(
                    turns: isExpanded ? 0.5 : 0,
                    duration: const Duration(milliseconds: 300),
                    curve: Curves.easeInOut,
                    child: Icon(
                      Icons.keyboard_arrow_down,
                      color: textBlue.withValues(alpha: 0.5),
                      size: 24,
                    ),
                  ),
                ],
              ),
            ),
          ),
          // Expandable content
          AnimatedCrossFade(
            firstChild: const SizedBox.shrink(),
            secondChild: Column(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: Container(
                    height: 1,
                    color: primaryBlue.withValues(alpha: 0.08),
                  ),
                ),
                ...children,
                const SizedBox(height: 8),
              ],
            ),
            crossFadeState: isExpanded
                ? CrossFadeState.showSecond
                : CrossFadeState.showFirst,
            duration: const Duration(milliseconds: 300),
            sizeCurve: Curves.easeInOut,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // TOGGLE TILE (inside expandable)
  // ══════════════════════════════════════════════
  Widget _buildToggleTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    required ValueChanged<bool> onChanged,
  }) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Row(
        children: [
          Icon(
            icon,
            color: textBlue.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: textBlue.withValues(alpha: 0.45),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: onChanged,
            activeThumbColor: primaryBlue,
            activeTrackColor: primaryBlue.withValues(alpha: 0.3),
            inactiveThumbColor: textBlue.withValues(alpha: 0.4),
            inactiveTrackColor: surfaceDark.withValues(alpha: 0.6),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ACTION TILE (inside expandable, tappable)
  // ══════════════════════════════════════════════
  Widget _buildActionTile({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
        child: Row(
          children: [
            Icon(
              icon,
              color: textBlue.withValues(alpha: 0.6),
              size: 20,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textBlue.withValues(alpha: 0.45),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textBlue.withValues(alpha: 0.3),
              size: 20,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // TEMPERATURE UNIT SELECTOR
  // ══════════════════════════════════════════════
  Widget _buildTemperatureUnitSelector() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      child: Row(
        children: [
          Icon(
            Icons.thermostat_outlined,
            color: textBlue.withValues(alpha: 0.6),
            size: 20,
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Temperature Unit',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                Text(
                  'Display temperature format',
                  style: TextStyle(
                    color: Color(0xFF70A9CC),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          // Segmented toggle
          Container(
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(10),
            ),
            padding: const EdgeInsets.all(3),
            child: Row(
              children: [
                _buildUnitChip('°C', 0),
                const SizedBox(width: 4),
                _buildUnitChip('°F', 1),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUnitChip(String label, int index) {
    final isSelected = _selectedTempUnit == index;
    return GestureDetector(
      onTap: () {
        HapticFeedback.lightImpact();
        setState(() => _selectedTempUnit = index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
        decoration: BoxDecoration(
          color: isSelected
              ? primaryBlue.withValues(alpha: 0.3)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
          border: isSelected
              ? Border.all(
                  color: primaryBlue.withValues(alpha: 0.5),
                  width: 1,
                )
              : null,
        ),
        child: Text(
          label,
          style: TextStyle(
            color: isSelected ? Colors.white : textBlue.withValues(alpha: 0.5),
            fontSize: 13,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ACTION CARD (standalone, non-expandable)
  // ══════════════════════════════════════════════
  Widget _buildActionCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: primaryBlue.withValues(alpha: 0.08),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: primaryBlue.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: primaryBlue, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textBlue.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: textBlue.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // DANGER CARD
  // ══════════════════════════════════════════════
  Widget _buildDangerCard({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isDestructive = false,
  }) {
    final dangerColor =
        isDestructive ? const Color(0xFFEF5350) : const Color(0xFFFF9800);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: dangerColor.withValues(alpha: 0.2),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: dangerColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: dangerColor, size: 22),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      color: dangerColor,
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textBlue.withValues(alpha: 0.5),
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: dangerColor.withValues(alpha: 0.4),
              size: 22,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // DIALOGS & SHEETS
  // ══════════════════════════════════════════════
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of AquaIntel?',
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.8),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.signIn,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF9800),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.warning_amber, color: Color(0xFFEF5350), size: 24),
            SizedBox(width: 10),
            Text(
              'Delete Account',
              style: TextStyle(
                color: Color(0xFFEF5350),
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your aquarium data, reminders, and settings will be deleted forever.',
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Account deletion requested');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Delete Forever'),
          ),
        ],
      ),
    );
  }

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text(
          'Clear Cache',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Text(
          'This will remove temporary files and cached data. Your aquarium data will not be affected.',
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              _showSnackBar('Cache cleared successfully');
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Clear'),
          ),
        ],
      ),
    );
  }

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.all(24),
        decoration: const BoxDecoration(
          color: Color(0xFF1C4667),
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(24),
            topRight: Radius.circular(24),
          ),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Drag handle
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: textBlue.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 24),
            // Logo
            Container(
              width: 64,
              height: 64,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF29A8DF), Color(0xFF1B8FC4)],
                ),
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.3),
                    blurRadius: 16,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: const Icon(
                Icons.water_drop,
                color: Colors.white,
                size: 32,
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'AquaIntel',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              'Version 1.0.0',
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.6),
                fontSize: 13,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Your intelligent companion for aquarium management. Monitor, maintain, and master your aquatic ecosystem.',
              textAlign: TextAlign.center,
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.7),
                fontSize: 13,
                height: 1.5,
              ),
            ),
            const SizedBox(height: 24),
            // Info rows
            _buildAboutRow(Icons.code, 'Developer', 'AquaIntel Team'),
            const SizedBox(height: 10),
            _buildAboutRow(Icons.mail_outline, 'Contact', 'hello@aquaintel.app'),
            const SizedBox(height: 10),
            _buildAboutRow(Icons.gavel, 'License', 'MIT License'),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }

  Widget _buildAboutRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, color: primaryBlue, size: 18),
        const SizedBox(width: 12),
        Text(
          label,
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.6),
            fontSize: 13,
          ),
        ),
        const Spacer(),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}
