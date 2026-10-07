import 'package:cloud_firestore/cloud_firestore.dart';

/// All supported reminder task types.
enum ReminderType {
  feeding,
  waterChange,
  filterCleaning,
  tankCleaning,
  medication,
  maintenance,
  custom,
}

extension ReminderTypeExtension on ReminderType {
  String get label {
    switch (this) {
      case ReminderType.feeding:
        return 'Feeding';
      case ReminderType.waterChange:
        return 'Water Change';
      case ReminderType.filterCleaning:
        return 'Filter Cleaning';
      case ReminderType.tankCleaning:
        return 'Tank Cleaning';
      case ReminderType.medication:
        return 'Medication';
      case ReminderType.maintenance:
        return 'Maintenance';
      case ReminderType.custom:
        return 'Custom';
    }
  }

  static ReminderType fromString(String value) {
    switch (value) {
      case 'Feeding':
        return ReminderType.feeding;
      case 'Water Change':
        return ReminderType.waterChange;
      case 'Filter Cleaning':
        return ReminderType.filterCleaning;
      case 'Tank Cleaning':
        return ReminderType.tankCleaning;
      case 'Medication':
        return ReminderType.medication;
      case 'Maintenance':
        return ReminderType.maintenance;
      case 'Custom':
      default:
        return ReminderType.custom;
    }
  }
}

/// Data model for a maintenance reminder stored under
/// `users/{userId}/reminders/{reminderId}` in Cloud Firestore.
class ReminderModel {
  final String? id;
  final String title;
  final String description;
  final ReminderType type;
  final String? aquariumId;
  final String aquariumName;
  final DateTime scheduledDateTime;
  final bool isCompleted;
  final bool notificationEnabled;
  final DateTime createdAt;
  final DateTime updatedAt;
  final int notificationId;

  ReminderModel({
    this.id,
    required this.title,
    required this.description,
    required this.type,
    this.aquariumId,
    required this.aquariumName,
    required this.scheduledDateTime,
    this.isCompleted = false,
    this.notificationEnabled = true,
    required this.createdAt,
    required this.updatedAt,
    required this.notificationId,
  });

  factory ReminderModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return ReminderModel(
      id: doc.id,
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      type: ReminderTypeExtension.fromString(data['type'] as String? ?? 'Custom'),
      aquariumId: data['aquariumId'] as String?,
      aquariumName: data['aquariumName'] as String? ?? '',
      scheduledDateTime: (data['scheduledDateTime'] as Timestamp?)?.toDate() ?? DateTime.now(),
      isCompleted: data['isCompleted'] as bool? ?? false,
      notificationEnabled: data['notificationEnabled'] as bool? ?? true,
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      notificationId: data['notificationId'] as int? ?? 0,
    );
  }

  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'description': description,
      'type': type.label,
      'aquariumId': aquariumId,
      'aquariumName': aquariumName,
      'scheduledDateTime': Timestamp.fromDate(scheduledDateTime),
      'isCompleted': isCompleted,
      'notificationEnabled': notificationEnabled,
      'createdAt': Timestamp.fromDate(createdAt),
      'updatedAt': Timestamp.fromDate(updatedAt),
      'notificationId': notificationId,
    };
  }

  ReminderModel copyWith({
    String? id,
    String? title,
    String? description,
    ReminderType? type,
    String? aquariumId,
    String? aquariumName,
    DateTime? scheduledDateTime,
    bool? isCompleted,
    bool? notificationEnabled,
    DateTime? createdAt,
    DateTime? updatedAt,
    int? notificationId,
  }) {
    return ReminderModel(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      type: type ?? this.type,
      aquariumId: aquariumId ?? this.aquariumId,
      aquariumName: aquariumName ?? this.aquariumName,
      scheduledDateTime: scheduledDateTime ?? this.scheduledDateTime,
      isCompleted: isCompleted ?? this.isCompleted,
      notificationEnabled: notificationEnabled ?? this.notificationEnabled,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      notificationId: notificationId ?? this.notificationId,
    );
  }

  bool get isFuture => scheduledDateTime.isAfter(DateTime.now());

  @override
  String toString() =>
      'ReminderModel(id: $id, title: $title, type: ${type.label}, '
      'scheduledAt: $scheduledDateTime, completed: $isCompleted)';
}
