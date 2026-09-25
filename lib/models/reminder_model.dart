/// Data model for a maintenance reminder / scheduled task.
///
/// This model captures everything the user inputs via the
/// "Schedule Maintenance" form and can be serialised to / from
/// JSON for API or local‑storage persistence.
class Reminder {
  final String? id;
  final String tankName;
  final String taskType; // 'Fish Feed', 'Water Change', 'Tank Cleaning', 'Filter Wash'
  final DateTime scheduledDate;
  final DateTime scheduledTime;
  final bool isCompleted;
  final DateTime? createdAt;

  Reminder({
    this.id,
    required this.tankName,
    required this.taskType,
    required this.scheduledDate,
    required this.scheduledTime,
    this.isCompleted = false,
    this.createdAt,
  });

  // ─── Serialisation helpers ───

  /// Create a [Reminder] from a JSON map (e.g. API response).
  factory Reminder.fromJson(Map<String, dynamic> json) {
    return Reminder(
      id: json['id'] as String?,
      tankName: json['tank_name'] as String? ?? '',
      taskType: json['task_type'] as String? ?? '',
      scheduledDate: json['scheduled_date'] != null
          ? DateTime.parse(json['scheduled_date'] as String)
          : DateTime.now(),
      scheduledTime: json['scheduled_time'] != null
          ? DateTime.parse(json['scheduled_time'] as String)
          : DateTime.now(),
      isCompleted: json['is_completed'] as bool? ?? false,
      createdAt: json['created_at'] != null
          ? DateTime.parse(json['created_at'] as String)
          : null,
    );
  }

  /// Convert this [Reminder] to a JSON‑compatible map.
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      'tank_name': tankName,
      'task_type': taskType,
      'scheduled_date': scheduledDate.toIso8601String(),
      'scheduled_time': scheduledTime.toIso8601String(),
      'is_completed': isCompleted,
      if (createdAt != null) 'created_at': createdAt!.toIso8601String(),
    };
  }

  /// Return a copy of this reminder with selected fields overridden.
  Reminder copyWith({
    String? id,
    String? tankName,
    String? taskType,
    DateTime? scheduledDate,
    DateTime? scheduledTime,
    bool? isCompleted,
    DateTime? createdAt,
  }) {
    return Reminder(
      id: id ?? this.id,
      tankName: tankName ?? this.tankName,
      taskType: taskType ?? this.taskType,
      scheduledDate: scheduledDate ?? this.scheduledDate,
      scheduledTime: scheduledTime ?? this.scheduledTime,
      isCompleted: isCompleted ?? this.isCompleted,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  String toString() {
    return 'Reminder(id: $id, tankName: $tankName, taskType: $taskType, '
        'date: $scheduledDate, time: $scheduledTime, '
        'completed: $isCompleted)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Reminder &&
        other.id == id &&
        other.tankName == tankName &&
        other.taskType == taskType &&
        other.scheduledDate == scheduledDate &&
        other.scheduledTime == scheduledTime &&
        other.isCompleted == isCompleted;
  }

  @override
  int get hashCode {
    return Object.hash(
      id,
      tankName,
      taskType,
      scheduledDate,
      scheduledTime,
      isCompleted,
    );
  }
}
