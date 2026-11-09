import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/services/compatibility_seeder.dart';

void main() {
  group('CompatibilitySeeder local validation and dry-run tests', () {
    test('Contains exactly 28 predefined pairs', () {
      expect(CompatibilitySeeder.predefinedPairs.length, equals(28));
    });

    test('All 28 predefined pairs pass schema validation with zero errors', () {
      final errors = CompatibilitySeeder.validateAllPairs();
      expect(errors, isEmpty, reason: 'Errors found: $errors');
    });

    test('validatePayload detects missing required fields', () {
      const invalidPairId = 'betta_guppy';
      final invalidPayload = <String, dynamic>{
        'score': 30,
        // missing 'status'
        'temperature': {'status': 'Compatible', 'message': 'ok'},
        'ph': {'status': 'Compatible', 'message': 'ok'},
        'temperament': {'status': 'Incompatible', 'message': 'ok'},
        'tankSize': {'status': 'Caution', 'message': 'ok'},
        'recommendation': 'Do not mix',
      };

      expect(
        CompatibilitySeeder.validatePayload(invalidPairId, invalidPayload),
        isFalse,
      );
    });

    test('Local dryRun without Firestore query validates all 28 items as missing/pending', () async {
      final seeder = CompatibilitySeeder();
      final report = await seeder.dryRun(inspectFirestore: false);

      expect(report.isDryRun, isTrue);
      expect(report.total, equals(28));
      expect(report.missing.length, equals(28));
      expect(report.failed, isEmpty);
      expect(report.isSuccessful, isTrue);
    });
  });
}
