import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/community_post.dart';
import '../models/aquarium_model.dart';

/// Result type for [CommunityService.likesStream].
typedef LikesState = ({int count, bool isLiked});

/// Service for all community post, like, and comment operations.
///
/// Firestore layout:
///   communityPosts/{postId}
///   communityPosts/{postId}/likes/{uid}
///   communityPosts/{postId}/comments/{commentId}
///
/// Counter strategy: likeCount and commentCount are NOT stored on the post
/// document. Counts are derived live from subcollection sizes using
/// Firestore AggregateQuery (count()) or subcollection snapshots.
/// This avoids the security impossibility of allowing non-authors to update
/// a post document while also preventing arbitrary counter manipulation.
class CommunityService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Helpers ───

  User get _requireUser {
    final u = _auth.currentUser;
    if (u == null) throw Exception('User is not authenticated. Please sign in.');
    return u;
  }

  CollectionReference<Map<String, dynamic>> get _posts =>
      _db.collection('communityPosts');

  /// Returns displayName if set, otherwise the part of the email before '@'.
  String _resolveAuthorName(User user) {
    final name = user.displayName?.trim() ?? '';
    if (name.isNotEmpty) return name;
    final email = user.email ?? '';
    return email.contains('@') ? email.split('@').first : 'Aquarist';
  }

  // ─── FEED ───────────────────────────────────────────────────────────────────

  /// Real-time stream of the 50 most recent community posts, newest first.
  Stream<List<CommunityPost>> feedStream() {
    return _posts
        .orderBy('createdAt', descending: true)
        .limit(50)
        .snapshots()
        .map((s) => s.docs.map(CommunityPost.fromFirestore).toList());
  }

  // ─── CREATE ─────────────────────────────────────────────────────────────────

  /// Creates a community post referencing the authenticated user's [aquarium].
  ///
  /// Enforces:
  ///   - Only fields in [kAllowedSnapshotFields] are copied into the snapshot.
  ///   - [visibleFields] is sanitised against [kAllowedSnapshotFields].
  ///   - [caption] is trimmed and must not exceed 500 characters.
  ///
  /// Aquarium ownership is also enforced by Firestore Security Rules via
  /// `exists(/users/{uid}/aquariums/{aquariumId})` — the client restriction
  /// here is defence-in-depth only.
  Future<String> createPost({
    required AquariumModel aquarium,
    required String caption,
    required List<String> visibleFields,
  }) async {
    final user = _requireUser;

    final trimmedCaption = caption.trim();
    if (trimmedCaption.isEmpty) throw Exception('Caption cannot be empty.');
    if (trimmedCaption.length > 500) {
      throw Exception('Caption must be 500 characters or fewer.');
    }

    // Sanitise visibleFields — only allow known safe field names.
    final safeVisible = visibleFields
        .where(kAllowedSnapshotFields.contains)
        .toList();
    if (safeVisible.isEmpty) {
      throw Exception('Select at least one aquarium detail to share.');
    }

    // Only the four allowed fields are ever written into the snapshot.
    final snapshot = {
      'name': aquarium.name,
      'type': aquarium.type,
      'volumeLitres': aquarium.volumeLitres,
      'description': aquarium.description,
    };

    final now = DateTime.now();
    final docRef = await _posts.add({
      'authorUid': user.uid,
      'authorName': _resolveAuthorName(user),
      'caption': trimmedCaption,
      'aquariumId': aquarium.id,
      'aquariumSnapshot': snapshot,
      'visibleFields': safeVisible,
      'imageUrl': null, // v1: no photo upload
      'createdAt': Timestamp.fromDate(now),
      'updatedAt': Timestamp.fromDate(now),
    });
    return docRef.id;
  }

  // ─── EDIT CAPTION ────────────────────────────────────────────────────────────

  /// Edits the caption of a post the current user owns.
  /// Only [caption] and [updatedAt] are written — matches the security rule
  /// `affectedKeys().hasOnly(['caption', 'updatedAt'])`.
  Future<void> editCaption(String postId, String newCaption) async {
    final user = _requireUser;
    final trimmed = newCaption.trim();
    if (trimmed.isEmpty) throw Exception('Caption cannot be empty.');
    if (trimmed.length > 500) throw Exception('Caption must be 500 characters or fewer.');

    final doc = await _posts.doc(postId).get();
    if (!doc.exists) throw Exception('Post not found.');
    if ((doc.data()!['authorUid'] as String) != user.uid) {
      throw Exception('You can only edit your own posts.');
    }

    await _posts.doc(postId).update({
      'caption': trimmed,
      'updatedAt': Timestamp.fromDate(DateTime.now()),
    });
  }

  // ─── DELETE ─────────────────────────────────────────────────────────────────

  /// Deletes the post and all its likes and comments subcollections.
  ///
  /// Firestore does not cascade-delete subcollections when a parent is deleted,
  /// so subcollections are explicitly removed first.
  Future<void> deletePost(String postId) async {
    final user = _requireUser;
    final doc = await _posts.doc(postId).get();
    if (!doc.exists) throw Exception('Post not found.');
    if ((doc.data()!['authorUid'] as String) != user.uid) {
      throw Exception('You can only delete your own posts.');
    }

    await _deleteSubcollection(postId, 'likes');
    await _deleteSubcollection(postId, 'comments');
    await _posts.doc(postId).delete();
  }

  Future<void> _deleteSubcollection(String postId, String sub) async {
    const batchSize = 100;
    while (true) {
      final snap = await _posts.doc(postId).collection(sub).limit(batchSize).get();
      if (snap.docs.isEmpty) break;
      final batch = _db.batch();
      for (final d in snap.docs) {
        batch.delete(d.reference);
      }
      await batch.commit();
      if (snap.docs.length < batchSize) break;
    }
  }

  // ─── LIKES ──────────────────────────────────────────────────────────────────

  /// Stream combining the current like count and whether the signed-in user
  /// has liked [postId]. Uses a single subcollection snapshot so both pieces
  /// of state are always in sync without a separate AggregateQuery.
  Stream<LikesState> likesStream(String postId) {
    final uid = _auth.currentUser?.uid;
    return _posts.doc(postId).collection('likes').snapshots().map(
          (snap) => (
            count: snap.docs.length,
            isLiked: uid != null && snap.docs.any((d) => d.id == uid),
          ),
        );
  }

  /// Toggles like/unlike for the current user on [postId].
  /// No counter fields are updated — counts are derived from the subcollection.
  Future<void> toggleLike(String postId, {required bool currentlyLiked}) async {
    final user = _requireUser;
    final likeRef = _posts.doc(postId).collection('likes').doc(user.uid);

    if (currentlyLiked) {
      await likeRef.delete();
    } else {
      await likeRef.set({
        'uid': user.uid,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }
  }

  // ─── COMMENTS ───────────────────────────────────────────────────────────────

  /// Real-time stream of comments for [postId], ordered oldest first.
  Stream<List<PostComment>> commentsStream(String postId) {
    return _posts
        .doc(postId)
        .collection('comments')
        .orderBy('createdAt')
        .snapshots()
        .map((s) => s.docs.map(PostComment.fromFirestore).toList());
  }

  /// Returns the server-side comment count via AggregateQuery.
  /// Used on the feed card where we want a count without a full stream.
  Future<int> commentCount(String postId) async {
    final agg = await _posts.doc(postId).collection('comments').count().get();
    return agg.count ?? 0;
  }

  /// Real-time stream of the comment count for [postId].
  /// Derives the count from the comments subcollection snapshot size so it
  /// stays in sync whenever a comment is added or deleted.
  Stream<int> commentCountStream(String postId) {
    return _posts
        .doc(postId)
        .collection('comments')
        .snapshots()
        .map((snap) => snap.docs.length);
  }

  /// Adds a comment to [postId].
  /// No counter batch write — count is derived from [commentCount].
  Future<void> addComment(String postId, String text) async {
    final user = _requireUser;
    final trimmed = text.trim();
    if (trimmed.isEmpty) throw Exception('Comment cannot be empty.');
    if (trimmed.length > 1000) throw Exception('Comment must be 1 000 characters or fewer.');

    await _posts.doc(postId).collection('comments').add({
      'authorUid': user.uid,
      'authorName': _resolveAuthorName(user),
      'text': trimmed,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  /// Deletes a comment owned by the current user.
  Future<void> deleteComment(String postId, String commentId) async {
    final user = _requireUser;
    final ref = _posts.doc(postId).collection('comments').doc(commentId);
    final doc = await ref.get();
    if (!doc.exists) throw Exception('Comment not found.');
    if ((doc.data()!['authorUid'] as String) != user.uid) {
      throw Exception('You can only delete your own comments.');
    }
    await ref.delete();
  }
}
