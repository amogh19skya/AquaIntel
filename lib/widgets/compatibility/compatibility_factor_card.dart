import 'package:flutter/material.dart';

/// Single responsibility widget for rendering a compatibility factor item.
class CompatibilityFactorCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String status;
  final String message;
  final Color cardColor;
  final Color textBlue;

  const CompatibilityFactorCard({
    super.key,
    required this.icon,
    required this.title,
    required this.status,
    required this.message,
    required this.cardColor,
    required this.textBlue,
  });

  Color _statusColor(String status) {
    switch (status.toLowerCase()) {
      case 'compatible':
        return const Color(0xFF66BB6A);
      case 'caution':
        return const Color(0xFFFFB74D);
      case 'incompatible':
        return const Color(0xFFEF5350);
      default:
        return textBlue;
    }
  }

  IconData _statusIcon(String status) {
    switch (status.toLowerCase()) {
      case 'compatible':
        return Icons.check_circle_outline_rounded;
      case 'caution':
        return Icons.warning_amber_rounded;
      case 'incompatible':
        return Icons.cancel_outlined;
      default:
        return Icons.info_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final statusColor = _statusColor(status);

    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: statusColor.withValues(alpha: 0.3),
          width: 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: textBlue, size: 20),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: statusColor.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: statusColor.withValues(alpha: 0.4),
                    width: 1,
                  ),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(_statusIcon(status), color: statusColor, size: 14),
                    const SizedBox(width: 4),
                    Text(
                      status,
                      style: TextStyle(
                        color: statusColor,
                        fontSize: 12,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          if (message.isNotEmpty) ...[
            const SizedBox(height: 10),
            Text(
              message,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.8),
                fontSize: 13,
                height: 1.4,
              ),
            ),
          ],
        ],
      ),
    );
  }
}
