import 'package:flutter/material.dart';
import 'reminder.dart';
import 'setting.dart';
import 'comtability_checker.dart';
import '../widgets/aqua_bottom_nav.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 1; // Dashboard selected by default
  final TextEditingController _chatController = TextEditingController();

  // ─── AquaIntel Color Palette (matching sign_in) ───
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);

  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);


  // ─── Sample aquarium data ───
  final List<Map<String, String>> _aquariums = [
    {
      'name': 'Aqua aura',
      'type': 'FRESHWATER',
      'size': '5000.0 Liters',
      'shape': 'Rectangular',
      'temperature': '36.0°C',
      'location': 'Living room',
    },
  ];

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
                        // Notification icon
                        _buildHeaderIcon(Icons.notifications_outlined),
                        const SizedBox(width: 10),
                        // Profile icon
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
                            builder: (context) =>
                                const CompatibilityCheckerScreen(),
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
                        Text(
                          '${_aquariums.length} tank${_aquariums.length != 1 ? 's' : ''}',
                          style: TextStyle(
                            color: textBlue.withValues(alpha: 0.7),
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // ─── AQUARIUM CARDS LIST ───
                SliverPadding(
                  padding: const EdgeInsets.fromLTRB(20, 0, 20, 160),
                  sliver: SliverList(
                    delegate: SliverChildBuilderDelegate(
                      (context, index) {
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 14),
                          child: _buildAquariumCard(_aquariums[index]),
                        );
                      },
                      childCount: _aquariums.length,
                    ),
                  ),
                ),
              ],
            ),

            // ═══════════════════════════════════════
            // FLOATING CHAT INPUT BAR
            // ═══════════════════════════════════════
            Positioned(
              left: 16,
              right: 16,
              bottom: 12,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 6),
                decoration: BoxDecoration(
                  color: cardColor,
                  borderRadius: BorderRadius.circular(28),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.2),
                    width: 1,
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.25),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Row(
                  children: [
                    const SizedBox(width: 6),
                    // Sparkle / AI icon
                    Container(
                      width: 34,
                      height: 34,
                      decoration: BoxDecoration(
                        gradient: const LinearGradient(
                          colors: [Color(0xFF29A8DF), Color(0xFF1B8FC4)],
                        ),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: const Icon(
                        Icons.auto_awesome,
                        color: Colors.white,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    // Text field
                    Expanded(
                      child: TextField(
                        controller: _chatController,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Ask AquaIntel anything...',
                          hintStyle: TextStyle(
                            color: textBlue.withValues(alpha: 0.5),
                            fontSize: 14,
                          ),
                          border: InputBorder.none,
                          isDense: true,
                          contentPadding:
                              const EdgeInsets.symmetric(vertical: 10),
                        ),
                      ),
                    ),
                    // Send button
                    GestureDetector(
                      onTap: () {
                        if (_chatController.text.isNotEmpty) {
                          // TODO: Handle chat send
                          _chatController.clear();
                        }
                      },
                      child: Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                            colors: [
                              Color(0xFF29A8DF),
                              Color(0xFF1B8FC4),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(14),
                          boxShadow: [
                            BoxShadow(
                              color: primaryBlue.withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.send_rounded,
                          color: Colors.white,
                          size: 18,
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

      // ═══════════════════════════════════════
      // BOTTOM NAVIGATION BAR (with centered FAB)
      // ═══════════════════════════════════════
      bottomNavigationBar: AquaBottomNav(
        currentIndex: _currentIndex,
        onItemSelected: (index) {
          if (index == 0) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReminderScreen(),
              ),
            );
            return;
          }
          if (index == 3) {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SettingScreen(),
              ),
            );
            return;
          }
          setState(() {
            _currentIndex = index;
          });
        },
        onFabPressed: () {
          // TODO: Navigate to Add Aquarium screen
        },
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
  // COMPATIBILITY CHECKER CARD
  // ══════════════════════════════════════════════
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
          // Icon container
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
          // Text
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Compatibility Checker',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  'Check if your fish species are compatible',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
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

  // ══════════════════════════════════════════════
  // AQUARIUM CARD
  // ══════════════════════════════════════════════
  Widget _buildAquariumCard(Map<String, String> aquarium) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ─── Card Header ───
          Row(
            children: [
              Container(
                width: 40,
                height: 40,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.water,
                  color: primaryBlue,
                  size: 22,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  aquarium['name'] ?? '',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Icon(
                Icons.chevron_right,
                color: textBlue.withValues(alpha: 0.6),
                size: 24,
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Divider
          Container(
            height: 1,
            color: primaryBlue.withValues(alpha: 0.1),
          ),

          const SizedBox(height: 14),

          // ─── Detail Rows ───
          _buildDetailRow('Type', aquarium['type'] ?? ''),
          const SizedBox(height: 10),
          _buildDetailRow('Size', aquarium['size'] ?? ''),
          const SizedBox(height: 10),
          _buildDetailRow('Shape', aquarium['shape'] ?? ''),
          const SizedBox(height: 10),
          _buildDetailRow('Temperature', aquarium['temperature'] ?? ''),
          const SizedBox(height: 10),
          _buildDetailRow('Location', aquarium['location'] ?? ''),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // DETAIL ROW (Label : Value)
  // ══════════════════════════════════════════════
  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.8),
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }


}
