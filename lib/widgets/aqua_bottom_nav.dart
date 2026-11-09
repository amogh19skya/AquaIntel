import 'package:flutter/material.dart';
import 'aqua_fab.dart';
import '../theme/app_theme.dart';

/// Reusable AquaIntel bottom navigation bar with the centered FAB.
///
/// Destinations: Maintenance | Dashboard | ⊕ | Library | Settings
class AquaBottomNav extends StatelessWidget {
  final int currentIndex;
  final ValueChanged<int> onItemSelected;
  final VoidCallback onFabPressed;

  const AquaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onFabPressed,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 72,
      decoration: BoxDecoration(
        color: AquaColors.bgSecondary,
        border: const Border(
          top: BorderSide(color: AquaColors.border, width: 1),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.4),
            blurRadius: 20,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.build_outlined, 'Maintenance', 0),
          _buildNavItem(Icons.dashboard_outlined, 'Dashboard', 1),
          // ── Center FAB ──
          AquaFab(onPressed: onFabPressed),
          _buildNavItem(Icons.people_outline, 'Community', 2),
          _buildNavItem(Icons.settings_outlined, 'Settings', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 64,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: isSelected
                    ? AquaColors.accent.withValues(alpha: 0.12)
                    : Colors.transparent,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: isSelected ? AquaColors.accent : AquaColors.textMuted,
                size: 22,
              ),
            ),
            const SizedBox(height: 3),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? AquaColors.accent : AquaColors.textMuted,
                fontSize: 10,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
