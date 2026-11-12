import 'package:flutter/material.dart';
import '../models/aquarium_model.dart';
import '../screens/aquarium/aquarium_details_screen.dart';
import '../theme/app_theme.dart';
import 'aquarium/aquarium_image_view.dart';

/// Reusable card widget that displays a single [AquariumModel] on the Dashboard.
///
/// Features a prominent top photograph banner (or an aquatic placeholder if
/// no photo has been uploaded yet), followed by the aquarium name, type badge,
/// dimensions, volume and description.
class AquariumCard extends StatelessWidget {
  final AquariumModel aquarium;

  const AquariumCard({super.key, required this.aquarium});

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
        clipBehavior: Clip.antiAlias,
        decoration: BoxDecoration(
          color: AquaColors.card,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AquaColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.18),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ─── Top Aquarium Image / Placeholder ───
            _buildAquariumBanner(),

            // ─── Card Content ───
            Padding(
              padding: const EdgeInsets.all(18),
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
                          color: AquaColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(
                            color: AquaColors.accent.withValues(alpha: 0.2),
                          ),
                        ),
                        child: Icon(
                          Icons.water,
                          color: AquaColors.accent,
                          size: 20,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              aquarium.name,
                              style: TextStyle(
                                color: AquaColors.textPrimary,
                                fontSize: 17,
                                fontWeight: FontWeight.bold,
                              ),
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                            ),
                            const SizedBox(height: 4),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: AquaColors.accent.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(
                                  color:
                                      AquaColors.accent.withValues(alpha: 0.2),
                                ),
                              ),
                              child: Text(
                                aquarium.type.toUpperCase(),
                                style: TextStyle(
                                  color: AquaColors.accent,
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
                        color: AquaColors.textMuted,
                        size: 22,
                      ),
                    ],
                  ),

                  const SizedBox(height: 14),

                  // ─── Divider ───
                  Divider(color: AquaColors.border, height: 1),

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
          ],
        ),
      ),
    );
  }

  /// Builds the top image banner or an attractive fallback placeholder.
  Widget _buildAquariumBanner() {
    final hasImage =
        aquarium.imageUrl != null && aquarium.imageUrl!.trim().isNotEmpty;

    return SizedBox(
      height: 155,
      width: double.infinity,
      child: Stack(
        fit: StackFit.expand,
        children: [
          if (hasImage)
            AquariumImageView(
              imageUrl: aquarium.imageUrl!,
              fit: BoxFit.cover,
              placeholder: _buildPlaceholder(isLoading: true),
              errorBuilder: (context, error, stackTrace) {
                return _buildPlaceholder(isLoading: false);
              },
            )
          else
            _buildPlaceholder(isLoading: false),

          // Subtle gradient overlay at the bottom of the image for seamless transition
          Positioned(
            left: 0,
            right: 0,
            bottom: 0,
            height: 32,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.transparent,
                    AquaColors.card.withValues(alpha: 0.7),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  /// Attractive default placeholder when no image is available or while loading.
  Widget _buildPlaceholder({required bool isLoading}) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AquaColors.cardElevated,
            AquaColors.bgSecondary,
          ],
        ),
      ),
      child: Center(
        child: isLoading
            ? const SizedBox(
                width: 28,
                height: 28,
                child: CircularProgressIndicator(
                  color: AquaColors.accent,
                  strokeWidth: 2.5,
                ),
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: AquaColors.accent.withValues(alpha: 0.12),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AquaColors.accent.withValues(alpha: 0.25),
                      ),
                    ),
                    child: Icon(
                      Icons.water_drop_outlined,
                      color: AquaColors.accent,
                      size: 24,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${aquarium.type} Tank',
                    style: TextStyle(
                      color: AquaColors.textMuted,
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.3,
                    ),
                  ),
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
            color: AquaColors.textSecondary,
            fontSize: 13,
            fontWeight: FontWeight.w400,
          ),
        ),
        Flexible(
          child: Text(
            value,
            style: TextStyle(
              color: AquaColors.textPrimary,
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
