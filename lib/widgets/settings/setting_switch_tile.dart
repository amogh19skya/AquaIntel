import 'package:flutter/material.dart';

/// Single responsibility widget for a settings switch list row (SRP).
class SettingSwitchTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final bool value;
  final bool enabled;
  final ValueChanged<bool>? onChanged;
  final Color surfaceColor;
  final Color primaryBlue;
  final Color textSecondary;

  const SettingSwitchTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.value,
    this.enabled = true,
    required this.onChanged,
    required this.surfaceColor,
    required this.primaryBlue,
    required this.textSecondary,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveTextColor = enabled ? Colors.white : Colors.white.withValues(alpha: 0.38);
    final effectiveSubtitleColor = enabled ? textSecondary : textSecondary.withValues(alpha: 0.38);
    final effectiveIconColor = enabled ? primaryBlue : primaryBlue.withValues(alpha: 0.38);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              color: effectiveIconColor.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: effectiveIconColor,
              size: 22,
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
                    color: effectiveTextColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    color: effectiveSubtitleColor,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Switch(
            value: value,
            onChanged: enabled ? onChanged : null,
            activeThumbColor: Colors.white,
            activeTrackColor: primaryBlue,
            inactiveThumbColor: Colors.grey.shade400,
            inactiveTrackColor: surfaceColor,
          ),
        ],
      ),
    );
  }
}
