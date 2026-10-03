import 'package:flutter/material.dart';
import '../models/aquarium_model.dart';
import '../services/aquarium_service.dart';
import '../widgets/aquarium_card.dart';
import 'reminder.dart';
import 'setting.dart';
import 'comtability_checker.dart';
import '../screens/aquarium/add_aquarium_screen.dart';
import '../widgets/aqua_bottom_nav.dart';
import 'aquabot_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Dashboard selected by default
  final AquariumService _aquariumService = AquariumService();

  // ─── AquaIntel Color Palette ───
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [
            // ═══════════════════════════════════════
            // TOP CURVED BACKGROUND
            // ═══════════════════════════════════════
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: Container(
                height: 200,
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
                        const SizedBox(width: 10),
                        _buildHeaderIcon(Icons.person_outline),
                      ],
                    ),
                  ),
                ),

                // ─── WELCOME SECTION ───
                SliverToBoxAdapter(
                  child: Padding(
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Welcome Back!',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            letterSpacing: -0.5,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'View your tanks and track key metrics.',
                          style: TextStyle(
                            color: textBlue.withValues(alpha: 0.9),
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
                    padding: const EdgeInsets.fromLTRB(20, 28, 20, 14),
                    child: Row(
                      children: [
                        const Text(
                          'Your Aquariums',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        // Add button
                        GestureDetector(
                          onTap: _navigateToAddAquarium,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(20),
                              border: Border.all(
                                color: primaryBlue.withValues(alpha: 0.3),
                              ),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.add, color: primaryBlue, size: 14),
                                SizedBox(width: 4),
                                Text(
                                  'Add',
                                  style: TextStyle(
                                    color: primaryBlue,
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
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                  sliver: SliverToBoxAdapter(
                    child: StreamBuilder<List<AquariumModel>>(
                      stream: _aquariumService.getAquariums(),
                      builder: (context, snapshot) {

                        // Loading state
                        if (snapshot.connectionState ==
                            ConnectionState.waiting) {
                          return const Padding(
                            padding: EdgeInsets.symmetric(vertical: 40),
                            child: Center(
                              child: CircularProgressIndicator(
                                color: primaryBlue,
                              ),
                            ),
                          );
                        }

                        // Error state
                        if (snapshot.hasError) {
                          return _buildErrorState(snapshot.error.toString());
                        }

                        final aquariums = snapshot.data ?? [];

                        // Empty state
                        if (aquariums.isEmpty) {
                          return _buildEmptyState();
                        }

                        // Aquarium list
                        return Column(
                          children: [
                            // Tank count
                            Align(
                              alignment: Alignment.centerRight,
                              child: Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: Text(
                                  '${aquariums.length} tank${aquariums.length != 1 ? 's' : ''}',
                                  style: TextStyle(
                                    color: textBlue.withValues(alpha: 0.7),
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

// ═══════════════════════════════════════
// FLOATING AI CHAT BUTTON
// ═══════════════════════════════════════
Positioned(
  right: 18,
  bottom: 12,
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
      width: 58,
      height: 58,
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            Color(0xFF29A8DF),
            Color(0xFF1B8FC4),
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryBlue.withValues(alpha: 0.35),
            blurRadius: 14,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: const Icon(
        Icons.auto_awesome,
        color: Colors.white,
        size: 26,
      ),
    ),
  ),
),
```

          ],
        ),
      ),

      // ═══════════════════════════════════════
      // BOTTOM NAVIGATION BAR
      // ═══════════════════════════════════════
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

  /// Navigate to the Add Aquarium screen.
  void _navigateToAddAquarium() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddAquariumScreen()),
    );
  }

  // ──────────────────────────────────────────
  // STATES: Empty / Error
  // ──────────────────────────────────────────

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 40),
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
              Icons.water_outlined,
              size: 40,
              color: primaryBlue.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            'No Aquariums Yet',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Tap the + button to add your first aquarium.',
            style: TextStyle(
              color: textBlue.withValues(alpha: 0.7),
              fontSize: 14,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: _navigateToAddAquarium,
            icon: const Icon(Icons.add),
            label: const Text('Add Aquarium'),
            style: ElevatedButton.styleFrom(
              backgroundColor: primaryBlue,
              foregroundColor: Colors.white,
              padding:
                  const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
            ),
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
          Icon(Icons.error_outline, size: 48, color: Colors.red.shade400),
          const SizedBox(height: 16),
          const Text(
            'Could not load aquariums',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(
              color: textBlue.withValues(alpha: 0.7),
              fontSize: 12,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ──────────────────────────────────────────
  // HEADER ICON BUTTON
  // ──────────────────────────────────────────
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
      child: Icon(icon, color: textBlue, size: 20),
    );
  }

  // ──────────────────────────────────────────
  // COMPATIBILITY CHECKER CARD
  // ──────────────────────────────────────────
  Widget _buildCompatibilityCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 18),
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
        borderRadius: BorderRadius.circular(18),
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
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.2),
              borderRadius: BorderRadius.circular(14),
            ),
            child: const Icon(
              Icons.fact_check_outlined,
              color: Colors.white,
              size: 26,
            ),
          ),
          const SizedBox(width: 16),
          const Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Compatibility Checker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: 4),
                Text(
                  'Check if your fish species are compatible',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Icon(
            Icons.arrow_forward_ios,
            color: Colors.white.withValues(alpha: 0.7),
            size: 16,
          ),
        ],
      ),
    );
  }
}
