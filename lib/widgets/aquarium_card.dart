import 'package:flutter/material.dart';
import '../models/aquarium_model.dart';
import '../screens/aquarium/aquarium_details_screen.dart';

/// Reusable card widget that displays a single [AquariumModel] on the Dashboard.
///
/// Tapping the card navigates to [AquariumDetailsScreen] where the user
/// can also edit or delete the aquarium.
class AquariumCard extends StatelessWidget {
  final AquariumModel aquarium;

  const AquariumCard({super.key, required this.aquarium});

  // AquaIntel colour tokens
  static const Color cardColor = Color(0xFF1C4667);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => AquariumDetailsScreen(aquarium: aquarium),
          ),
        );
      },
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
            // ─── Card Header ───
            Row(
              children: [
                Container(
                  width: 42,
                  height: 42,
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
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        aquarium.name,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 17,
                          fontWeight: FontWeight.bold,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 2),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 2),
                        decoration: BoxDecoration(
                          color: primaryBlue.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          aquarium.type.toUpperCase(),
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
                ),
                Icon(
                  Icons.chevron_right,
                  color: textBlue.withValues(alpha: 0.6),
                  size: 24,
                ),
              ],
            ),

            const SizedBox(height: 14),

            // ─── Divider ───
            Container(
              height: 1,
              color: primaryBlue.withValues(alpha: 0.1),
            ),

            const SizedBox(height: 12),

            // ─── Detail Rows ───
            _buildDetailRow(
              'Volume',
              '${aquarium.volumeLitres.toStringAsFixed(1)} L',
            ),
            const SizedBox(height: 8),
            _buildDetailRow(
              'Dimensions',
              '${aquarium.length} × ${aquarium.width} × ${aquarium.height} ${aquarium.unit}',
            ),
            if (aquarium.description.isNotEmpty) ...[
              const SizedBox(height: 8),
              _buildDetailRow('Description', aquarium.description),
            ],
          ],
        ),
      ),
    );
  }

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
        Flexible(
          child: Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 13,
              fontWeight: FontWeight.w600,
            ),
            textAlign: TextAlign.right,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }
}
