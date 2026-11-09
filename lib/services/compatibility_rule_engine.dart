import '../models/fish.dart';
import '../models/compatibility_result.dart';

/// Pure domain rule engine for computing fish compatibility (Single Responsibility Principle).
/// 

/// Contains zero external database dependencies, enabling independent unit testing
/// and fast rule execution.
class CompatibilityRuleEngine {
  static const String sCompatible = 'Compatible';
  static const String sCaution = 'Caution';
  static const String sIncompatible = 'Incompatible';

  /// Evaluates two fish species against biological and parameter rules.
  CompatibilityResult evaluate(Fish a, Fish b) {
    final tempResult = checkTemperature(a, b);
    final phResult = checkPh(a, b);
    final temperamentResult = checkTemperament(a, b);
    final tankResult = checkTankSize(a, b);

    final score = computeScore(
      tempPoints: tempResult.points,
      phPoints: phResult.points,
      temperamentPoints: temperamentResult.points,
      tankPoints: tankResult.points,
    );

    return CompatibilityResult(
      score: score,
      status: overallStatus(score),
      temperatureStatus: tempResult.status,
      temperatureMessage: tempResult.message,
      phStatus: phResult.status,
      phMessage: phResult.message,
      temperamentStatus: temperamentResult.status,
      temperamentMessage: temperamentResult.message,
      tankSizeStatus: tankResult.status,
      tankSizeMessage: tankResult.message,
      recommendation: recommendation(score, a, b, temperamentResult.status),
    );
  }

  FactorResult checkTemperature(Fish a, Fish b) {
    final overlapMin = a.minTemperature > b.minTemperature
        ? a.minTemperature
        : b.minTemperature;
    final overlapMax = a.maxTemperature < b.maxTemperature
        ? a.maxTemperature
        : b.maxTemperature;

    if (overlapMax - overlapMin >= 2) {
      return FactorResult(
        status: sCompatible,
        message: 'Both species share a comfortable temperature range '
            '(${overlapMin.toStringAsFixed(0)}–${overlapMax.toStringAsFixed(0)}°C overlap).',
        points: 25,
      );
    } else if (overlapMax > overlapMin) {
      return FactorResult(
        status: sCaution,
        message: 'Temperature ranges barely overlap. Careful temperature '
            'management is required.',
        points: 13,
      );
    } else {
      return FactorResult(
        status: sIncompatible,
        message: 'These species prefer incompatible temperature ranges. '
            '${a.name} needs ${a.temperatureRange}, ${b.name} needs ${b.temperatureRange}.',
        points: 0,
      );
    }
  }

  FactorResult checkPh(Fish a, Fish b) {
    final overlapMin = a.minPh > b.minPh ? a.minPh : b.minPh;
    final overlapMax = a.maxPh < b.maxPh ? a.maxPh : b.maxPh;

    if (overlapMax - overlapMin >= 0.4) {
      return FactorResult(
        status: sCompatible,
        message: 'pH ranges overlap well '
            '(${overlapMin.toStringAsFixed(1)}–${overlapMax.toStringAsFixed(1)} shared).',
        points: 25,
      );
    } else if (overlapMax > overlapMin) {
      return FactorResult(
        status: sCaution,
        message: 'pH ranges barely overlap. Precise pH control is needed.',
        points: 13,
      );
    } else {
      return FactorResult(
        status: sIncompatible,
        message: 'pH requirements are incompatible. '
            '${a.name} needs ${a.phRange}, ${b.name} needs ${b.phRange}.',
        points: 0,
      );
    }
  }

  FactorResult checkTemperament(Fish a, Fish b) {
    final tA = a.temperament.toLowerCase();
    final tB = b.temperament.toLowerCase();

    if (tA == 'peaceful' && tB == 'peaceful') {
      return FactorResult(
        status: sCompatible,
        message: 'Both species are peaceful and unlikely to harass each other.',
        points: 35,
      );
    }

    if ((tA == 'peaceful' && tB == 'semi-aggressive') ||
        (tA == 'semi-aggressive' && tB == 'peaceful')) {
      return FactorResult(
        status: sCaution,
        message: 'One species is semi-aggressive. Provide plenty of hiding '
            'spots and monitor for fin-nipping or territorial behaviour.',
        points: 20,
      );
    }

    if (tA == 'semi-aggressive' && tB == 'semi-aggressive') {
      return FactorResult(
        status: sCaution,
        message: 'Both species are semi-aggressive. Keep in a larger aquarium '
            'with adequate territory and visual barriers.',
        points: 15,
      );
    }

    if (tA == 'aggressive' || tB == 'aggressive') {
      final aggressor = tA == 'aggressive' ? a.name : b.name;
      return FactorResult(
        status: sIncompatible,
        message: '$aggressor is aggressive and may attack or predate the '
            'other species. Housing them together is not recommended.',
        points: 0,
      );
    }

    return FactorResult(
      status: sCaution,
      message: 'Temperament mismatch detected. Monitor behaviour closely.',
      points: 15,
    );
  }

  FactorResult checkTankSize(Fish a, Fish b) {
    final required = a.minimumTankLitres > b.minimumTankLitres
        ? a.minimumTankLitres
        : b.minimumTankLitres;

    final smaller = a.minimumTankLitres < b.minimumTankLitres ? a : b;
    final ratio = required / smaller.minimumTankLitres;

    if (ratio <= 3.0) {
      return FactorResult(
        status: sCompatible,
        message: 'Both species can share a ${required.toStringAsFixed(0)}L+ '
            'aquarium comfortably.',
        points: 15,
      );
    } else if (ratio <= 6.0) {
      return FactorResult(
        status: sCaution,
        message: 'Tank size requirements differ significantly. A '
            '${required.toStringAsFixed(0)}L+ aquarium is needed for the '
            'larger species, which may dwarf the smaller one.',
        points: 8,
      );
    } else {
      return FactorResult(
        status: sIncompatible,
        message: 'These species have vastly different space requirements '
            '(${a.tankSizeLabel} vs ${b.tankSizeLabel}). '
            'They are not suitable tankmates.',
        points: 0,
      );
    }
  }

  int computeScore({
    required int tempPoints,
    required int phPoints,
    required int temperamentPoints,
    required int tankPoints,
  }) {
    final raw = tempPoints + phPoints + temperamentPoints + tankPoints;
    return raw.clamp(0, 100);
  }

  String overallStatus(int score) {
    if (score >= 80) return 'Highly Compatible';
    if (score >= 60) return 'Moderately Compatible';
    if (score >= 40) return 'Low Compatibility';
    return 'Not Compatible';
  }

  String recommendation(
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
      final extra = temperamentStatus == sCaution
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
}

/// Helper result structure for individual compatibility factors.
class FactorResult {
  final String status;
  final String message;
  final int points;

  const FactorResult({
    required this.status,
    required this.message,
    required this.points,
  });
}
