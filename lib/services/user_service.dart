import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service responsible for user profile management and avatar persistence.
///
/// Avatars are identified by predefined IDs (`avatar_01` to `avatar_20`)
/// and stored under `users/{uid}` in Cloud Firestore, with local caching in
/// SharedPreferences for instant, offline-capable display.
class UserService {
  static const String _kLocalAvatarPrefix = 'user_avatar_';

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Returns a stream of the current user's profile document from Firestore.
  Stream<UserModel?> currentUserStream() {
    final uid = currentUid;
    if (uid == null) {
      return Stream.value(null);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        final fbUser = _auth.currentUser;
        if (fbUser != null) {
          return UserModel(
            id: uid,
            fullName: fbUser.displayName ?? 'Aquarist',
            email: fbUser.email ?? '',
            avatarId: UserModel.defaultAvatarId,
          );
        }
        return null;
      }
      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      return UserModel.fromJson(data);
    });
  }

  /// Returns a stream of the current user's avatar ID.
  Stream<String> currentAvatarIdStream() {
    final uid = currentUid;
    if (uid == null) {
      return Stream.value(UserModel.defaultAvatarId);
    }

    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return UserModel.defaultAvatarId;
      }
      final data = snapshot.data()!;
      final avatarId = (data['avatarId'] ?? data['avatar_id']) as String?;
      return UserModel.sanitizeAvatarId(avatarId);
    });
  }

  /// Gets the current avatar ID from cache or Firestore.
  Future<String> getCurrentAvatarId() async {
    final uid = currentUid;
    if (uid == null) {
      return UserModel.defaultAvatarId;
    }

    // Try SharedPreferences first for instant render
    final prefs = await SharedPreferences.getInstance();
    final cached = prefs.getString('$_kLocalAvatarPrefix$uid');

    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists && doc.data() != null) {
        final data = doc.data()!;
        final rawId = (data['avatarId'] ?? data['avatar_id']) as String?;
        final sanitized = UserModel.sanitizeAvatarId(rawId);
        await prefs.setString('$_kLocalAvatarPrefix$uid', sanitized);
        return sanitized;
      }
    } catch (_) {
      // Offline or error — fallback to cached
      if (cached != null && UserModel.isValidAvatarId(cached)) {
        return cached;
      }
    }

    return cached != null && UserModel.isValidAvatarId(cached)
        ? cached
        : UserModel.defaultAvatarId;
  }

  /// Updates the user's avatar ID in Firestore and local storage.
  Future<void> updateAvatarId(String avatarId) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('User is not signed in.');
    }

    final sanitized = UserModel.sanitizeAvatarId(avatarId);

    // Save locally
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kLocalAvatarPrefix$uid', sanitized);

    // Save to Firestore users/{uid}
    await _firestore.collection('users').doc(uid).set({
      'avatarId': sanitized,
      'avatar_id': sanitized,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));
  }

  /// Updates profile details (e.g. name, date of birth, avatar).
  Future<void> updateUserProfile(UserModel user) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('User is not signed in.');
    }

    final sanitizedAvatar = UserModel.sanitizeAvatarId(user.avatarId);

    // Update Firebase Auth displayName
    if (user.fullName.isNotEmpty) {
      await _auth.currentUser?.updateDisplayName(user.fullName);
    }

    final data = {
      'full_name': user.fullName,
      'fullName': user.fullName,
      'email': user.email,
      'avatarId': sanitizedAvatar,
      'avatar_id': sanitizedAvatar,
      if (user.dateOfBirth != null)
        'date_of_birth': user.dateOfBirth!.toIso8601String(),
      'updatedAt': FieldValue.serverTimestamp(),
    };

    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('$_kLocalAvatarPrefix$uid', sanitizedAvatar);

    await _firestore
        .collection('users')
        .doc(uid)
        .set(data, SetOptions(merge: true));
  }
}

