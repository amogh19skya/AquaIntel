import 'package:flutter/material.dart';
import 'dart:math' as math;

// ═══════════════════════════════════════════════════════════════════
// MOCK FISH DATA
// ═══════════════════════════════════════════════════════════════════

class FishData {
  final String name;
  final String scientificName;
  final String temperament;
  final String size;
  final String temperature;
  final String ph;
  final String tankSize;
  final IconData icon;
  final Color accentColor;

  const FishData({
    required this.name,
    required this.scientificName,
    required this.temperament,
    required this.size,
    required this.temperature,
    required this.ph,
    required this.tankSize,
    required this.icon,
    required this.accentColor,
  });
}

const List<FishData> mockFishList = [
  FishData(
    name: 'Betta',
    scientificName: 'Betta splendens',
    temperament: 'Semi-aggressive',
    size: '6–8 cm',
    temperature: '24–30°C',
    ph: '6.5–7.5',
    tankSize: '20L+',
    icon: Icons.waves,
    accentColor: Color(0xFFE53935),
  ),
  FishData(
    name: 'Neon Tetra',
    scientificName: 'Paracheirodon innesi',
    temperament: 'Peaceful',
    size: '3–4 cm',
    temperature: '20–26°C',
    ph: '6.0–7.0',
    tankSize: '40L+',
    icon: Icons.bubble_chart,
    accentColor: Color(0xFF29B6F6),
  ),
  FishData(
    name: 'Guppy',
    scientificName: 'Poecilia reticulata',
    temperament: 'Peaceful',
    size: '3–6 cm',
    temperature: '22–28°C',
    ph: '6.8–7.8',
    tankSize: '40L+',
    icon: Icons.water,
    accentColor: Color(0xFF66BB6A),
  ),
  FishData(
    name: 'Goldfish',
    scientificName: 'Carassius auratus',
    temperament: 'Peaceful',
    size: '10–30 cm',
    temperature: '18–24°C',
    ph: '7.0–8.4',
    tankSize: '75L+',
    icon: Icons.spa,
    accentColor: Color(0xFFFF9800),
  ),
  FishData(
    name: 'Angelfish',
    scientificName: 'Pterophyllum scalare',
    temperament: 'Semi-aggressive',
    size: '12–15 cm',
    temperature: '24–30°C',
    ph: '6.0–7.5',
    tankSize: '150L+',
    icon: Icons.change_history,
    accentColor: Color(0xFFAB47BC),
  ),
  FishData(
    name: 'Corydoras',
    scientificName: 'Corydoras paleatus',
    temperament: 'Peaceful',
    size: '5–7 cm',
    temperature: '22–26°C',
    ph: '6.0–7.5',
    tankSize: '40L+',
    icon: Icons.circle,
    accentColor: Color(0xFF8D6E63),
  ),
  FishData(
    name: 'Oscar',
    scientificName: 'Astronotus ocellatus',
    temperament: 'Aggressive',
    size: '25–35 cm',
    temperature: '22–28°C',
    ph: '6.0–8.0',
    tankSize: '200L+',
    icon: Icons.shield,
    accentColor: Color(0xFFEF5350),
  ),
  FishData(
    name: 'Platy',
    scientificName: 'Xiphophorus maculatus',
    temperament: 'Peaceful',
    size: '4–7 cm',
    temperature: '20–28°C',
    ph: '7.0–8.3',
    tankSize: '40L+',
    icon: Icons.favorite,
    accentColor: Color(0xFFEC407A),
  ),
];

// ═══════════════════════════════════════════════════════════════════
// COMPATIBILITY CHECKER SCREEN
// ═══════════════════════════════════════════════════════════════════

class CompatibilityCheckerScreen extends StatefulWidget {
  const CompatibilityCheckerScreen({super.key});

  @override
  State<CompatibilityCheckerScreen> createState() =>
      _CompatibilityCheckerScreenState();
}

class _CompatibilityCheckerScreenState extends State<CompatibilityCheckerScreen>
    with TickerProviderStateMixin {
  // ─── AquaIntel Color Palette ───
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  // ─── State ───
  FishData? _firstFish;
  FishData? _secondFish;
  bool _showResults = false;

  late AnimationController _fadeController;
  late Animation<double> _fadeAnim;

  late AnimationController _resultController;
  late Animation<double> _resultFadeAnim;
  late Animation<double> _scoreAnim;

  late AnimationController _swapController;
  late Animation<double> _swapRotation;

  @override
  void initState() {
    super.initState();
    // Page entrance fade
    _fadeController = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();

    // Result section animation
    _resultController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _resultFadeAnim = CurvedAnimation(
      parent: _resultController,
      curve: Curves.easeOut,
    );
    _scoreAnim = Tween<double>(begin: 0, end: 82).animate(
      CurvedAnimation(
        parent: _resultController,
        curve: const Interval(0.2, 1.0, curve: Curves.easeOutCubic),
      ),
    );

    // Swap button rotation
    _swapController = AnimationController(
      duration: const Duration(milliseconds: 400),
      vsync: this,
    );
    _swapRotation = Tween<double>(begin: 0, end: math.pi).animate(
      CurvedAnimation(parent: _swapController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _resultController.dispose();
    _swapController.dispose();
    super.dispose();
  }

  void _swapFish() {
    if (_firstFish == null && _secondFish == null) return;
    setState(() {
      final temp = _firstFish;
      _firstFish = _secondFish;
      _secondFish = temp;
      _showResults = false;
    });
    _swapController.forward(from: 0);
    _resultController.reset();
  }

  void _checkCompatibility() {
    if (_firstFish == null || _secondFish == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Please select both fish first'),
          backgroundColor: cardColor,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      );
      return;
    }
    setState(() {
      _showResults = true;
    });
    _resultController.forward(from: 0);
  }

  void _resetSelection() {
    setState(() {
      _firstFish = null;
      _secondFish = null;
      _showResults = false;
    });
    _resultController.reset();
  }

  Future<void> _selectFish(bool isFirst) async {
    final selected = await showModalBottomSheet<FishData>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => _FishSelectionSheet(
        selectedFish: isFirst ? _firstFish : _secondFish,
        otherFish: isFirst ? _secondFish : _firstFish,
      ),
    );
    if (selected != null) {
      setState(() {
        if (isFirst) {
          _firstFish = selected;
        } else {
          _secondFish = selected;
        }
        _showResults = false;
      });
      _resultController.reset();
    }
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
                  height: 240,
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
                  // ─── APP BAR ───
                  SliverToBoxAdapter(child: _buildAppBar()),

                  // ─── HEADER ───
                  SliverToBoxAdapter(child: _buildHeader()),

                  // ─── FIRST FISH CARD ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                      child: _buildFishCard(
                        label: 'First Fish',
                        fish: _firstFish,
                        onTap: () => _selectFish(true),
                        iconLabel: '1',
                      ),
                    ),
                  ),

                  // ─── SWAP BUTTON ───
                  SliverToBoxAdapter(
                    child: _buildSwapButton(),
                  ),

                  // ─── SECOND FISH CARD ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 0, 20, 0),
                      child: _buildFishCard(
                        label: 'Second Fish',
                        fish: _secondFish,
                        onTap: () => _selectFish(false),
                        iconLabel: '2',
                      ),
                    ),
                  ),

                  // ─── CHECK BUTTON ───
                  SliverToBoxAdapter(child: _buildCheckButton()),

                  // ─── RESULTS SECTION ───
                  if (_showResults) ...[
                    SliverToBoxAdapter(child: _buildResultCard()),
                    SliverToBoxAdapter(child: _buildCompatibilityOverview()),
                    SliverToBoxAdapter(child: _buildRecommendationCard()),
                    SliverToBoxAdapter(child: _buildCheckAnotherButton()),
                  ],

                  // Bottom spacing
                  const SliverToBoxAdapter(
                    child: SizedBox(height: 40),
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
  // APP BAR
  // ══════════════════════════════════════════════
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
          // Title
          const Expanded(
            child: Text(
              'Compatibility Checker',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
                letterSpacing: 0.3,
              ),
            ),
          ),
          // Info button
          GestureDetector(
            onTap: () => _showInfoDialog(),
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
                Icons.info_outline_rounded,
                color: textBlue,
                size: 18,
              ),
            ),
          ),
        ],
      ),
    );
  }

  void _showInfoDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.info_outline_rounded, color: primaryBlue, size: 22),
            SizedBox(width: 10),
            Text(
              'How it works',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Select two fish species to check if they can live '
          'together in the same aquarium. The compatibility score '
          'is based on water parameters, temperament, size, and '
          'tank requirements.',
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.9),
            fontSize: 14,
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Got it',
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

  // ══════════════════════════════════════════════
  // HEADER SECTION
  // ══════════════════════════════════════════════
  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Check Fish\nCompatibility',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 26,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.5,
                        height: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
              // Subtle aquarium visual element
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      primaryBlue.withValues(alpha: 0.2),
                      primaryBlue.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.water,
                      color: primaryBlue.withValues(alpha: 0.3),
                      size: 40,
                    ),
                    const Icon(
                      Icons.set_meal_rounded,
                      color: primaryBlue,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            'Find out if two fish can live together in the same aquarium.',
            style: TextStyle(
              color: textBlue.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // FISH SELECTION CARD
  // ══════════════════════════════════════════════
  Widget _buildFishCard({
    required String label,
    required FishData? fish,
    required VoidCallback onTap,
    required String iconLabel,
  }) {
    final bool isSelected = fish != null;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
        width: double.infinity,
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(
            color: isSelected
                ? primaryBlue.withValues(alpha: 0.4)
                : primaryBlue.withValues(alpha: 0.1),
            width: isSelected ? 1.5 : 1,
          ),
          boxShadow: [
            BoxShadow(
              color: isSelected
                  ? primaryBlue.withValues(alpha: 0.1)
                  : Colors.black.withValues(alpha: 0.15),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            // Fish icon / placeholder
            AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              width: 56,
              height: 56,
              decoration: BoxDecoration(
                color: isSelected
                    ? fish.accentColor.withValues(alpha: 0.15)
                    : inputColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: isSelected
                      ? fish!.accentColor.withValues(alpha: 0.3)
                      : primaryBlue.withValues(alpha: 0.1),
                  width: 1,
                ),
              ),
              child: isSelected
                  ? Icon(
                      fish.icon,
                      color: fish.accentColor,
                      size: 28,
                    )
                  : Icon(
                      Icons.set_meal_rounded,
                      color: textBlue.withValues(alpha: 0.4),
                      size: 26,
                    ),
            ),
            const SizedBox(width: 14),
            // Text content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Label
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          label,
                          style: const TextStyle(
                            color: primaryBlue,
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  // Fish name
                  Text(
                    isSelected ? fish.name : 'Select a fish',
                    style: TextStyle(
                      color: isSelected ? Colors.white : textBlue,
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 2),
                  // Subtitle
                  Text(
                    isSelected
                        ? fish.scientificName
                        : 'Tap to choose a species',
                    style: TextStyle(
                      color: isSelected
                          ? textBlue.withValues(alpha: 0.8)
                          : textBlue.withValues(alpha: 0.5),
                      fontSize: 12,
                      fontStyle:
                          isSelected ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ],
              ),
            ),
            // Chevron
            Icon(
              Icons.chevron_right_rounded,
              color: textBlue.withValues(alpha: 0.5),
              size: 24,
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // SWAP BUTTON
  // ══════════════════════════════════════════════
  Widget _buildSwapButton() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Center(
        child: GestureDetector(
          onTap: _swapFish,
          child: AnimatedBuilder(
            animation: _swapRotation,
            builder: (context, child) {
              return Transform.rotate(
                angle: _swapRotation.value,
                child: child,
              );
            },
            child: Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: inputColor,
                shape: BoxShape.circle,
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.25),
                  width: 1.5,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.swap_vert_rounded,
                color: primaryBlue,
                size: 22,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // CHECK COMPATIBILITY BUTTON
  // ══════════════════════════════════════════════
  Widget _buildCheckButton() {
    final bool canCheck = _firstFish != null && _secondFish != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: GestureDetector(
        onTap: _checkCompatibility,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 300),
          width: double.infinity,
          height: 54,
          decoration: BoxDecoration(
            gradient: canCheck
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      Color(0xFF29A8DF),
                      Color(0xFF1B8FC4),
                    ],
                  )
                : null,
            color: canCheck ? null : inputColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: canCheck
                ? [
                    BoxShadow(
                      color: primaryBlue.withValues(alpha: 0.35),
                      blurRadius: 16,
                      offset: const Offset(0, 6),
                    ),
                  ]
                : null,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.fact_check_outlined,
                color: canCheck
                    ? Colors.white
                    : textBlue.withValues(alpha: 0.4),
                size: 20,
              ),
              const SizedBox(width: 10),
              Text(
                'Check Compatibility',
                style: TextStyle(
                  color: canCheck
                      ? Colors.white
                      : textBlue.withValues(alpha: 0.4),
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // RESULT CARD  — Score & Status
  // ══════════════════════════════════════════════
  Widget _buildResultCard() {
    return FadeTransition(
      opacity: _resultFadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
          decoration: BoxDecoration(
            color: cardColor,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: primaryBlue.withValues(alpha: 0.15),
              width: 1,
            ),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.2),
                blurRadius: 16,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              // Section label
              Text(
                'Compatibility Score',
                style: TextStyle(
                  color: textBlue.withValues(alpha: 0.8),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 0.5,
                ),
              ),
              const SizedBox(height: 20),

              // Circular progress indicator with score
              AnimatedBuilder(
                animation: _scoreAnim,
                builder: (context, child) {
                  final score = _scoreAnim.value;
                  return SizedBox(
                    width: 140,
                    height: 140,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        // Background ring
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: 1.0,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            color: inputColor,
                          ),
                        ),
                        // Active ring
                        SizedBox(
                          width: 140,
                          height: 140,
                          child: CircularProgressIndicator(
                            value: score / 100,
                            strokeWidth: 8,
                            strokeCap: StrokeCap.round,
                            color: _getScoreColor(score),
                          ),
                        ),
                        // Score text
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              '${score.toInt()}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 40,
                                fontWeight: FontWeight.bold,
                                letterSpacing: -1,
                              ),
                            ),
                            Text(
                              '/ 100',
                              style: TextStyle(
                                color: textBlue.withValues(alpha: 0.6),
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
              const SizedBox(height: 18),

              // Status badge
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 8,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF66BB6A).withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: const Color(0xFF66BB6A).withValues(alpha: 0.3),
                    width: 1,
                  ),
                ),
                child: const Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.check_circle_rounded,
                      color: Color(0xFF66BB6A),
                      size: 16,
                    ),
                    SizedBox(width: 6),
                    Text(
                      'Highly Compatible',
                      style: TextStyle(
                        color: Color(0xFF66BB6A),
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Color _getScoreColor(double score) {
    if (score >= 75) return const Color(0xFF66BB6A);
    if (score >= 50) return const Color(0xFFFF9800);
    return const Color(0xFFEF5350);
  }

  // ══════════════════════════════════════════════
  // COMPATIBILITY OVERVIEW  — Detailed rows
  // ══════════════════════════════════════════════
  Widget _buildCompatibilityOverview() {
    return FadeTransition(
      opacity: _resultFadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
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
              const Text(
                'Compatibility Overview',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                'How well these species match across key factors',
                style: TextStyle(
                  color: textBlue.withValues(alpha: 0.6),
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 16),
              // Divider
              Container(
                height: 1,
                color: primaryBlue.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 12),
              _buildOverviewRow(
                icon: Icons.thermostat_outlined,
                label: 'Water Temperature',
                status: 'Compatible',
                statusColor: const Color(0xFF66BB6A),
                statusIcon: Icons.check_circle_outline,
              ),
              _buildOverviewRow(
                icon: Icons.science_outlined,
                label: 'pH Level',
                status: 'Compatible',
                statusColor: const Color(0xFF66BB6A),
                statusIcon: Icons.check_circle_outline,
              ),
              _buildOverviewRow(
                icon: Icons.pets_outlined,
                label: 'Temperament',
                status: 'Caution',
                statusColor: const Color(0xFFFF9800),
                statusIcon: Icons.warning_amber_rounded,
              ),
              _buildOverviewRow(
                icon: Icons.straighten_outlined,
                label: 'Size',
                status: 'Compatible',
                statusColor: const Color(0xFF66BB6A),
                statusIcon: Icons.check_circle_outline,
              ),
              _buildOverviewRow(
                icon: Icons.water_damage_outlined,
                label: 'Tank Requirements',
                status: 'Compatible',
                statusColor: const Color(0xFF66BB6A),
                statusIcon: Icons.check_circle_outline,
                isLast: true,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOverviewRow({
    required IconData icon,
    required String label,
    required String status,
    required Color statusColor,
    required IconData statusIcon,
    bool isLast = false,
  }) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 10),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  icon,
                  color: textBlue,
                  size: 18,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(statusIcon, color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        if (!isLast)
          Container(
            height: 1,
            color: primaryBlue.withValues(alpha: 0.06),
          ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // RECOMMENDATION CARD
  // ══════════════════════════════════════════════
  Widget _buildRecommendationCard() {
    return FadeTransition(
      opacity: _resultFadeAnim,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
        child: Container(
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
              Row(
                children: [
                  Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: primaryBlue.withValues(alpha: 0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.lightbulb_outline_rounded,
                      color: primaryBlue,
                      size: 18,
                    ),
                  ),
                  const SizedBox(width: 10),
                  const Text(
                    'Recommendation',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Container(
                height: 1,
                color: primaryBlue.withValues(alpha: 0.08),
              ),
              const SizedBox(height: 14),
              Text(
                'These fish have similar water requirements and can generally '
                'be kept together. Monitor temperament during the first few '
                'days and provide sufficient hiding spots for both species.',
                style: TextStyle(
                  color: textBlue.withValues(alpha: 0.9),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 14),
              // Tip row
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: primaryBlue.withValues(alpha: 0.08),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: primaryBlue.withValues(alpha: 0.12),
                    width: 1,
                  ),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.tips_and_updates_outlined,
                      color: primaryBlue.withValues(alpha: 0.8),
                      size: 18,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        'Tip: Start with a larger tank to reduce territorial stress.',
                        style: TextStyle(
                          color: textBlue.withValues(alpha: 0.8),
                          fontSize: 12,
                          fontWeight: FontWeight.w500,
                          height: 1.4,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // CHECK ANOTHER PAIR BUTTON
  // ══════════════════════════════════════════════
  Widget _buildCheckAnotherButton() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
      child: GestureDetector(
        onTap: _resetSelection,
        child: Container(
          width: double.infinity,
          height: 50,
          decoration: BoxDecoration(
            color: Colors.transparent,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: primaryBlue.withValues(alpha: 0.4),
              width: 1.5,
            ),
          ),
          child: const Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                Icons.refresh_rounded,
                color: primaryBlue,
                size: 20,
              ),
              SizedBox(width: 8),
              Text(
                'Check Another Pair',
                style: TextStyle(
                  color: primaryBlue,
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.3,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// FISH SELECTION BOTTOM SHEET
// ═══════════════════════════════════════════════════════════════════

class _FishSelectionSheet extends StatefulWidget {
  final FishData? selectedFish;
  final FishData? otherFish;

  const _FishSelectionSheet({
    this.selectedFish,
    this.otherFish,
  });

  @override
  State<_FishSelectionSheet> createState() => _FishSelectionSheetState();
}

class _FishSelectionSheetState extends State<_FishSelectionSheet> {
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  List<FishData> get _filteredFish {
    if (_searchQuery.isEmpty) return mockFishList;
    return mockFishList.where((fish) {
      return fish.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          fish.scientificName
              .toLowerCase()
              .contains(_searchQuery.toLowerCase());
    }).toList();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
      ),
      child: Column(
        children: [
          // ─── Handle bar ───
          const SizedBox(height: 12),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: textBlue.withValues(alpha: 0.3),
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          const SizedBox(height: 16),

          // ─── Sheet header ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Row(
              children: [
                Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: primaryBlue.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.set_meal_rounded,
                    color: primaryBlue,
                    size: 20,
                  ),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Text(
                    'Select a Fish',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Container(
                    width: 34,
                    height: 34,
                    decoration: BoxDecoration(
                      color: cardColor.withValues(alpha: 0.6),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: primaryBlue.withValues(alpha: 0.15),
                        width: 1,
                      ),
                    ),
                    child: Icon(
                      Icons.close_rounded,
                      color: textBlue.withValues(alpha: 0.7),
                      size: 18,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),

          // ─── Search bar ───
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              height: 48,
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: inputColor,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: primaryBlue.withValues(alpha: 0.15),
                  width: 1,
                ),
              ),
              child: Row(
                children: [
                  Icon(
                    Icons.search_rounded,
                    color: textBlue.withValues(alpha: 0.5),
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _searchController,
                      onChanged: (value) {
                        setState(() {
                          _searchQuery = value;
                        });
                      },
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                      ),
                      decoration: InputDecoration(
                        hintText: 'Search fish species...',
                        hintStyle: TextStyle(
                          color: textBlue.withValues(alpha: 0.4),
                          fontSize: 14,
                        ),
                        border: InputBorder.none,
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                          vertical: 10,
                        ),
                      ),
                    ),
                  ),
                  if (_searchQuery.isNotEmpty)
                    GestureDetector(
                      onTap: () {
                        _searchController.clear();
                        setState(() {
                          _searchQuery = '';
                        });
                      },
                      child: Icon(
                        Icons.clear_rounded,
                        color: textBlue.withValues(alpha: 0.5),
                        size: 18,
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 8),

          // Result count
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 6),
            child: Row(
              children: [
                Text(
                  '${_filteredFish.length} species available',
                  style: TextStyle(
                    color: textBlue.withValues(alpha: 0.5),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),

          // ─── Fish list ───
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              padding: const EdgeInsets.fromLTRB(20, 4, 20, 24),
              itemCount: _filteredFish.length,
              itemBuilder: (context, index) {
                final fish = _filteredFish[index];
                final bool isSelected = widget.selectedFish?.name == fish.name;
                final bool isOtherSelected =
                    widget.otherFish?.name == fish.name;

                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: GestureDetector(
                    onTap: isOtherSelected
                        ? null
                        : () => Navigator.pop(context, fish),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected
                            ? primaryBlue.withValues(alpha: 0.12)
                            : cardColor,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: isSelected
                              ? primaryBlue.withValues(alpha: 0.4)
                              : isOtherSelected
                                  ? textBlue.withValues(alpha: 0.15)
                                  : primaryBlue.withValues(alpha: 0.08),
                          width: isSelected ? 1.5 : 1,
                        ),
                      ),
                      child: Opacity(
                        opacity: isOtherSelected ? 0.4 : 1.0,
                        child: Row(
                          children: [
                            // Fish icon
                            Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: fish.accentColor
                                    .withValues(alpha: 0.15),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(
                                  color: fish.accentColor
                                      .withValues(alpha: 0.25),
                                  width: 1,
                                ),
                              ),
                              child: Icon(
                                fish.icon,
                                color: fish.accentColor,
                                size: 24,
                              ),
                            ),
                            const SizedBox(width: 12),
                            // Fish info
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    fish.name,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: 15,
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    fish.scientificName,
                                    style: TextStyle(
                                      color: textBlue.withValues(alpha: 0.7),
                                      fontSize: 12,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  const SizedBox(height: 6),
                                  // Quick info chips
                                  Row(
                                    children: [
                                      _buildInfoChip(
                                        fish.temperament,
                                        fish.temperament == 'Aggressive'
                                            ? const Color(0xFFEF5350)
                                            : fish.temperament ==
                                                    'Semi-aggressive'
                                                ? const Color(0xFFFF9800)
                                                : const Color(0xFF66BB6A),
                                      ),
                                      const SizedBox(width: 6),
                                      _buildInfoChip(
                                        fish.size,
                                        textBlue,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                            // Selection indicator
                            if (isSelected)
                              Container(
                                width: 26,
                                height: 26,
                                decoration: const BoxDecoration(
                                  color: primaryBlue,
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.check_rounded,
                                  color: Colors.white,
                                  size: 16,
                                ),
                              )
                            else if (isOtherSelected)
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 3,
                                ),
                                decoration: BoxDecoration(
                                  color: textBlue.withValues(alpha: 0.1),
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Text(
                                  'In use',
                                  style: TextStyle(
                                    color: textBlue.withValues(alpha: 0.5),
                                    fontSize: 10,
                                    fontWeight: FontWeight.w500,
                                  ),
                                ),
                              )
                            else
                              Icon(
                                Icons.add_circle_outline_rounded,
                                color: textBlue.withValues(alpha: 0.4),
                                size: 22,
                              ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoChip(String text, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 10,
          fontWeight: FontWeight.w600,
        ),
      ),
    );
  }
}
