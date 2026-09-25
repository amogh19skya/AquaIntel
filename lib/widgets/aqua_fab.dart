import 'package:flutter/material.dart';

/// Reusable AquaIntel floating action button.
///
/// A 56×56 circular button with the AquaIntel blue gradient,
/// a white "+" icon, and a soft blue glow/shadow.
///
/// Usage:
/// ```dart
/// AquaFab(
///   onPressed: () {
///     // Navigate to Add Aquarium screen
///   },
/// )
/// ```
class AquaFab extends StatelessWidget {
  /// Callback when the button is pressed.
  final VoidCallback onPressed;

  const AquaFab({super.key, required this.onPressed});

  // ─── AquaIntel colour tokens ───
  static const Color _primaryBlue = Color(0xFF29A8DF);
  static const Color _gradientEnd = Color(0xFF1B8FC4);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 56,
        height: 56,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [_primaryBlue, _gradientEnd],
          ),
          boxShadow: [
            BoxShadow(
              color: _primaryBlue.withValues(alpha: 0.4),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}
