import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

/// Service responsible for user profile management and avatar persistence.
///
/// Avatars are identified by predefined IDs (`avatar_01` to `avatar_20`)
/// and stored under `users/{uid}` in Cloud Firestore, with local caching in
/// SharedPreferences and in-memory caches for instant, offline-capable display.
class UserService {
  static const String _kLocalAvatarPrefix = 'user_avatar_';

  // In-memory cache for user avatars by UID (prevents redundant fetches/rebuilds)
  static final Map<String, String> _avatarCache = {};
  // Shared broadcast streams per UID (deduplicates Firestore listeners)
  static final Map<String, Stream<String?>> _avatarStreams = {};

  final FirebaseAuth _auth;
  final FirebaseFirestore _firestore;

  UserService({
    FirebaseAuth? auth,
    FirebaseFirestore? firestore,
  })  : _auth = auth ?? FirebaseAuth.instance,
        _firestore = firestore ?? FirebaseFirestore.instance;

  String? get currentUid => _auth.currentUser?.uid;

  /// Returns cached avatarId for [uid] synchronously if available in memory.
  String? getCachedAvatarId(String uid) {
    if (uid.isEmpty) return null;
    return _avatarCache[uid];
  }

  /// Manually seed or prime the in-memory cache (e.g. for testing).
  static void setCachedAvatarId(String uid, String avatarId) {
    if (uid.isNotEmpty && UserModel.isValidAvatarId(avatarId)) {
      _avatarCache[uid] = UserModel.sanitizeAvatarId(avatarId);
    }
  }

  /// Clears in-memory avatar caches (e.g. for testing or logout).
  static void clearAvatarCache() {
    _avatarCache.clear();
    _avatarStreams.clear();
  }

  /// Watches any user's avatar ID by their [uid].
  ///
  /// - Returns a shared broadcast stream to prevent duplicate Firestore listeners.
  /// - Updates the in-memory cache whenever the user document changes.
  /// - Returns `null` if the user has no avatar set or if profile data is unavailable,
  ///   allowing caller to fall back gracefully to initials.
  Stream<String?> watchUserAvatarId(String uid) {
    if (uid.isEmpty) {
      return Stream.value(null);
    }

    if (_avatarStreams.containsKey(uid)) {
      return _avatarStreams[uid]!;
    }

    final stream = _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map<String?>((snapshot) {
      if (!snapshot.exists || snapshot.data() == null) {
        return null;
      }
      final data = snapshot.data()!;
      final rawId = (data['avatarId'] ?? data['avatar_id']) as String?;
      if (rawId != null && UserModel.isValidAvatarId(rawId)) {
        final sanitized = UserModel.sanitizeAvatarId(rawId);
        _avatarCache[uid] = sanitized;
        return sanitized;
      }
      return null;
    }).handleError((_) {
      // Gracefully handle permission-denied or offline errors without throwing
      return null;
    }).asBroadcastStream();

    _avatarStreams[uid] = stream;
    return stream;
  }

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
      final user = UserModel.fromJson(data);
      if (user.avatarId != null && UserModel.isValidAvatarId(user.avatarId)) {
        _avatarCache[uid] = user.effectiveAvatarId;
      }
      return user;
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
      final sanitized = UserModel.sanitizeAvatarId(avatarId);
      _avatarCache[uid] = sanitized;
      return sanitized;
    });
  }

  /// Gets the current avatar ID from cache or Firestore.
  Future<String> getCurrentAvatarId() async {
    final uid = currentUid;
    if (uid == null) {
      return UserModel.defaultAvatarId;
    }

    if (_avatarCache.containsKey(uid)) {
      return _avatarCache[uid]!;
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
        _avatarCache[uid] = sanitized;
        await prefs.setString('$_kLocalAvatarPrefix$uid', sanitized);
        return sanitized;
      }
    } catch (_) {
      // Offline or error — fallback to cached
      if (cached != null && UserModel.isValidAvatarId(cached)) {
        _avatarCache[uid] = cached;
        return cached;
      }
    }

    if (cached != null && UserModel.isValidAvatarId(cached)) {
      _avatarCache[uid] = cached;
      return cached;
    }

    return UserModel.defaultAvatarId;
  }

  /// Updates the user's avatar ID in Firestore and local storage.
  Future<void> updateAvatarId(String avatarId) async {
    final uid = currentUid;
    if (uid == null) {
      throw Exception('User is not signed in.');
    }

    final sanitized = UserModel.sanitizeAvatarId(avatarId);
    _avatarCache[uid] = sanitized;

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
    _avatarCache[uid] = sanitizedAvatar;

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
