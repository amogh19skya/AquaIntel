import 'package:flutter/material.dart';
import 'aqua_fab.dart';

/// Reusable AquaIntel bottom navigation bar **with** the centered FAB.
///
/// The bar renders a single row containing four nav items
/// (Maintenance, Dashboard, Library, Settings) with an [AquaFab]
/// centered between Dashboard and Library.
///
/// ```
/// Maintenance │ Dashboard │  ⊕  │ Library │ Settings
/// ```
///
/// [currentIndex] — the currently selected tab (0‑3).
/// [onItemSelected] — called when a nav item is tapped.
/// [onFabPressed] — called when the center FAB is tapped.
///
/// This widget contains **no** business logic or direct navigation.
class AquaBottomNav extends StatelessWidget {
  /// Index of the currently active tab (0–3).
  final int currentIndex;

  /// Callback when a navigation item is tapped.
  final ValueChanged<int> onItemSelected;

  /// Callback when the center FAB is tapped.
  final VoidCallback onFabPressed;

  const AquaBottomNav({
    super.key,
    required this.currentIndex,
    required this.onItemSelected,
    required this.onFabPressed,
  });

  // ─── AquaIntel colour tokens (matching HomeScreen) ───
  static const Color _cardColor = Color(0xFF1C4667);
  static const Color _primaryBlue = Color(0xFF29A8DF);
  static const Color _textBlue = Color(0xFF70A9CC);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 70,
      decoration: BoxDecoration(
        color: _cardColor,
        borderRadius: const BorderRadius.only(
          topLeft: Radius.circular(24),
          topRight: Radius.circular(24),
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.3),
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
          _buildNavItem(Icons.menu_book_outlined, 'Library', 2),
          _buildNavItem(Icons.settings_outlined, 'Settings', 3),
        ],
      ),
    );
  }

  /// Builds a single navigation item (icon + label).
  Widget _buildNavItem(IconData icon, String label, int index) {
    final bool isSelected = currentIndex == index;
    return GestureDetector(
      onTap: () => onItemSelected(index),
      behavior: HitTestBehavior.opaque,
      child: SizedBox(
        width: 65,
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: isSelected
                  ? _primaryBlue
                  : _textBlue.withValues(alpha: 0.5),
              size: 24,
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected
                    ? _primaryBlue
                    : _textBlue.withValues(alpha: 0.5),
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
