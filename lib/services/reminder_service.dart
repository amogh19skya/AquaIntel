import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';

/// Abstract contract for Reminder operations (DIP).
abstract class IReminderService {
  String newReminderId();
  Future<String> addReminder(ReminderModel reminder, {String? reminderId});
  Stream<List<ReminderModel>> getReminders();
  Future<void> updateReminder(ReminderModel reminder);
  Future<void> toggleReminderCompleted(String reminderId, bool completed);
  Future<void> markCompleted(String reminderId);
  Future<void> deleteReminder(String reminderId);
}

/// Firestore CRUD service for AquaIntel reminders.
///
/// Data is stored at: `users/{userId}/reminders/{reminderId}`
///
/// All methods guard against unauthenticated access and Firestore errors.
/// Reminders remain permanently saved in Firestore until explicitly deleted.
class ReminderService implements IReminderService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Helpers ─────────────────────────────────────────────

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User is not authenticated.');
    return user.uid;
  }

  CollectionReference<Map<String, dynamic>> get _remindersRef =>
      _firestore.collection('users').doc(_uid).collection('reminders');

  @override
  String newReminderId() => _remindersRef.doc().id;

  // ─── CREATE ──────────────────────────────────────────────

  /// Adds a new reminder document to Firestore.
  /// Returns the Firestore document ID of the created reminder.
  @override
  Future<String> addReminder(ReminderModel reminder, {String? reminderId}) async {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated. Please log in and try again.');
    }
    debugPrint('ReminderService: saving for uid=${user.uid}');
    try {
      final now = DateTime.now();
      final data = reminder.toFirestore();
      data['createdAt'] = Timestamp.fromDate(now);
      data['updatedAt'] = Timestamp.fromDate(now);

      final docRef = reminderId != null
          ? _remindersRef.doc(reminderId)
          : _remindersRef.doc();

      await docRef.set(data);
      debugPrint('ReminderService: document created at ${docRef.path}');
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint(
          'ReminderService FIRESTORE ERROR: code=${e.code} message=${e.message}');
      throw Exception('Failed to save reminder: [${e.code}] ${e.message}');
    } catch (e) {
      debugPrint('ReminderService UNEXPECTED ERROR: $e');
      throw Exception('Failed to save reminder: $e');
    }
  }

  // ─── READ ────────────────────────────────────────────────

  @override
  Stream<List<ReminderModel>> getReminders() {
    try {
      return _remindersRef
          .orderBy('scheduledDateTime', descending: false)
          .snapshots()
          .map(
            (snapshot) => snapshot.docs
                .map((doc) => ReminderModel.fromFirestore(doc))
                .toList(),
          );
    } catch (e) {
      return Stream.error(Exception('Failed to load reminders: $e'));
    }
  }

  // ─── UPDATE ──────────────────────────────────────────────

  @override
  Future<void> updateReminder(ReminderModel reminder) async {
    if (reminder.id == null) {
      throw Exception('Cannot update reminder without an ID.');
    }
    try {
      final data = reminder.toFirestore();
      data['updatedAt'] = Timestamp.fromDate(DateTime.now());

      await _remindersRef.doc(reminder.id).update(data);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update reminder: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  /// Explicitly marks a reminder as completed, writing `completedAt` timestamp.
  /// Never deletes the reminder record.
  @override
  Future<void> markCompleted(String reminderId) async {
    await toggleReminderCompleted(reminderId, true);
  }

  /// Toggles the completion state of a reminder.
  ///
  /// When [completed] is true:
  ///   - `isCompleted` is set to true
  ///   - `status` is set to 'completed'
  ///   - `completedAt` is recorded
  ///
  /// When [completed] is false:
  ///   - `isCompleted` is set to false
  ///   - `completedAt` is set to null
  ///   - `status` is recalculated based on scheduled time
  @override
  Future<void> toggleReminderCompleted(String reminderId, bool completed) async {
    try {
      final now = DateTime.now();
      final updates = <String, dynamic>{
        'isCompleted': completed,
        'status': completed ? 'completed' : 'pending',
        'completedAt': completed ? Timestamp.fromDate(now) : null,
        'updatedAt': Timestamp.fromDate(now),
      };

      await _remindersRef.doc(reminderId).update(updates);
    } on FirebaseException catch (e) {
      throw Exception('Failed to update reminder: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  // ─── DELETE ──────────────────────────────────────────────

  /// Permanently removes the reminder from Firestore.
  /// Only invoked when the user explicitly confirms deletion.
  @override
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _remindersRef.doc(reminderId).delete();
      debugPrint('ReminderService: deleted reminderId=$reminderId');
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete reminder: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }
}
