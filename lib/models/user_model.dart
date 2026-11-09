/// Data model representing an AquaIntel user profile.
///
/// Holds the editable profile fields shown on the Edit Profile screen
/// and can be serialised to / from JSON for API or local‑storage persistence.
class UserModel {
  static const String defaultAvatarId = 'avatar_01';
  static const int totalAvatars = 20;

  /// List of all 20 predefined avatar IDs: ['avatar_01', 'avatar_02', ..., 'avatar_20']
  static final List<String> allAvatarIds = List.generate(
    totalAvatars,
    (index) => 'avatar_${(index + 1).toString().padLeft(2, '0')}',
  );

  /// Checks if an avatar ID is one of the valid predefined 20 avatars.
  static bool isValidAvatarId(String? id) {
    if (id == null) return false;
    return allAvatarIds.contains(id);
  }

  /// Sanitizes an avatar ID, returning [defaultAvatarId] if null or invalid.
  static String sanitizeAvatarId(String? id) {
    if (id != null && allAvatarIds.contains(id)) {
      return id;
    }
    return defaultAvatarId;
  }

  /// Returns the asset path for a given avatar ID.
  static String avatarAssetPath(String? id) {
    return 'assets/images/avatars/${sanitizeAvatarId(id)}.png';
  }

  final String? id;
  final String fullName;
  final DateTime? dateOfBirth;
  final String email;
  final String? profileImageUrl;
  final String? avatarId;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.fullName,
    this.dateOfBirth,
    required this.email,
    this.profileImageUrl,
    this.avatarId,
    this.createdAt,
    this.updatedAt,
  });

  /// The active avatar ID, falling back safely to [defaultAvatarId].
  String get effectiveAvatarId => sanitizeAvatarId(avatarId);

  /// The asset path for this user's avatar.
  String get avatarAssetPathString => avatarAssetPath(avatarId);

  // ─── Serialisation helpers ───

  /// Create a [UserModel] from a JSON map (e.g. Firestore / API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      fullName: json['full_name'] as String? ?? json['fullName'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : (json['dateOfBirth'] != null
              ? DateTime.parse(json['dateOfBirth'] as String)
              : null),
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profile_image_url'] as String? ?? json['profileImageUrl'] as String?,
      avatarId: json['avatar_id'] as String? ?? json['avatarId'] as String?,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
      updatedAt: json['updated_at'] != null
          ? DateTime.parse(json['updated_at'] as String)
          : null,
    );
  }

  /// Convert this [UserModel] to a JSON‑compatible map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'full_name': fullName,
      if (dateOfBirth != null)
        'date_of_birth': dateOfBirth!.toIso8601String(),
      'email': email,
      if (profileImageUrl != null) 'profile_image_url': profileImageUrl,
      if (avatarId != null) 'avatar_id': avatarId,
      'avatarId': effectiveAvatarId,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
      if (updatedAt != null) 'updated_at': updatedAt!.toIso8601String(),
    };
  }

  /// Return a copy of this user with selected fields overridden.
  UserModel copyWith({
    String? id,
    String? fullName,
    DateTime? dateOfBirth,
    String? email,
    String? profileImageUrl,
    String? avatarId,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      avatarId: avatarId ?? this.avatarId,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, '
        'dob: $dateOfBirth, avatarId: $avatarId)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.dateOfBirth == dateOfBirth &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl &&
        other.avatarId == avatarId;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      fullName,
      dateOfBirth,
      email,
      profileImageUrl,
      avatarId,
    );
  }
}
