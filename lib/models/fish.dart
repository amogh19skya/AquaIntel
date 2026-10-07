import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

/// Represents a fish species stored in the Firestore `fish` collection.
///
/// Each document lives at `fish/{fishId}` in Cloud Firestore.
/// All Firestore fields are mapped to typed Dart fields with safe
/// null-fallback defaults so a missing or malformed field never crashes
/// the app.
class Fish {
  /// Firestore document ID — used as the stable identifier (e.g. "guppy").
  final String id;

  /// Display name shown in the UI (e.g. "Guppy").
  final String name;

  /// Latin / scientific name shown as the subtitle (e.g. "Poecilia reticulata").
  final String scientificName;

  /// Behavioural category: "Peaceful", "Semi-aggressive", or "Aggressive".
  final String temperament;

  /// Minimum body length in centimetres.
  final double minSizeCm;

  /// Maximum body length in centimetres.
  final double maxSizeCm;

  /// Minimum suitable water temperature in °C.
  final double minTemperature;

  /// Maximum suitable water temperature in °C.
  final double maxTemperature;

  /// Minimum suitable pH value.
  final double minPh;

  /// Maximum suitable pH value.
  final double maxPh;

  /// Minimum recommended aquarium volume in litres.
  final double minimumTankLitres;

  // ─── UI helpers (NOT stored in Firestore) ─────────────────────────────────

  /// Icon used in the fish selection card/list.
  ///
  /// Derived locally from the fish [id]; not stored in Firestore.
  IconData get icon => _iconForId(id);

  /// Accent colour used in the fish card.
  ///
  /// Derived locally from the fish [id]; not stored in Firestore.
  Color get accentColor => _colorForId(id);

  /// Human-readable size range string, e.g. "3–6 cm".
  String get sizeRange =>
      '${minSizeCm.toStringAsFixed(0)}–${maxSizeCm.toStringAsFixed(0)} cm';

  /// Human-readable temperature range string, e.g. "22–28°C".
  String get temperatureRange =>
      '${minTemperature.toStringAsFixed(0)}–${maxTemperature.toStringAsFixed(0)}°C';

  /// Human-readable pH range string, e.g. "6.8–7.8".
  String get phRange =>
      '${minPh.toStringAsFixed(1)}–${maxPh.toStringAsFixed(1)}';

  /// Human-readable tank size string, e.g. "40L+".
  String get tankSizeLabel =>
      '${minimumTankLitres.toStringAsFixed(0)}L+';

  const Fish({
    required this.id,
    required this.name,
    required this.scientificName,
    required this.temperament,
    required this.minSizeCm,
    required this.maxSizeCm,
    required this.minTemperature,
    required this.maxTemperature,
    required this.minPh,
    required this.maxPh,
    required this.minimumTankLitres,
  });

  // ─── Firestore factory ─────────────────────────────────────────────────────

  /// Creates a [Fish] from a Firestore [DocumentSnapshot].
  ///
  /// Handles missing / null / wrong-typed fields gracefully by using
  /// sensible defaults so a bad Firestore document never crashes the app.
  factory Fish.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Fish(
      id: doc.id,
      name: data['name'] as String? ?? doc.id,
      scientificName: data['scientificName'] as String? ?? '',
      temperament: data['temperament'] as String? ?? 'Peaceful',
      minSizeCm: (data['minSizeCm'] as num?)?.toDouble() ?? 0.0,
      maxSizeCm: (data['maxSizeCm'] as num?)?.toDouble() ?? 0.0,
      minTemperature: (data['minTemperature'] as num?)?.toDouble() ?? 22.0,
      maxTemperature: (data['maxTemperature'] as num?)?.toDouble() ?? 28.0,
      minPh: (data['minPh'] as num?)?.toDouble() ?? 6.5,
      maxPh: (data['maxPh'] as num?)?.toDouble() ?? 7.5,
      minimumTankLitres:
          (data['minimumTankLitres'] as num?)?.toDouble() ?? 40.0,
    );
  }

  // ─── UI helpers ────────────────────────────────────────────────────────────

  /// Maps a fish document ID to a Material icon.
  static IconData _iconForId(String id) {
    const map = <String, IconData>{
      'betta': Icons.waves,
      'neon_tetra': Icons.bubble_chart,
      'guppy': Icons.water,
      'goldfish': Icons.spa,
      'angelfish': Icons.change_history,
      'corydoras': Icons.circle,
      'oscar': Icons.shield,
      'platy': Icons.favorite,
    };
    return map[id] ?? Icons.set_meal_rounded;
  }

  /// Maps a fish document ID to an accent [Color].
  static Color _colorForId(String id) {
    const map = <String, Color>{
      'betta': Color(0xFFE53935),
      'neon_tetra': Color(0xFF29B6F6),
      'guppy': Color(0xFF66BB6A),
      'goldfish': Color(0xFFFF9800),
      'angelfish': Color(0xFFAB47BC),
      'corydoras': Color(0xFF8D6E63),
      'oscar': Color(0xFFEF5350),
      'platy': Color(0xFFEC407A),
    };
    return map[id] ?? const Color(0xFF29A8DF);
  }

  @override
  String toString() => 'Fish(id: $id, name: $name)';

  @override
  bool operator ==(Object other) => other is Fish && other.id == id;

  @override
  int get hashCode => id.hashCode;
}
