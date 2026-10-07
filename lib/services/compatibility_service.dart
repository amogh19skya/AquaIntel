import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fish.dart';
import '../models/compatibility_result.dart';

/// Rule-based compatibility engine backed by Cloud Firestore.
///
/// ## Flow
/// ```
/// CompatibilityService.checkCompatibility(fishA, fishB)
///   1. Check Firestore `compatibility/{pairId}` for a specific override.
///   2. If override exists → use its score/status/messages directly.
///   3. Otherwise → run the built-in rule engine on fish parameters.
///   4. Return a [CompatibilityResult].
/// ```
///
/// ## Scoring weights (when no override exists)
/// | Factor        | Max points |
/// |---------------|-----------|
/// | Temperature   | 25        |
/// | pH            | 25        |
/// | Temperament   | 35        |
/// | Tank size     | 15        |
/// | **Total**     | **100**   |
class CompatibilityService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Internal status constants ────────────────────────────────────────────

  static const String _sCompatible = 'Compatible';
  static const String _sCaution = 'Caution';
  static const String _sIncompatible = 'Incompatible';

  // ─── Public API ───────────────────────────────────────────────────────────

  /// Checks compatibility between [fishA] and [fishB].
  ///
  /// First looks for a pair-specific Firestore override in the
  /// `compatibility` collection; falls back to the built-in rule engine.
  ///
  /// Throws a human-readable [Exception] on unrecoverable Firestore errors.
  Future<CompatibilityResult> checkCompatibility(
    Fish fishA,
    Fish fishB,
  ) async {
    debugPrint('[CompatibilityService] Checking: ${fishA.id} ↔ ${fishB.id}');

    // 1. Try to load a Firestore override for this pair.
    final override = await _loadOverride(fishA.id, fishB.id);
    if (override != null) {
      debugPrint('[CompatibilityService] Using Firestore override.');
      return override;
    }

    // 2. Fall back to the rule engine.
    debugPrint('[CompatibilityService] No override – using rule engine.');
    return _runRuleEngine(fishA, fishB);
  }

  // ─── Firestore override ───────────────────────────────────────────────────

  /// Looks for a document in `compatibility/{pairId}`.
  ///
  /// The pair ID is constructed alphabetically so `guppy_neon_tetra` and
  /// `neon_tetra_guppy` both resolve to the same document.
  Future<CompatibilityResult?> _loadOverride(
    String idA,
    String idB,
  ) async {
    final pairId = _pairId(idA, idB);
    try {
      final doc =
          await _firestore.collection('compatibility').doc(pairId).get();
      if (!doc.exists) {
        debugPrint('[CompatibilityService] No override for "$pairId".');
        return null;
      }
      return _overrideFromDoc(doc);
    } on FirebaseException catch (e) {
      // Non-fatal – fall back to the rule engine.
      debugPrint('[CompatibilityService] Firestore error loading override '
          '"$pairId": ${e.code} – ${e.message}');
      return null;
    } catch (e) {
      debugPrint('[CompatibilityService] Unexpected error loading override: $e');
      return null;
    }
  }

  /// Creates a [CompatibilityResult] from a Firestore override document.
  CompatibilityResult _overrideFromDoc(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>? ?? {};

    String str(dynamic map, String key, String fallback) {
      if (map is Map) return map[key] as String? ?? fallback;
      return fallback;
    }

    final temp = d['temperature'];
    final ph = d['ph'];
    final temperament = d['temperament'];
    final tankSize = d['tankSize'];

    return CompatibilityResult(
      score: (d['score'] as num?)?.toInt() ?? 50,
      status: d['status'] as String? ?? 'Moderate Compatibility',
      temperatureStatus: str(temp, 'status', _sCompatible),
      temperatureMessage: str(temp, 'message', ''),
      phStatus: str(ph, 'status', _sCompatible),
      phMessage: str(ph, 'message', ''),
      temperamentStatus: str(temperament, 'status', _sCompatible),
      temperamentMessage: str(temperament, 'message', ''),
      tankSizeStatus: str(tankSize, 'status', _sCompatible),
      tankSizeMessage: str(tankSize, 'message', ''),
      recommendation:
          d['recommendation'] as String? ?? 'No specific recommendation.',
    );
  }

  // ─── Rule engine ──────────────────────────────────────────────────────────

  /// Computes compatibility purely from [Fish] parameters.
  CompatibilityResult _runRuleEngine(Fish a, Fish b) {
    // ── Temperature ──────────────────────────────────────────────────────────
    final tempResult = _checkTemperature(a, b);

    // ── pH ────────────────────────────────────────────────────────────────────
    final phResult = _checkPh(a, b);

    // ── Temperament ───────────────────────────────────────────────────────────
    final temperamentResult = _checkTemperament(a, b);

    // ── Tank size ──────────────────────────────────────────────────────────────
    final tankResult = _checkTankSize(a, b);

    // ── Score ──────────────────────────────────────────────────────────────────
    final score = _computeScore(
      tempPoints: tempResult.points,
      phPoints: phResult.points,
      temperamentPoints: temperamentResult.points,
      tankPoints: tankResult.points,
    );

    return CompatibilityResult(
      score: score,
      status: _overallStatus(score),
      temperatureStatus: tempResult.status,
      temperatureMessage: tempResult.message,
      phStatus: phResult.status,
      phMessage: phResult.message,
      temperamentStatus: temperamentResult.status,
      temperamentMessage: temperamentResult.message,
      tankSizeStatus: tankResult.status,
      tankSizeMessage: tankResult.message,
      recommendation: _recommendation(score, a, b, temperamentResult.status),
    );
  }

  // ── Temperature check ──────────────────────────────────────────────────────

  _FactorResult _checkTemperature(Fish a, Fish b) {
    // Overlap = max(minA, minB) < min(maxA, maxB)
    final overlapMin = a.minTemperature > b.minTemperature
        ? a.minTemperature
        : b.minTemperature;
    final overlapMax = a.maxTemperature < b.maxTemperature
        ? a.maxTemperature
        : b.maxTemperature;

    if (overlapMax - overlapMin >= 2) {
      // Good overlap
      return _FactorResult(
        status: _sCompatible,
        message: 'Both species share a comfortable temperature range '
            '(${overlapMin.toStringAsFixed(0)}–'
            '${overlapMax.toStringAsFixed(0)}°C overlap).',
        points: 25,
      );
    } else if (overlapMax > overlapMin) {
      // Marginal overlap
      return _FactorResult(
        status: _sCaution,
        message: 'Temperature ranges barely overlap. Careful temperature '
            'management is required.',
        points: 13,
      );
    } else {
      // No overlap
      return _FactorResult(
        status: _sIncompatible,
        message: 'These species prefer incompatible temperature ranges. '
            '${a.name} needs ${a.temperatureRange}, '
            '${b.name} needs ${b.temperatureRange}.',
        points: 0,
      );
    }
  }

  // ── pH check ──────────────────────────────────────────────────────────────

  _FactorResult _checkPh(Fish a, Fish b) {
    final overlapMin = a.minPh > b.minPh ? a.minPh : b.minPh;
    final overlapMax = a.maxPh < b.maxPh ? a.maxPh : b.maxPh;

    if (overlapMax - overlapMin >= 0.4) {
      return _FactorResult(
        status: _sCompatible,
        message: 'pH ranges overlap well '
            '(${overlapMin.toStringAsFixed(1)}–'
            '${overlapMax.toStringAsFixed(1)} shared).',
        points: 25,
      );
    } else if (overlapMax > overlapMin) {
      return _FactorResult(
        status: _sCaution,
        message: 'pH ranges barely overlap. Precise pH control is needed.',
        points: 13,
      );
    } else {
      return _FactorResult(
        status: _sIncompatible,
        message: 'pH requirements are incompatible. '
            '${a.name} needs ${a.phRange}, ${b.name} needs ${b.phRange}.',
        points: 0,
      );
    }
  }

  // ── Temperament check ─────────────────────────────────────────────────────

  _FactorResult _checkTemperament(Fish a, Fish b) {
    final tA = a.temperament.toLowerCase();
    final tB = b.temperament.toLowerCase();

    if (tA == 'peaceful' && tB == 'peaceful') {
      return _FactorResult(
        status: _sCompatible,
        message: 'Both species are peaceful and unlikely to harass each other.',
        points: 35,
      );
    }

    if ((tA == 'peaceful' && tB == 'semi-aggressive') ||
        (tA == 'semi-aggressive' && tB == 'peaceful')) {
      return _FactorResult(
        status: _sCaution,
        message: 'One species is semi-aggressive. Provide plenty of hiding '
            'spots and monitor for fin-nipping or territorial behaviour.',
        points: 20,
      );
    }

    if (tA == 'semi-aggressive' && tB == 'semi-aggressive') {
      return _FactorResult(
        status: _sCaution,
        message: 'Both species are semi-aggressive. Keep in a larger aquarium '
            'with adequate territory and visual barriers.',
        points: 15,
      );
    }

    if (tA == 'aggressive' || tB == 'aggressive') {
      final aggressor = tA == 'aggressive' ? a.name : b.name;
      return _FactorResult(
        status: _sIncompatible,
        message: '$aggressor is aggressive and may attack or predate the '
            'other species. Housing them together is not recommended.',
        points: 0,
      );
    }

    // Fallback (shouldn't normally be reached)
    return _FactorResult(
      status: _sCaution,
      message: 'Temperament mismatch detected. Monitor behaviour closely.',
      points: 15,
    );
  }

  // ── Tank size check ───────────────────────────────────────────────────────

  _FactorResult _checkTankSize(Fish a, Fish b) {
    // Community tank should meet the higher of the two minimum requirements.
    final required = a.minimumTankLitres > b.minimumTankLitres
        ? a.minimumTankLitres
        : b.minimumTankLitres;

    // If the lower-requirement fish can comfortably live in the higher-
    // requirement tank, it's compatible.
    final smaller = a.minimumTankLitres < b.minimumTankLitres ? a : b;
    final ratio = required / smaller.minimumTankLitres;

    if (ratio <= 3.0) {
      return _FactorResult(
        status: _sCompatible,
        message: 'Both species can share a ${required.toStringAsFixed(0)}L+ '
            'aquarium comfortably.',
        points: 15,
      );
    } else if (ratio <= 6.0) {
      return _FactorResult(
        status: _sCaution,
        message: 'Tank size requirements differ significantly. A '
            '${required.toStringAsFixed(0)}L+ aquarium is needed for the '
            'larger species, which may dwarf the smaller one.',
        points: 8,
      );
    } else {
      return _FactorResult(
        status: _sIncompatible,
        message: 'These species have vastly different space requirements '
            '(${a.tankSizeLabel} vs ${b.tankSizeLabel}). '
            'They are not suitable tankmates.',
        points: 0,
      );
    }
  }

  // ─── Score & status helpers ───────────────────────────────────────────────

  int _computeScore({
    required int tempPoints,
    required int phPoints,
    required int temperamentPoints,
    required int tankPoints,
  }) {
    final raw = tempPoints + phPoints + temperamentPoints + tankPoints;
    // Clamp to [0, 100]
    return raw.clamp(0, 100);
  }

  String _overallStatus(int score) {
    if (score >= 80) return 'Highly Compatible';
    if (score >= 60) return 'Moderately Compatible';
    if (score >= 40) return 'Low Compatibility';
    return 'Not Compatible';
  }

  String _recommendation(
    int score,
    Fish a,
    Fish b,
    String temperamentStatus,
  ) {
    if (score >= 80) {
      return '${a.name} and ${b.name} are well-suited tankmates. '
          'They share similar water requirements and peaceful dispositions. '
          'Maintain stable water conditions and provide adequate space '
          'for both species to thrive.';
    }
    if (score >= 60) {
      final extra = temperamentStatus == _sCaution
          ? 'Monitor for aggressive behaviour and provide hiding spots. '
          : '';
      return '${a.name} and ${b.name} can coexist with care. '
          '${extra}Maintain water parameters within the shared '
          'acceptable range and observe their behaviour during introduction.';
    }
    if (score >= 40) {
      return 'Housing ${a.name} and ${b.name} together requires significant '
          'effort. Address the compatibility concerns identified above before '
          'attempting to keep them in the same aquarium. Consider alternatives.';
    }
    return '${a.name} and ${b.name} are generally not recommended as '
        'tankmates. The incompatibilities identified above are likely to '
        'cause stress, injury, or death. Choose a different species pairing.';
  }

  // ─── Pair ID helper ───────────────────────────────────────────────────────

  /// Returns a canonical pair ID so A_B and B_A both resolve the same document.
  String _pairId(String idA, String idB) {
    final sorted = [idA, idB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}

// ─── Internal helper class ────────────────────────────────────────────────────

class _FactorResult {
  final String status;
  final String message;
  final int points;

  const _FactorResult({
    required this.status,
    required this.message,
    required this.points,
  });
}
