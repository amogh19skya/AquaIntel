import 'package:flutter/material.dart';
import '../../models/fish.dart';

/// Selection card component for displaying a selected fish or empty placeholder (SRP).
class FishSelectionCard extends StatelessWidget {
  final String label;
  final Fish? fish;
  final VoidCallback onTap;
  final VoidCallback onClear;
  final Color cardColor;
  final Color inputColor;
  final Color primaryBlue;
  final Color textBlue;

  const FishSelectionCard({
    super.key,
    required this.label,
    required this.fish,
    required this.onTap,
    required this.onClear,
    required this.cardColor,
    required this.inputColor,
    required this.primaryBlue,
    required this.textBlue,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(
            color: fish != null
                ? primaryBlue.withValues(alpha: 0.5)
                : Colors.white.withValues(alpha: 0.08),
            width: 1.5,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.2),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Material(
          color: Colors.transparent,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(20),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      color: textBlue,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(height: 12),
                  if (fish == null) ...[
                    Container(
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        color: inputColor,
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: primaryBlue.withValues(alpha: 0.3),
                          width: 1,
                        ),
                      ),
                      child: Icon(
                        Icons.add_rounded,
                        color: primaryBlue,
                        size: 30,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Text(
                      'Select Fish',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.6),
                        fontSize: 13,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ] else ...[
                    Stack(
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          width: 60,
                          height: 60,
                          decoration: BoxDecoration(
                            color: fish!.accentColor.withValues(alpha: 0.15),
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: fish!.accentColor.withValues(alpha: 0.5),
                              width: 2,
                            ),
                          ),
                          child: Icon(
                            fish!.icon,
                            color: fish!.accentColor,
                            size: 32,
                          ),
                        ),
                        GestureDetector(
                          onTap: onClear,
                          child: Container(
                            padding: const EdgeInsets.all(2),
                            decoration: const BoxDecoration(
                              color: Color(0xFFEF5350),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.close,
                              color: Colors.white,
                              size: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      fish!.name,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      fish!.scientificName,
                      textAlign: TextAlign.center,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        color: textBlue.withValues(alpha: 0.8),
                        fontSize: 11,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ],
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
