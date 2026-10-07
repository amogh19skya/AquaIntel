import 'package:flutter/material.dart';

/// Reusable Compatibility Checker header widget.
///
/// Extracted from [CompatibilityCheckerScreen] so it can be used
/// independently and kept in the `lib/widgets/` directory.
///
/// Preserves the exact visual design (title, subtitle, icon, spacing,
/// colours, typography, gradient background) from the original screen.
class CompatibilityHeader extends StatelessWidget {
  // ─── AquaIntel colour tokens (matching the Compatibility Checker screen) ──
  static const Color _primaryBlue = Color(0xFF29A8DF);
  static const Color _textBlue = Color(0xFF70A9CC);

  const CompatibilityHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // ─── Title text ──────────────────────────────────────────────
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

              // ─── Aquarium icon badge ─────────────────────────────────────
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [
                      _primaryBlue.withValues(alpha: 0.2),
                      _primaryBlue.withValues(alpha: 0.05),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: _primaryBlue.withValues(alpha: 0.15),
                    width: 1,
                  ),
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.water,
                      color: _primaryBlue.withValues(alpha: 0.3),
                      size: 40,
                    ),
                    const Icon(
                      Icons.set_meal_rounded,
                      color: _primaryBlue,
                      size: 28,
                    ),
                  ],
                ),
              ),
            ],
          ),

          // ─── Subtitle ───────────────────────────────────────────────────
          const SizedBox(height: 8),
          Text(
            'Find out if two fish can live together in the same aquarium.',
            style: TextStyle(
              color: _textBlue.withValues(alpha: 0.85),
              fontSize: 14,
              fontWeight: FontWeight.w400,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
