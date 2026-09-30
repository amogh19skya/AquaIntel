/// Data model representing an AquaIntel user profile.
///
/// Holds the editable profile fields shown on the Edit Profile screen
/// and can be serialised to / from JSON for API or local‑storage persistence.
class UserModel {
  final String? id;
  final String fullName;
  final DateTime? dateOfBirth;
  final String email;
  final String? profileImageUrl;
  final DateTime? createdAt;
  final DateTime? updatedAt;

  UserModel({
    this.id,
    required this.fullName,
    this.dateOfBirth,
    required this.email,
    this.profileImageUrl,
    this.createdAt,
    this.updatedAt,
  });

  // ─── Serialisation helpers ───

  /// Create a [UserModel] from a JSON map (e.g. API response).
  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      id: json['id'] as String?,
      fullName: json['full_name'] as String? ?? '',
      dateOfBirth: json['date_of_birth'] != null
          ? DateTime.parse(json['date_of_birth'] as String)
          : null,
      email: json['email'] as String? ?? '',
      profileImageUrl: json['profile_image_url'] as String?,
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
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      dateOfBirth: dateOfBirth ?? this.dateOfBirth,
      email: email ?? this.email,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'UserModel(id: $id, fullName: $fullName, email: $email, '
        'dob: $dateOfBirth, profileImage: $profileImageUrl)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is UserModel &&
        other.id == id &&
        other.fullName == fullName &&
        other.dateOfBirth == dateOfBirth &&
        other.email == email &&
        other.profileImageUrl == profileImageUrl;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      fullName,
      dateOfBirth,
      email,
      profileImageUrl,
    );
  }
}
