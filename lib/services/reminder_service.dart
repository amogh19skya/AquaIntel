import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/reminder_model.dart';

/// Firestore CRUD service for AquaIntel reminders.
///
/// Data is stored at: `users/{userId}/reminders/{reminderId}`
///
/// All methods guard against unauthenticated access and Firestore errors.
class ReminderService {
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

  // ─── CREATE ──────────────────────────────────────────────

  /// Adds a new reminder document to Firestore.
  /// Returns the Firestore document ID of the created reminder.
  Future<String> addReminder(ReminderModel reminder) async {
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

      final docRef = await _remindersRef.add(data);
      debugPrint('ReminderService: document created at ${docRef.path}');
      return docRef.id;
    } on FirebaseException catch (e) {
      debugPrint('ReminderService FIRESTORE ERROR: code=${e.code} message=${e.message}');
      throw Exception('Failed to save reminder: [${e.code}] ${e.message}');
    } catch (e) {
      debugPrint('ReminderService UNEXPECTED ERROR: $e');
      throw Exception('Failed to save reminder: $e');
    }
  }

  // ─── READ ────────────────────────────────────────────────

  /// Returns a real-time stream of all reminders for the current user,
  /// ordered by scheduled date (soonest first).
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

  /// Updates an existing reminder document.
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

  /// Toggles the isCompleted flag for a reminder.
  Future<void> toggleReminderCompleted(String reminderId, bool completed) async {
    try {
      await _remindersRef.doc(reminderId).update({
        'isCompleted': completed,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } on FirebaseException catch (e) {
      throw Exception('Failed to update reminder: ${e.message}');
    } catch (e) {
      throw Exception('Failed to update reminder: $e');
    }
  }

  // ─── DELETE ──────────────────────────────────────────────

  /// Permanently deletes a single reminder document.
  Future<void> deleteReminder(String reminderId) async {
    try {
      await _remindersRef.doc(reminderId).delete();
    } on FirebaseException catch (e) {
      throw Exception('Failed to delete reminder: ${e.message}');
    } catch (e) {
      throw Exception('Failed to delete reminder: $e');
    }
  }
}
