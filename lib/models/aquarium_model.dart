import 'package:cloud_firestore/cloud_firestore.dart';

/// Data model representing an aquarium stored under
/// `users/{userId}/aquariums/{aquariumId}` in Cloud Firestore.
class AquariumModel {
  final String id;
  final String name;
  final String type;
  final double length;
  final double width;
  final double height;
  final String unit;
  final double volumeLitres;
  final String description;
  final DateTime createdAt;
  final DateTime updatedAt;

  AquariumModel({
    required this.id,
    required this.name,
    required this.type,
    required this.length,
    required this.width,
    required this.height,
    required this.unit,
    required this.volumeLitres,
    required this.description,
    required this.createdAt,
    required this.updatedAt,
  });

  // ─── Firestore factory ───

  /// Creates an [AquariumModel] from a Firestore [DocumentSnapshot].
  factory AquariumModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return AquariumModel(
      id: doc.id,
      name: data['name'] as String? ?? '',
      type: data['type'] as String? ?? 'Freshwater',
      length: (data['length'] as num?)?.toDouble() ?? 0.0,
      width: (data['width'] as num?)?.toDouble() ?? 0.0,
      height: (data['height'] as num?)?.toDouble() ?? 0.0,
      unit: data['unit'] as String? ?? 'cm',
      volumeLitres: (data['volumeLitres'] as num?)?.toDouble() ?? 0.0,
      description: data['description'] as String? ?? '',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  /// Converts this [AquariumModel] to a Firestore-compatible map for saving.
  Map<String, dynamic> toFirestore() {
    return {
      'name': name,
      'type': type,
      'length': length,
      'width': width,
      'height': height,
      'unit': unit,
      'volumeLitres': volumeLitres,
      'description': description,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
    };
  }

  /// Returns a copy of this aquarium with selected fields overridden.
  AquariumModel copyWith({
    String? id,
    String? name,
    String? type,
    double? length,
    double? width,
    double? height,
    String? unit,
    double? volumeLitres,
    String? description,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return AquariumModel(
      id: id ?? this.id,
      name: name ?? this.name,
      type: type ?? this.type,
      length: length ?? this.length,
      width: width ?? this.width,
      height: height ?? this.height,
      unit: unit ?? this.unit,
      volumeLitres: volumeLitres ?? this.volumeLitres,
      description: description ?? this.description,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  @override
  String toString() {
    return 'AquariumModel(id: $id, name: $name, type: $type, '
        'volume: $volumeLitres L)';
  }
}