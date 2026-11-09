import 'package:flutter_test/flutter_test.dart';
import 'package:aquaintel/models/reminder_model.dart';

void main() {
  group('ReminderModel Status and Persistence Tests', () {
    test('Correctly derives Pending status for future uncompleted reminders', () {
      final futureTime = DateTime.now().add(const Duration(hours: 2));
      final reminder = ReminderModel(
        id: 'rem-1',
        title: 'Feed Guppies',
        description: 'Pinch of flakes',
        type: ReminderType.feeding,
        aquariumName: 'Community Tank',
        scheduledDateTime: futureTime,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationId: 101,
      );

      expect(reminder.status, ReminderStatus.pending);
      expect(reminder.isPending, isTrue);
      expect(reminder.isOverdue, isFalse);
      expect(reminder.isCompleted, isFalse);
    });

    test('Correctly derives Overdue status for past uncompleted reminders', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 2));
      final reminder = ReminderModel(
        id: 'rem-2',
        title: 'Water Change',
        description: '20% change',
        type: ReminderType.waterChange,
        aquariumName: 'Community Tank',
        scheduledDateTime: pastTime,
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationId: 102,
      );

      expect(reminder.status, ReminderStatus.overdue);
      expect(reminder.isOverdue, isTrue);
      expect(reminder.isPending, isFalse);
      expect(reminder.isCompleted, isFalse);
    });

    test('Correctly derives Completed status regardless of scheduled time', () {
      final pastTime = DateTime.now().subtract(const Duration(hours: 5));
      final completedTime = DateTime.now().subtract(const Duration(hours: 1));
      final reminder = ReminderModel(
        id: 'rem-3',
        title: 'Filter Cleaning',
        description: 'Rinse sponge in tank water',
        type: ReminderType.filterCleaning,
        aquariumName: 'Nano Tank',
        scheduledDateTime: pastTime,
        isCompleted: true,
        completedAt: completedTime,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationId: 103,
      );

      expect(reminder.status, ReminderStatus.completed);
      expect(reminder.isCompleted, isTrue);
      expect(reminder.isOverdue, isFalse);
      expect(reminder.isPending, isFalse);
      expect(reminder.completedAt, equals(completedTime));
    });

    test('Serialization toFirestore preserves all fields and completedAt', () {
      final scheduled = DateTime(2026, 11, 10, 14, 30);
      final completed = DateTime(2026, 11, 10, 15, 0);
      final reminder = ReminderModel(
        id: 'rem-4',
        title: 'Medication Dose',
        description: 'Add 5ml medicine',
        type: ReminderType.medication,
        aquariumId: 'aqua-99',
        aquariumName: 'Quarantine Tank',
        scheduledDateTime: scheduled,
        isCompleted: true,
        completedAt: completed,
        notificationEnabled: true,
        createdAt: DateTime(2026, 11, 1),
        updatedAt: DateTime(2026, 11, 10),
        notificationId: 104,
      );

      final map = reminder.toFirestore();
      expect(map['title'], 'Medication Dose');
      expect(map['type'], 'Medication');
      expect(map['status'], 'completed');
      expect(map['isCompleted'], isTrue);
      expect(map['completedAt'], isNotNull);
      expect(map['aquariumId'], 'aqua-99');
      expect(map['notificationId'], 104);
    });

    test('copyWith allows marking as completed and un-completing', () {
      final reminder = ReminderModel(
        id: 'rem-5',
        title: 'Tank Cleaning',
        description: 'Scrape algae',
        type: ReminderType.tankCleaning,
        aquariumName: 'Display Tank',
        scheduledDateTime: DateTime.now().add(const Duration(days: 1)),
        isCompleted: false,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
        notificationId: 105,
      );

      final completionTime = DateTime.now();
      final completed = reminder.copyWith(
        isCompleted: true,
        completedAt: completionTime,
      );

      expect(completed.isCompleted, isTrue);
      expect(completed.status, ReminderStatus.completed);
      expect(completed.completedAt, equals(completionTime));

      final restored = completed.copyWith(
        isCompleted: false,
        completedAt: null,
      );

      expect(restored.isCompleted, isFalse);
      expect(restored.completedAt, isNull);
      expect(restored.status, ReminderStatus.pending);
    });
  });
}

