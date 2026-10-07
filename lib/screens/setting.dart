import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_profile.dart';
import '../routes/app_routes.dart';
import '../services/settings_service.dart';
import '../services/notification_service.dart';

class SettingScreen extends StatefulWidget {
  const SettingScreen({super.key});

  @override
  State<SettingScreen> createState() => _SettingScreenState();
}

class _SettingScreenState extends State<SettingScreen>
    with SingleTickerProviderStateMixin {
  // ─────────────────────────────────────────────
  // AquaIntel colours
  // ─────────────────────────────────────────────

  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color surfaceColor = Color(0xFF163B5A);
  static const Color dividerColor = Color(0xFF28506B);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textSecondary = Color(0xFF8FB3C9);
  static const Color dangerColor = Color(0xFFEF5350);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // Firebase user
  User? _currentUser;

  // Settings
  bool _notificationsEnabled = true;
  bool _feedingAlerts = true;
  bool _waterChangeAlerts = true;
  bool _darkMode = true;
  bool _soundEnabled = false;
  bool _hapticFeedback = true;
  bool _autoBackup = false;

  // Temperature
  int _selectedTempUnit = 0; // 0 = Celsius, 1 = Fahrenheit

  final _settingsService = SettingsService();

  final _notificationService = NotificationService();

  @override
  void initState() {
    super.initState();

    _currentUser = FirebaseAuth.instance.currentUser;

    _animController = AnimationController(
      duration: const Duration(milliseconds: 350),
      vsync: this,
    );

    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );

    _animController.forward();

    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final notif = await _settingsService.getNotificationsEnabled();
    final feeding = await _settingsService.getFeedingAlerts();
    final water = await _settingsService.getWaterChangeAlerts();
    final sound = await _settingsService.getSoundEnabled();
    final haptic = await _settingsService.getHapticFeedback();
    final dark = await _settingsService.getDarkMode();
    final backup = await _settingsService.getAutoBackup();
    final tempUnit = await _settingsService.getTemperatureUnit();

    if (!mounted) return;

    setState(() {
      _notificationsEnabled = notif;
      _feedingAlerts = feeding;
      _waterChangeAlerts = water;
      _soundEnabled = sound;
      _hapticFeedback = haptic;
      _darkMode = dark;
      _autoBackup = backup;
      _selectedTempUnit = tempUnit;
    });
  }

  // Calls HapticFeedback only when the setting is ON.
  Future<void> _haptic() async {
    if (_hapticFeedback) {
      HapticFeedback.lightImpact();
    }
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  // ─────────────────────────────────────────────
  // Firebase user information
  // ─────────────────────────────────────────────

  String get _displayName {
    final name = _currentUser?.displayName;

    if (name != null && name.trim().isNotEmpty) {
      return name.trim();
    }

    return 'Aquarist';
  }

  String get _displayEmail {
    final email = _currentUser?.email;

    if (email != null && email.trim().isNotEmpty) {
      return email.trim();
    }

    return 'No email available';
  }

  // ─────────────────────────────────────────────
  // Build
  // ─────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              // Header
              SliverToBoxAdapter(
                child: _buildHeader(),
              ),

              // Main content
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(20, 8, 20, 40),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      _buildSectionTitle('Account'),

                      const SizedBox(height: 10),

                      _buildProfileSection(),

                      const SizedBox(height: 28),

                      _buildSectionTitle('Notifications'),

                      const SizedBox(height: 10),

                      _buildSettingsGroup(
                        children: [
                          _buildSwitchRow(
                            icon: Icons.notifications_none_rounded,
                            title: 'Push Notifications',
                            subtitle: 'Receive alerts on your device',
                            value: _notificationsEnabled,
                            onChanged: (value) async {
                              await _haptic();

                              setState(() {
                                _notificationsEnabled = value;
                              });

                              await _settingsService.setNotificationsEnabled(value);

                              if (!mounted) return;

                              _showSnackBar(
                                value
                                    ? 'Notifications enabled'
                                    : 'Notifications disabled',
                              );
                            },
                          ),

                          _buildDivider(),

                          // Feeding Reminders – disabled visually when master is OFF.
                          _buildSwitchRow(
                            icon: Icons.restaurant_outlined,
                            title: 'Feeding Reminders',
                            subtitle: _notificationsEnabled
                                ? 'Alerts for scheduled feedings'
                                : 'Enable Push Notifications first',
                            value: _feedingAlerts && _notificationsEnabled,
                            enabled: _notificationsEnabled,
                            onChanged: _notificationsEnabled
                                ? (value) async {
                                    await _haptic();
                                    setState(() => _feedingAlerts = value);
                                    await _settingsService.setFeedingAlerts(value);
                                    // Cancel feeding notifications if turned off.
                                    if (!value) {
                                      await _notificationService.cancelAllNotifications();
                                    }
                                  }
                                : null,
                          ),

                          _buildDivider(),

                          // Water Change Alerts – disabled visually when master is OFF.
                          _buildSwitchRow(
                            icon: Icons.water_drop_outlined,
                            title: 'Water Change Alerts',
                            subtitle: _notificationsEnabled
                                ? 'Reminders for water changes'
                                : 'Enable Push Notifications first',
                            value: _waterChangeAlerts && _notificationsEnabled,
                            enabled: _notificationsEnabled,
                            onChanged: _notificationsEnabled
                                ? (value) async {
                                    await _haptic();
                                    setState(() => _waterChangeAlerts = value);
                                    await _settingsService.setWaterChangeAlerts(value);
                                    if (!value) {
                                      await _notificationService.cancelAllNotifications();
                                    }
                                  }
                                : null,
                          ),

                          _buildDivider(),

                          _buildSwitchRow(
                            icon: Icons.volume_up_outlined,
                            title: 'Sound Effects',
                            subtitle: 'Play sounds for alerts',
                            value: _soundEnabled,
                            onChanged: (value) async {
                              await _haptic();
                              setState(() => _soundEnabled = value);
                              await _settingsService.setSoundEnabled(value);
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildSectionTitle('Preferences'),

                      const SizedBox(height: 10),

                      _buildSettingsGroup(
                        children: [
                          _buildSwitchRow(
                            icon: Icons.dark_mode_outlined,
                            title: 'Dark Mode',
                            subtitle: 'Use the dark appearance',
                            value: _darkMode,
                            onChanged: (value) async {
                              await _haptic();
                              setState(() => _darkMode = value);
                              await _settingsService.setDarkMode(value);
                            },
                          ),

                          _buildDivider(),

                          _buildSwitchRow(
                            icon: Icons.vibration_outlined,
                            title: 'Haptic Feedback',
                            subtitle: 'Vibrate when interacting',
                            value: _hapticFeedback,
                            onChanged: (value) async {
                              // Give one last haptic before potentially disabling it.
                              HapticFeedback.lightImpact();
                              setState(() => _hapticFeedback = value);
                              await _settingsService.setHapticFeedback(value);
                            },
                          ),

                          _buildDivider(),

                          _buildTemperatureRow(),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildSectionTitle('Data & Storage'),

                      const SizedBox(height: 10),

                      _buildSettingsGroup(
                        children: [
                          _buildSwitchRow(
                            icon: Icons.cloud_outlined,
                            title: 'Auto Backup',
                            subtitle: 'Automatically sync your data',
                            value: _autoBackup,
                            onChanged: (value) async {
                              await _haptic();
                              setState(() => _autoBackup = value);
                              await _settingsService.setAutoBackup(value);
                            },
                          ),

                          _buildDivider(),

                          _buildNavigationRow(
                            icon: Icons.download_outlined,
                            title: 'Export Data',
                            subtitle: 'Download your aquarium data',
                            onTap: () {
                              _showSnackBar('Exporting data...');
                            },
                          ),

                          _buildDivider(),

                          _buildNavigationRow(
                            icon: Icons.delete_sweep_outlined,
                            title: 'Clear Cache',
                            subtitle: 'Remove temporary files',
                            onTap: _showClearCacheDialog,
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildSectionTitle('About'),

                      const SizedBox(height: 10),

                      _buildSettingsGroup(
                        children: [
                          _buildNavigationRow(
                            icon: Icons.info_outline_rounded,
                            title: 'About AquaIntel',
                            subtitle: 'Version, licenses and information',
                            onTap: _showAboutSheet,
                          ),

                          _buildDivider(),

                          _buildNavigationRow(
                            icon: Icons.help_outline_rounded,
                            title: 'Help & Support',
                            subtitle: 'FAQs, contact and bug reports',
                            onTap: () {
                              _showSnackBar('Opening Help Center...');
                            },
                          ),

                          _buildDivider(),

                          _buildNavigationRow(
                            icon: Icons.star_outline_rounded,
                            title: 'Rate AquaIntel',
                            subtitle: 'Leave a review',
                            onTap: () {
                              _showSnackBar('Opening store...');
                            },
                          ),
                        ],
                      ),

                      const SizedBox(height: 28),

                      _buildSectionTitle(
                        'Account Actions',
                        danger: true,
                      ),

                      const SizedBox(height: 10),

                      _buildSettingsGroup(
                        children: [
                          _buildDangerRow(
                            icon: Icons.logout_rounded,
                            title: 'Log Out',
                            subtitle: 'Sign out of your account',
                            color: const Color(0xFFFFA726),
                            onTap: _showLogoutDialog,
                          ),

                          _buildDivider(),

                          _buildDangerRow(
                            icon: Icons.delete_outline_rounded,
                            title: 'Delete Account',
                            subtitle: 'Permanently remove your account',
                            color: dangerColor,
                            onTap: _showDeleteAccountDialog,
                          ),
                        ],
                      ),

                      const SizedBox(height: 36),

                      Center(
                        child: Text(
                          'AquaIntel v1.0.0',
                          style: TextStyle(
                            color: textSecondary.withValues(alpha: 0.45),
                            fontSize: 12,
                          ),
                        ),
                      ),

                      const SizedBox(height: 6),

                      Center(
                        child: Text(
                          'Aquarium management, made simpler.',
                          style: TextStyle(
                            color: textSecondary.withValues(alpha: 0.35),
                            fontSize: 11,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Header
  // ─────────────────────────────────────────────

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 18),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(
              Icons.arrow_back_ios_new_rounded,
              size: 19,
            ),
            color: textSecondary,
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(
              minWidth: 40,
              minHeight: 40,
            ),
          ),

          const SizedBox(width: 4),

          const Text(
            'Settings',
            style: TextStyle(
              color: Colors.white,
              fontSize: 23,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Section title
  // ─────────────────────────────────────────────

  Widget _buildSectionTitle(
    String title, {
    bool danger = false,
  }) {
    return Text(
      title.toUpperCase(),
      style: TextStyle(
        color: danger
            ? dangerColor.withValues(alpha: 0.85)
            : textSecondary.withValues(alpha: 0.75),
        fontSize: 11,
        fontWeight: FontWeight.w600,
        letterSpacing: 1.1,
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Profile
  // ─────────────────────────────────────────────

  Widget _buildProfileSection() {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 16, 10, 16),
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dividerColor.withValues(alpha: 0.65),
        ),
      ),
      child: Row(
        children: [
          // Simple avatar
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: primaryBlue.withValues(alpha: 0.12),
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.person_outline_rounded,
              color: primaryBlue,
              size: 25,
            ),
          ),

          const SizedBox(width: 14),

          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _displayName,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 3),

                Text(
                  _displayEmail,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: textSecondary.withValues(alpha: 0.75),
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),

          TextButton(
            onPressed: () async {
              await Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const EditProfileScreen(),
                ),
              );

              final updatedUser =
                  FirebaseAuth.instance.currentUser;

              if (!mounted) return;

              setState(() {
                _currentUser = updatedUser;
              });
            },
            style: TextButton.styleFrom(
              foregroundColor: primaryBlue,
              padding: const EdgeInsets.symmetric(
                horizontal: 10,
                vertical: 8,
              ),
            ),
            child: const Text(
              'Edit',
              style: TextStyle(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Settings group
  // ─────────────────────────────────────────────

  Widget _buildSettingsGroup({
    required List<Widget> children,
  }) {
    return Container(
      decoration: BoxDecoration(
        color: surfaceColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: dividerColor.withValues(alpha: 0.65),
        ),
      ),
      clipBehavior: Clip.antiAlias,
      child: Column(
        children: children,
      ),
    );
  }

  Widget _buildDivider() {
    return Padding(
      padding: const EdgeInsets.only(left: 58),
      child: Divider(
        height: 1,
        thickness: 1,
        color: dividerColor.withValues(alpha: 0.5),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Switch row
  // ─────────────────────────────────────────────

  Widget _buildSwitchRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool value,
    // null = row is visually disabled (master switch is OFF)
    required ValueChanged<bool>? onChanged,
    bool enabled = true,
  }) {
    final rowOpacity = enabled ? 1.0 : 0.4;
    return Opacity(
      opacity: rowOpacity,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 12, 10, 12),
        child: Row(
          children: [
            SizedBox(
              width: 28,
              child: Icon(
                icon,
                color: textSecondary.withValues(alpha: 0.7),
                size: 20,
              ),
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

                  const SizedBox(height: 2),

                  Text(
                    subtitle,
                    style: TextStyle(
                      color: textSecondary.withValues(alpha: 0.6),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),

            Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: primaryBlue.withValues(alpha: 0.45),
              activeThumbColor: primaryBlue,
            ),
          ],
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Navigation row
  // ─────────────────────────────────────────────

  Widget _buildNavigationRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Icon(
                  icon,
                  color: textSecondary.withValues(alpha: 0.7),
                  size: 20,
                ),
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

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSecondary.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: textSecondary.withValues(alpha: 0.4),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Temperature
  // ─────────────────────────────────────────────

  Widget _buildTemperatureRow() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
      child: Row(
        children: [
          SizedBox(
            width: 28,
            child: Icon(
              Icons.thermostat_outlined,
              color: textSecondary.withValues(alpha: 0.7),
              size: 20,
            ),
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
                SizedBox(height: 2),
                Text(
                  'Choose how temperature is displayed',
                  style: TextStyle(
                    color: Color(0xFF70A9CC),
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),

          _buildTemperatureSelector(),
        ],
      ),
    );
  }

  Widget _buildTemperatureSelector() {
    return Container(
      padding: const EdgeInsets.all(2),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        children: [
          _buildTemperatureOption('°C', 0),
          _buildTemperatureOption('°F', 1),
        ],
      ),
    );
  }

  Widget _buildTemperatureOption(
    String label,
    int index,
  ) {
    final selected = _selectedTempUnit == index;

    return GestureDetector(
      onTap: () async {
        await _haptic();
        setState(() => _selectedTempUnit = index);
        await _settingsService.setTemperatureUnit(index);
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 150),
        padding: const EdgeInsets.symmetric(
          horizontal: 9,
          vertical: 6,
        ),
        decoration: BoxDecoration(
          color: selected
              ? primaryBlue.withValues(alpha: 0.18)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(6),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected
                ? Colors.white
                : textSecondary.withValues(alpha: 0.6),
            fontSize: 12,
            fontWeight: selected
                ? FontWeight.w600
                : FontWeight.w400,
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Danger row
  // ─────────────────────────────────────────────

  Widget _buildDangerRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: Row(
            children: [
              SizedBox(
                width: 28,
                child: Icon(
                  icon,
                  color: color.withValues(alpha: 0.85),
                  size: 20,
                ),
              ),

              const SizedBox(width: 14),

              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        color: color.withValues(alpha: 0.95),
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                      ),
                    ),

                    const SizedBox(height: 2),

                    Text(
                      subtitle,
                      style: TextStyle(
                        color: textSecondary.withValues(alpha: 0.6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),

              Icon(
                Icons.chevron_right_rounded,
                color: color.withValues(alpha: 0.4),
                size: 21,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Snackbar
  // ─────────────────────────────────────────────

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(
            color: Colors.white,
          ),
        ),
        backgroundColor: surfaceColor,
        behavior: SnackBarBehavior.floating,
        duration: const Duration(seconds: 2),
        margin: const EdgeInsets.all(16),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
        ),
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Logout
  // ─────────────────────────────────────────────

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Log Out',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to log out of AquaIntel?',
          style: TextStyle(
            color: textSecondary.withValues(alpha: 0.85),
            height: 1.4,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),

          TextButton(
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
            child: const Text(
              'Log Out',
              style: TextStyle(
                color: Color(0xFFFFA726),
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Delete account
  // ─────────────────────────────────────────────

  void _showDeleteAccountDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Delete Account',
          style: TextStyle(
            color: dangerColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This action is permanent and cannot be undone. All your aquarium data, reminders, and settings will be deleted forever.',
          style: TextStyle(
            color: textSecondary.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(ctx);

              _showSnackBar(
                'Account deletion requested',
              );
            },
            child: const Text(
              'Delete',
              style: TextStyle(
                color: dangerColor,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // Clear cache
  // ─────────────────────────────────────────────

  void _showClearCacheDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: surfaceColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(14),
        ),
        title: const Text(
          'Clear Cache',
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'This will remove temporary files and cached data. Your aquarium data will not be affected.',
          style: TextStyle(
            color: textSecondary.withValues(alpha: 0.85),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textSecondary.withValues(alpha: 0.8),
              ),
            ),
          ),

          TextButton(
            onPressed: () {
              Navigator.pop(ctx);

              _showSnackBar(
                'Cache cleared successfully',
              );
            },
            child: const Text(
              'Clear',
              style: TextStyle(
                color: primaryBlue,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ─────────────────────────────────────────────
  // About sheet
  // ─────────────────────────────────────────────

  void _showAboutSheet() {
    showModalBottomSheet(
      context: context,
      backgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      builder: (ctx) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              24,
              12,
              24,
              24,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Container(
                    width: 36,
                    height: 4,
                    decoration: BoxDecoration(
                      color: textSecondary.withValues(alpha: 0.3),
                      borderRadius: BorderRadius.circular(2),
                    ),
                  ),
                ),

                const SizedBox(height: 24),

                const Text(
                  'About AquaIntel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                Text(
                  'Version 1.0.0',
                  style: TextStyle(
                    color: textSecondary.withValues(alpha: 0.7),
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 20),

                Text(
                  'AquaIntel helps aquarium owners keep track of their tanks, maintenance, reminders and aquarium information in one place.',
                  style: TextStyle(
                    color: textSecondary.withValues(alpha: 0.8),
                    fontSize: 13,
                    height: 1.5,
                  ),
                ),

                const SizedBox(height: 24),

                _buildAboutRow(
                  Icons.code_outlined,
                  'Developer',
                  'AquaIntel Team',
                ),

                const SizedBox(height: 14),

                _buildAboutRow(
                  Icons.mail_outline,
                  'Contact',
                  'hello@aquaintel.app',
                ),

                const SizedBox(height: 14),

                _buildAboutRow(
                  Icons.gavel_outlined,
                  'License',
                  'MIT License',
                ),

                const SizedBox(height: 8),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _buildAboutRow(
    IconData icon,
    String label,
    String value,
  ) {
    return Row(
      children: [
        Icon(
          icon,
          color: primaryBlue.withValues(alpha: 0.8),
          size: 19,
        ),

        const SizedBox(width: 12),

        Text(
          label,
          style: TextStyle(
            color: textSecondary.withValues(alpha: 0.65),
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