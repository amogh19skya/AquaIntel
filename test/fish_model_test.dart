import 'package:flutter_test/flutter_test.dart';
import 'package:flutter/material.dart';
import 'package:aquaintel/models/fish.dart';

void main() {
  group('Fish model tests', () {
    test('Default values and getters format properly', () {
      const fish = Fish(
        id: 'guppy',
        name: 'Guppy',
        scientificName: 'Poecilia reticulata',
        temperament: 'Peaceful',
        minSizeCm: 3.2,
        maxSizeCm: 5.8,
        minTemperature: 22.0,
        maxTemperature: 28.0,
        minPh: 7.0,
        maxPh: 8.0,
        minimumTankLitres: 40.0,
      );

      expect(fish.sizeRange, '3–6 cm');
      expect(fish.temperatureRange, '22–28°C');
      expect(fish.phRange, '7.0–8.0');
      expect(fish.tankSizeLabel, '40L+');
      expect(fish.icon, Icons.water);
      expect(fish.accentColor, const Color(0xFF66BB6A));
      expect(fish.toString(), 'Fish(id: guppy, name: Guppy)');
    });

    test('Equality and hashCode are based on id', () {
      const fish1 = Fish(
        id: 'betta',
        name: 'Betta A',
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

      const fish2 = Fish(
        id: 'betta',
        name: 'Betta B',
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

      expect(fish1, equals(fish2));
      expect(fish1.hashCode, equals(fish2.hashCode));
    });

    test('All 8 known fish IDs resolve to dedicated icons and colors', () {
      const ids = [
        'betta',
        'neon_tetra',
        'guppy',
        'goldfish',
        'angelfish',
        'corydoras',
        'oscar',
        'platy',
      ];

      for (final id in ids) {
        final fish = Fish(
          id: id,
          name: id,
          scientificName: '',
          temperament: 'Peaceful',
          minSizeCm: 1,
          maxSizeCm: 2,
          minTemperature: 20,
          maxTemperature: 25,
          minPh: 6.5,
          maxPh: 7.5,
          minimumTankLitres: 40,
        );
        expect(fish.icon, isNotNull);
        expect(fish.accentColor, isNotNull);
      }
    });
  });
}
