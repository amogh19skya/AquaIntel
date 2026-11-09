import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Reusable AquaIntel floating action button.
class AquaFab extends StatelessWidget {
  final VoidCallback onPressed;

  const AquaFab({super.key, required this.onPressed});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        width: 52,
        height: 52,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AquaColors.accent,
          boxShadow: [
            BoxShadow(
              color: AquaColors.accent.withValues(alpha: 0.35),
              blurRadius: 14,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        child: const Icon(
          Icons.add,
          color: Colors.white,
          size: 26,
        ),
      ),
    );
  }
}
