import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/models/user_model.dart';

void main() {
  group('UserModel Avatar Tests', () {
    test('allAvatarIds contains 20 avatars with format avatar_01 to avatar_20', () {
      expect(UserModel.allAvatarIds.length, 20);
      expect(UserModel.allAvatarIds.first, 'avatar_01');
      expect(UserModel.allAvatarIds.last, 'avatar_20');
      for (int i = 1; i <= 20; i++) {
        final expected = 'avatar_${i.toString().padLeft(2, '0')}';
        expect(UserModel.allAvatarIds.contains(expected), isTrue);
      }
    });

    test('isValidAvatarId correctly validates IDs', () {
      expect(UserModel.isValidAvatarId('avatar_01'), isTrue);
      expect(UserModel.isValidAvatarId('avatar_20'), isTrue);
      expect(UserModel.isValidAvatarId('avatar_00'), isFalse);
      expect(UserModel.isValidAvatarId('avatar_21'), isFalse);
      expect(UserModel.isValidAvatarId(''), isFalse);
      expect(UserModel.isValidAvatarId(null), isFalse);
      expect(UserModel.isValidAvatarId('avatar_5'), isFalse);
    });

    test('sanitizeAvatarId falls back safely to avatar_01', () {
      expect(UserModel.sanitizeAvatarId('avatar_05'), 'avatar_05');
      expect(UserModel.sanitizeAvatarId(null), 'avatar_01');
      expect(UserModel.sanitizeAvatarId('invalid_id'), 'avatar_01');
      expect(UserModel.sanitizeAvatarId(''), 'avatar_01');
    });

    test('avatarAssetPath returns correct asset string', () {
      expect(
        UserModel.avatarAssetPath('avatar_07'),
        'assets/images/avatars/avatar_07.png',
      );
      expect(
        UserModel.avatarAssetPath(null),
        'assets/images/avatars/avatar_01.png',
      );
    });

    test('UserModel serialization preserves avatarId', () {
      final user = UserModel(
        id: 'user_123',
        fullName: 'Test Aquarist',
        email: 'test@example.com',
        avatarId: 'avatar_14',
      );

      final json = user.toJson();
      expect(json['avatarId'], 'avatar_14');
      expect(json['avatar_id'], 'avatar_14');

      final reconstructed = UserModel.fromJson(json);
      expect(reconstructed.avatarId, 'avatar_14');
      expect(reconstructed.effectiveAvatarId, 'avatar_14');
    });

    test('UserModel defaults to avatar_01 when avatarId is absent', () {
      final user = UserModel(
        fullName: 'Aqua User',
        email: 'user@aqua.com',
      );
      expect(user.effectiveAvatarId, 'avatar_01');
      expect(user.avatarAssetPathString, 'assets/images/avatars/avatar_01.png');
    });
  });
}

