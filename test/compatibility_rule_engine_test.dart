import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/models/fish.dart';
import 'package:aquaintel/services/compatibility_rule_engine.dart';

void main() {
  group('CompatibilityRuleEngine tests', () {
    late CompatibilityRuleEngine engine;

    setUp(() {
      engine = CompatibilityRuleEngine();
    });

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

    const neonTetra = Fish(
      id: 'neon_tetra',
      name: 'Neon Tetra',
      scientificName: 'Paracheirodon innesi',
      temperament: 'Peaceful',
      minSizeCm: 2.5,
      maxSizeCm: 4.0,
      minTemperature: 22.0,
      maxTemperature: 26.0,
      minPh: 6.0,
      maxPh: 7.0,
      minimumTankLitres: 40.0,
    );

    const betta = Fish(
      id: 'betta',
      name: 'Betta',
      scientificName: 'Betta splendens',
      temperament: 'Aggressive',
      minSizeCm: 5.0,
      maxSizeCm: 7.0,
      minTemperature: 24.0,
      maxTemperature: 28.0,
      minPh: 6.5,
      maxPh: 7.5,
      minimumTankLitres: 20.0,
    );

    const oscar = Fish(
      id: 'oscar',
      name: 'Oscar',
      scientificName: 'Astronotus ocellatus',
      temperament: 'Aggressive',
      minSizeCm: 25.0,
      maxSizeCm: 35.0,
      minTemperature: 23.0,
      maxTemperature: 28.0,
      minPh: 6.5,
      maxPh: 7.5,
      minimumTankLitres: 250.0,
    );

    const goldfish = Fish(
      id: 'goldfish',
      name: 'Goldfish',
      scientificName: 'Carassius auratus',
      temperament: 'Peaceful',
      minSizeCm: 15.0,
      maxSizeCm: 25.0,
      minTemperature: 18.0,
      maxTemperature: 22.0,
      minPh: 7.0,
      maxPh: 8.0,
      minimumTankLitres: 100.0,
    );

    const corydoras = Fish(
      id: 'corydoras',
      name: 'Corydoras',
      scientificName: 'Corydoras sp.',
      temperament: 'Peaceful',
      minSizeCm: 4.0,
      maxSizeCm: 7.0,
      minTemperature: 22.0,
      maxTemperature: 26.0,
      minPh: 6.5,
      maxPh: 7.5,
      minimumTankLitres: 60.0,
    );

    test('Compatible pair: Guppy and Neon Tetra evaluate favorably', () {
      final result = engine.evaluate(guppy, neonTetra);
      expect(result.temperatureStatus, 'Compatible');
      expect(result.temperamentStatus, 'Compatible');
      expect(result.tankSizeStatus, 'Compatible');
      expect(result.score, greaterThanOrEqualTo(70));
    });

    test('Predation risk: Oscar and Neon Tetra is Incompatible', () {
      final result = engine.evaluate(oscar, neonTetra);
      expect(result.temperamentStatus, 'Incompatible');
      expect(result.isIncompatible, isTrue);
      expect(result.score, lessThan(40));
      expect(result.temperamentMessage, contains('predation'));
    });

    test('Behavioral risk: Betta and Guppy are flagged Incompatible/Caution', () {
      final result = engine.evaluate(betta, guppy);
      expect(result.temperamentStatus, 'Incompatible');
      expect(result.temperamentMessage, contains('Guppies'));
      expect(result.isIncompatible, isTrue);
    });

    test('Choking / substrate risk: Goldfish and Corydoras returns caution', () {
      final result = engine.checkTemperament(goldfish, corydoras);
      expect(result.status, 'Caution');
      expect(result.message, contains('defensive spines'));
    });

    test('Temperature mismatch: Goldfish and Betta has no/poor overlap', () {
      final result = engine.evaluate(goldfish, betta);
      expect(result.temperatureStatus, 'Incompatible');
      expect(result.score, lessThan(40));
    });

    test('Handles incomplete / zero parameter values with caution', () {
      const incompleteFish = Fish(
        id: 'mystery_fish',
        name: 'Mystery Fish',
        scientificName: 'Unknown',
        temperament: 'Peaceful',
        minSizeCm: 0.0,
        maxSizeCm: 0.0,
        minTemperature: 0.0,
        maxTemperature: 0.0,
        minPh: 0.0,
        maxPh: 0.0,
        minimumTankLitres: 0.0,
      );

      final result = engine.evaluate(guppy, incompleteFish);
      expect(result.temperatureStatus, 'Caution');
      expect(result.phStatus, 'Caution');
      expect(result.temperatureMessage, contains('Incomplete'));
    });
  });
}
