import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/fish.dart';

/// Service responsible for fetching fish data from Cloud Firestore.
///
/// Reads from the top-level `fish` collection.
/// Documents are public reference data (no auth required in Firestore rules).
///
/// Firestore path: `fish/{fishId}`
class FishService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // ─── Collection reference ─────────────────────────────────────────────────

  CollectionReference<Map<String, dynamic>> get _fishRef =>
      _firestore.collection('fish');

  // ─── READ ─────────────────────────────────────────────────────────────────

  /// Fetches all fish documents from Firestore as a [Future<List<Fish>>].
  ///
  /// Documents are sorted alphabetically by name in the UI layer; Firestore
  /// returns them in an unspecified order (use the `name` field to sort).
  ///
  /// Returns an empty list — not an error — when the collection is empty.
  /// Throws a human-readable [Exception] on Firestore errors so callers can
  /// display a user-friendly message.
  Future<List<Fish>> getFishList() async {
    try {
      debugPrint('[FishService] Fetching fish collection…');
      final snapshot = await _fishRef.orderBy('name').get();

      final fish = snapshot.docs.map((doc) {
        try {
          return Fish.fromFirestore(doc);
        } catch (e) {
          debugPrint('[FishService] Skipping malformed document '
              '"${doc.id}": $e');
          return null;
        }
      }).whereType<Fish>().toList();

      debugPrint('[FishService] Loaded ${fish.length} fish.');
      return fish;
    } on FirebaseException catch (e) {
      debugPrint('[FishService] FirebaseException: ${e.code} – ${e.message}');
      throw Exception(
        'Could not load fish data. '
        'Please check your internet connection and try again.',
      );
    } catch (e) {
      debugPrint('[FishService] Unexpected error: $e');
      throw Exception('An unexpected error occurred while loading fish data.');
    }
  }

  /// Fetches a single fish document by its Firestore document [id].
  ///
  /// Returns `null` when no document with that ID exists.
  Future<Fish?> getFishById(String id) async {
    try {
      debugPrint('[FishService] Fetching fish "$id"…');
      final doc = await _fishRef.doc(id).get();
      if (!doc.exists) {
        debugPrint('[FishService] Fish "$id" not found.');
        return null;
      }
      return Fish.fromFirestore(doc);
    } on FirebaseException catch (e) {
      debugPrint('[FishService] FirebaseException for "$id": ${e.code}');
      throw Exception('Could not load fish data. Please try again.');
    } catch (e) {
      debugPrint('[FishService] Unexpected error for "$id": $e');
      throw Exception('An unexpected error occurred.');
    }
  }
}
