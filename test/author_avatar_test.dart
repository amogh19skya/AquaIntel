import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/widgets/community/author_avatar.dart';
import 'package:aquaintel/widgets/user_avatar.dart';
import 'package:aquaintel/services/user_service.dart';

void main() {
  group('AuthorAvatar & Avatar Fallback Tests', () {
    setUp(() {
      UserService.clearAvatarCache();
    });

    test('UserService in-memory cache sets and retrieves avatar IDs properly', () {
      expect(UserService().getCachedAvatarId('user_1'), isNull);

      UserService.setCachedAvatarId('user_1', 'avatar_07');
      expect(UserService().getCachedAvatarId('user_1'), 'avatar_07');

      // Invalid ID should not be cached
      UserService.setCachedAvatarId('user_2', 'invalid_avatar');
      expect(UserService().getCachedAvatarId('user_2'), isNull);
    });

    testWidgets('AuthorAvatar displays initials fallback when avatarId is null or uncached', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthorAvatar(
              authorUid: 'user_fallback',
              authorName: 'Amogh Shakya',
              size: 40,
            ),
          ),
        ),
      );

      // Verify initials "AS" are rendered
      expect(find.text('AS'), findsOneWidget);
    });

    testWidgets('AuthorAvatar formats single name initials correctly', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthorAvatar(
              authorUid: 'user_single',
              authorName: 'Aquarist',
              size: 40,
            ),
          ),
        ),
      );

      expect(find.text('A'), findsOneWidget);
    });

    testWidgets('AuthorAvatar renders UserAvatar when avatarId is pre-cached', (tester) async {
      UserService.setCachedAvatarId('user_with_avatar', 'avatar_03');

      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: AuthorAvatar(
              authorUid: 'user_with_avatar',
              authorName: 'John Doe',
              size: 40,
            ),
          ),
        ),
      );

      // UserAvatar should be rendered instead of initials text
      expect(find.byType(UserAvatar), findsOneWidget);
      expect(find.text('JD'), findsNothing);
    });

    testWidgets('UserAvatar renders fallback widget when avatarId is invalid and fallback is provided', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: UserAvatar(
              avatarId: null,
              size: 40,
              fallback: Text('FALLBACK_TEXT'),
            ),
          ),
        ),
      );

      expect(find.text('FALLBACK_TEXT'), findsOneWidget);
    });
  });
}

