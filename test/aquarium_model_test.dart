import 'package:aquaintel/models/aquarium_model.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('AquariumModel with imageUrl tests', () {
    test('Constructs with optional imageUrl', () {
      final aquarium = AquariumModel(
        id: 'test-123',
        name: 'Planted Tank',
        type: 'Freshwater',
        length: 60.0,
        width: 30.0,
        height: 35.0,
        unit: 'cm',
        volumeLitres: 63.0,
        description: 'Nature style aquarium',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        imageUrl: 'https://firebasestorage.googleapis.com/.../aquarium_image.jpg',
      );

      expect(aquarium.imageUrl, isNotNull);
      expect(aquarium.imageUrl, contains('aquarium_image.jpg'));
    });

    test('toFirestore includes imageUrl and preserves existing fields', () {
      final aquarium = AquariumModel(
        id: 'test-456',
        name: 'Reef Tank',
        type: 'Saltwater',
        length: 90.0,
        width: 45.0,
        height: 45.0,
        unit: 'cm',
        volumeLitres: 182.25,
        description: 'Mixed reef',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        imageUrl: 'https://example.com/reef.jpg',
      );

      final map = aquarium.toFirestore();
      expect(map['name'], 'Reef Tank');
      expect(map['type'], 'Saltwater');
      expect(map['volumeLitres'], 182.25);
      expect(map['imageUrl'], 'https://example.com/reef.jpg');
    });

    test('Backward compatibility: null imageUrl is supported', () {
      final aquarium = AquariumModel(
        id: 'test-legacy',
        name: 'Legacy Tank',
        type: 'Freshwater',
        length: 50.0,
        width: 25.0,
        height: 30.0,
        unit: 'cm',
        volumeLitres: 37.5,
        description: '',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
      );

      expect(aquarium.imageUrl, isNull);
      final map = aquarium.toFirestore();
      expect(map['imageUrl'], isNull);
    });

    test('copyWith can update or clear imageUrl', () {
      final aquarium = AquariumModel(
        id: 'test-789',
        name: 'Nano Tank',
        type: 'Freshwater',
        length: 30.0,
        width: 30.0,
        height: 30.0,
        unit: 'cm',
        volumeLitres: 27.0,
        description: 'Shrimp tank',
        createdAt: DateTime(2026, 1, 1),
        updatedAt: DateTime(2026, 1, 2),
        imageUrl: 'https://example.com/initial.jpg',
      );

      // Update imageUrl
      final updated = aquarium.copyWith(imageUrl: 'https://example.com/new.jpg');
      expect(updated.imageUrl, 'https://example.com/new.jpg');

      // Clear imageUrl explicitly
      final cleared = updated.copyWith(imageUrl: null);
      expect(cleared.imageUrl, isNull);

      // Leave unchanged
      final unchanged = updated.copyWith(name: 'Updated Name');
      expect(unchanged.name, 'Updated Name');
      expect(unchanged.imageUrl, 'https://example.com/new.jpg');
    });
  });
}

