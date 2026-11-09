import 'package:cloud_firestore/cloud_firestore.dart';

/// The four aquarium fields that may legally appear in a community post.
/// Nothing outside this set is ever stored in a post snapshot.
const kAllowedSnapshotFields = {'name', 'type', 'volumeLitres', 'description'};

// ─── Aquarium snapshot ────────────────────────────────────────────────────────

/// A privacy-safe copy of selected [AquariumModel] fields embedded in a post.
/// Only fields in [kAllowedSnapshotFields] are included — dimensions, unit,
/// private createdAt/updatedAt are never copied.
class AquariumSnapshot {
  final String name;
  final String type;
  final double volumeLitres;
  final String description;

  const AquariumSnapshot({
    required this.name,
    required this.type,
    required this.volumeLitres,
    required this.description,
  });

  factory AquariumSnapshot.fromMap(Map<String, dynamic> m) => AquariumSnapshot(
        name: m['name'] as String? ?? '',
        type: m['type'] as String? ?? '',
        volumeLitres: (m['volumeLitres'] as num?)?.toDouble() ?? 0.0,
        description: m['description'] as String? ?? '',
      );

  Map<String, dynamic> toMap() => {
        'name': name,
        'type': type,
        'volumeLitres': volumeLitres,
        'description': description,
      };
}

// ─── Community post ───────────────────────────────────────────────────────────

/// A post stored at `communityPosts/{postId}`.
///
/// **No `likeCount` or `commentCount` fields** — counts are derived live from
/// the `likes/` and `comments/` subcollections to avoid counter-security issues.
class CommunityPost {
  final String id;
  final String authorUid;
  final String authorName;
  final String caption;

  /// Document ID of the source aquarium under `users/{authorUid}/aquariums/`.
  final String aquariumId;

  /// Privacy-safe snapshot. Only [kAllowedSnapshotFields] keys are present.
  final AquariumSnapshot aquariumSnapshot;

  /// Subset of [kAllowedSnapshotFields] the author wants to render in the feed.
  final List<String> visibleFields;

  /// Always null in v1 (no Firebase Storage).
  final String? imageUrl;

  final DateTime createdAt;
  final DateTime updatedAt;

  const CommunityPost({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.caption,
    required this.aquariumId,
    required this.aquariumSnapshot,
    required this.visibleFields,
    this.imageUrl,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── Firestore serialisation ───

  factory CommunityPost.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return CommunityPost(
      id: doc.id,
      authorUid: d['authorUid'] as String? ?? '',
      authorName: d['authorName'] as String? ?? 'Aquarist',
      caption: d['caption'] as String? ?? '',
      aquariumId: d['aquariumId'] as String? ?? '',
      aquariumSnapshot: AquariumSnapshot.fromMap(
        (d['aquariumSnapshot'] as Map<String, dynamic>?) ?? {},
      ),
      visibleFields: List<String>.from(
        (d['visibleFields'] as List? ?? []).where(kAllowedSnapshotFields.contains),
      ),
      imageUrl: d['imageUrl'] as String?,
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (d['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'authorUid': authorUid,
        'authorName': authorName,
        'caption': caption,
        'aquariumId': aquariumId,
        'aquariumSnapshot': aquariumSnapshot.toMap(),
        'visibleFields': visibleFields,
        'imageUrl': null, // v1: no photo upload
        'createdAt': Timestamp.fromDate(createdAt),
        'updatedAt': Timestamp.fromDate(updatedAt),
      };

  CommunityPost copyWith({String? caption, DateTime? updatedAt}) => CommunityPost(
        id: id,
        authorUid: authorUid,
        authorName: authorName,
        caption: caption ?? this.caption,
        aquariumId: aquariumId,
        aquariumSnapshot: aquariumSnapshot,
        visibleFields: visibleFields,
        imageUrl: imageUrl,
        createdAt: createdAt,
        updatedAt: updatedAt ?? this.updatedAt,
      );
}

// ─── Post comment ─────────────────────────────────────────────────────────────

/// Stored at `communityPosts/{postId}/comments/{commentId}`.
class PostComment {
  final String id;
  final String authorUid;
  final String authorName;
  final String text;
  final DateTime createdAt;

  const PostComment({
    required this.id,
    required this.authorUid,
    required this.authorName,
    required this.text,
    required this.createdAt,
  });

  factory PostComment.fromFirestore(DocumentSnapshot doc) {
    final d = doc.data() as Map<String, dynamic>;
    return PostComment(
      id: doc.id,
      authorUid: d['authorUid'] as String? ?? '',
      authorName: d['authorName'] as String? ?? 'Aquarist',
      text: d['text'] as String? ?? '',
      createdAt: (d['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toFirestore() => {
        'authorUid': authorUid,
        'authorName': authorName,
        'text': text,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
