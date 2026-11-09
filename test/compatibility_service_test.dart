import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/models/fish.dart';
import 'package:aquaintel/services/compatibility_service.dart';
import 'package:aquaintel/services/compatibility_rule_engine.dart';

void main() {
  group('CompatibilityService validation tests', () {
    const guppy = Fish(
      id: 'guppy',
      name: 'Guppy',
      scientificName: 'Poecilia reticulata',
      temperament: 'Peaceful',
      minSizeCm: 3.0,
      maxSizeCm: 6.0,
      minTemperature: 22.0,
      maxTemperature: 28.0,
      minPh: 7.0,
      maxPh: 8.0,
      minimumTankLitres: 40.0,
    );

    test('Throws ArgumentError when checking identical fish species', () async {
      final service = CompatibilityService(ruleEngine: CompatibilityRuleEngine());
      expect(
        () => service.checkCompatibility(guppy, guppy),
        throwsA(isA<ArgumentError>()),
      );
    });

    test('Pair ID sorting logic produces consistent keys regardless of order', () {
      final sortedA = ['guppy', 'neon_tetra']..sort();
      final sortedB = ['neon_tetra', 'guppy']..sort();

      final pairIdA = '${sortedA[0]}_${sortedA[1]}';
      final pairIdB = '${sortedB[0]}_${sortedB[1]}';

      expect(pairIdA, equals('guppy_neon_tetra'));
      expect(pairIdB, equals('guppy_neon_tetra'));
      expect(pairIdA, equals(pairIdB));
    });
  });
}
