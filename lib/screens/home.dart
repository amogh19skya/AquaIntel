import 'package:flutter/material.dart';
import '../models/aquarium_model.dart';
import '../models/reminder_model.dart';
import '../models/user_model.dart';
import '../services/aquarium_service.dart';
import '../services/notification_service.dart';
import '../services/reminder_service.dart';
import '../services/notification_centre_service.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/aquarium_card.dart';
import '../widgets/user_avatar.dart';
import 'notifications/notification_centre_screen.dart';
import 'avatar_selection_screen.dart';
import 'reminder.dart';
import 'setting.dart';
import 'comtability_checker.dart';
import '../screens/aquarium/add_aquarium_screen.dart';
import '../widgets/aqua_bottom_nav.dart';
import 'aquabot_screen.dart';
import 'community/community_feed_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen>
    with WidgetsBindingObserver {
  int _currentIndex = 1; // Dashboard selected by default
  final AquariumService _aquariumService = AquariumService();
  final NotificationService _notificationService = NotificationService();
  final ReminderService _reminderService = ReminderService();
  final UserService _userService = UserService();

  final NotificationCentreService _notifCentreService =
      NotificationCentreService();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    WidgetsBinding.instance
        .addPostFrameCallback((_) => _checkPendingNavigation());
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _checkPendingNavigation();
    }
  }

  void _checkPendingNavigation() {
    final pending = _notificationService.consumePendingNavigation();
    if (pending != null && mounted) {
      Navigator.of(context).pushNamed(
        pending.route,
        arguments: pending.reminderId,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── APP BAR ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    // Logo
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AquaColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AquaColors.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: const Icon(
                        Icons.water_drop,
                        color: AquaColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    const Text(
                      'AquaIntel',
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                    const Spacer(),
                    StreamBuilder<List<ReminderModel>>(
                      stream: _reminderService.getReminders(),
                      builder: (context, snapshot) {
                        final reminders = snapshot.data ?? [];

                        return FutureBuilder<Set<String>>(
                          future: _notifCentreService.getReadNotificationIds(),
                          builder: (context, readSnap) {
                            return FutureBuilder<Set<String>>(
                              future: _notifCentreService
                                  .getClearedNotificationIds(),
                              builder: (context, clearedSnap) {
                                final readIds = readSnap.data ?? {};
                                final clearedIds = clearedSnap.data ?? {};

                                final unreadCount = reminders
                                    .where((r) =>
                                        r.id != null &&
                                        !clearedIds.contains(r.id) &&
                                        !readIds.contains(r.id))
                                    .length;

                                return GestureDetector(
                                  onTap: () async {
                                    await Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationCentreScreen(),
                                      ),
                                    );
                                    if (mounted) setState(() {});
                                  },
                                  child: Stack(
                                    clipBehavior: Clip.none,
                                    children: [
                                      _buildHeaderIcon(
                                          Icons.notifications_outlined),
                                      if (unreadCount > 0)
                                        Positioned(
                                          top: -2,
                                          right: -2,
                                          child: Container(
                                            padding: const EdgeInsets.all(4),
                                            decoration: const BoxDecoration(
                                              color: AquaColors.error,
                                              shape: BoxShape.circle,
                                            ),
                                            constraints: const BoxConstraints(
                                              minWidth: 16,
                                              minHeight: 16,
                                            ),
                                            child: Center(
                                              child: Text(
                                                unreadCount > 9
                                                    ? '9+'
                                                    : '$unreadCount',
                                                style: const TextStyle(
                                                  color: Colors.white,
                                                  fontSize: 9,
                                                  fontWeight: FontWeight.bold,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                    ],
                                  ),
                                );
                              },
                            );
                          },
                        );
                      },
                    ),
                    const SizedBox(width: 8),
                    StreamBuilder<String>(
                      stream: _userService.currentAvatarIdStream(),
                      builder: (context, snapshot) {
                        final avatarId = snapshot.data ?? UserModel.defaultAvatarId;
                        return GestureDetector(
                          onTap: () async {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (_) => AvatarSelectionScreen(
                                  initialAvatarId: avatarId,
                                ),
                              ),
                            );
                            if (mounted) setState(() {});
                          },
                          child: UserAvatar(
                            avatarId: avatarId,
                            size: 38,
                            showBorder: true,
                            borderColor: AquaColors.border,
                            borderWidth: 1.5,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),

            // ─── WELCOME SECTION ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Welcome Back!',
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 29,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 6),
                    const Text(
                      'View your tanks and track key metrics.',
                      style: TextStyle(
                        color: AquaColors.textSecondary,
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── COMPATIBILITY CHECKER CARD ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CompatibilityCheckerScreen(),
                      ),
                    );
                  },
                  child: _buildCompatibilityCard(),
                ),
              ),
            ),

            // ─── YOUR AQUARIUMS HEADER ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 0),
                child: Row(
                  children: [
                    const Text(
                      'Your Aquariums',
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const Spacer(),
                    // + Add button
                    GestureDetector(
                      onTap: _navigateToAddAquarium,
                      child: Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 6),
                        decoration: BoxDecoration(
                          color: AquaColors.accent.withValues(alpha: 0.12),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(
                            color: AquaColors.accent.withValues(alpha: 0.3),
                          ),
                        ),
                        child: const Row(
                          children: [
                            Icon(Icons.add, color: AquaColors.accent, size: 14),
                            SizedBox(width: 4),
                            Text(
                              'Add',
                              style: TextStyle(
                                color: AquaColors.accent,
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
            ),

            // ─── REAL-TIME AQUARIUM LIST ───
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 160),
              sliver: SliverToBoxAdapter(
                child: StreamBuilder<List<AquariumModel>>(
                  stream: _aquariumService.getAquariums(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Padding(
                        padding: EdgeInsets.symmetric(vertical: 40),
                        child: Center(
                          child: CircularProgressIndicator(
                            color: AquaColors.accent,
                          ),
                        ),
                      );
                    }

                    if (snapshot.hasError) {
                      return _buildErrorState(snapshot.error.toString());
                    }

                    final aquariums = snapshot.data ?? [];

                    if (aquariums.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: [
                        Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 12),
                            child: Text(
                              '${aquariums.length} tank${aquariums.length != 1 ? 's' : ''}',
                              style: const TextStyle(
                                color: AquaColors.textMuted,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ),
                        ...aquariums.map(
                          (aquarium) => Padding(
                            padding: const EdgeInsets.only(bottom: 14),
                            child: AquariumCard(aquarium: aquarium),
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ─── FLOATING AI CHAT BUTTON ───
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (_) => const AquaBotScreen(),
              ),
            );
          },
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AquaColors.card,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: AquaColors.accent.withValues(alpha: 0.35),
              ),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.accent.withValues(alpha: 0.18),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(
              Icons.auto_awesome,
              color: AquaColors.accent,
              size: 24,
            ),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,

      // ─── BOTTOM NAVIGATION BAR ───
      bottomNavigationBar: AquaBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const ReminderScreen()),
            );
            return;
          }
          if (index == 2) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CommunityFeedScreen()),
            );
            return;
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const SettingScreen()),
            );
            return;
          }
          setState(() => _currentIndex = index);
        },
        onFabPressed: _navigateToAddAquarium,
      ),
    );
  }

  void _navigateToAddAquarium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAquariumScreen()),
    );
  }

  // ── Empty State ──

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 48),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AquaColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AquaColors.border),
            ),
            child: const Icon(
              Icons.water_outlined,
              size: 36,
              color: AquaColors.textMuted,
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Aquariums Yet',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Tap the + button to add your first aquarium.',
            style: TextStyle(
              color: AquaColors.textSecondary,
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddAquarium,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Aquarium'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
      child: Column(
        children: [
          const Icon(Icons.error_outline, size: 48, color: AquaColors.error),
          const SizedBox(height: 16),
          const Text(
            'Could not load aquariums',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: const TextStyle(
              color: AquaColors.textSecondary,
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ── Header Icon Button ──
  Widget _buildHeaderIcon(IconData icon) {
    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: AquaColors.card,
        shape: BoxShape.circle,
        border: Border.all(color: AquaColors.border),
      ),
      child: Icon(icon, color: AquaColors.textSecondary, size: 19),
    );
  }

  // ── Compatibility Checker Card ──
  Widget _buildCompatibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AquaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              color: AquaColors.accent.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: AquaColors.accent.withValues(alpha: 0.2),
              ),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: AquaColors.accent,
              size: 22,
            ),
          ),
          const SizedBox(width: 14),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compatibility Checker',
                  style: TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  'Check if your fish species are compatible',
                  style: TextStyle(
                    color: AquaColors.textSecondary,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const Icon(
            Icons.arrow_forward_ios,
            color: AquaColors.textMuted,
            size: 15,
          ),
        ],
      ),
    );
  }
}
