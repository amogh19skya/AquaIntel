import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fish.dart';
import '../models/compatibility_result.dart';
import 'compatibility_rule_engine.dart';

/// Interface for compatibility check service (DIP).
abstract class ICompatibilityService {
  Future<CompatibilityResult> checkCompatibility(Fish fishA, Fish fishB);
}

/// Compatibility service backed by Cloud Firestore overrides and rule engine.
class CompatibilityService implements ICompatibilityService {
  final FirebaseFirestore? _customFirestore;
  final CompatibilityRuleEngine _ruleEngine;

  CompatibilityService({
    FirebaseFirestore? firestore,
    CompatibilityRuleEngine? ruleEngine,
  })  : _customFirestore = firestore,
        _ruleEngine = ruleEngine ?? CompatibilityRuleEngine();

  FirebaseFirestore get _firestore =>
      _customFirestore ?? FirebaseFirestore.instance;

  static const String _sCompatible = 'Compatible';

  @override
  Future<CompatibilityResult> checkCompatibility(
    Fish fishA,
    Fish fishB,
  ) async {
    if (fishA.id == fishB.id) {
      throw ArgumentError('Cannot check compatibility of a fish species with itself.');
    }

    debugPrint('[CompatibilityService] Checking: ${fishA.id} ↔ ${fishB.id}');

    // 1. Check for Firestore override.
    final override = await _loadOverride(fishA.id, fishB.id);
    if (override != null) {
      debugPrint('[CompatibilityService] Using Firestore override.');
      return override;
    }

    // 2. Delegate calculation to pure rule engine (SRP).
    debugPrint('[CompatibilityService] No override – using rule engine.');
    return _ruleEngine.evaluate(fishA, fishB);
  }

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
      debugPrint('[CompatibilityService] Firestore error loading override '
          '"$pairId": ${e.code} – ${e.message}');
      throw Exception('Database error loading compatibility: ${e.message ?? e.code}');
    } catch (e) {
      debugPrint('[CompatibilityService] Unexpected error loading override: $e');
      throw Exception('Could not connect to compatibility database. Please try again.');
    }
  }

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

  String _pairId(String idA, String idB) {
    final sorted = [idA, idB]..sort();
    return '${sorted[0]}_${sorted[1]}';
  }
}
