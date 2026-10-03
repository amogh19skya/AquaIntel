import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/aquarium_model.dart';

/// Service class for all Aquarium CRUD operations in Cloud Firestore.
///
/// Data is stored at: `users/{userId}/aquariums/{aquariumId}`
///
/// Every method safely handles the case where the user is not
/// authenticated by throwing a descriptive [Exception].
class AquariumService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Helpers ───

  /// Returns the current user's UID, or throws if not signed in.
  String get _uid {
    final user = _auth.currentUser;
    if (user == null) {
      throw Exception('User is not authenticated. Please sign in.');
    }
    return user.uid;
  }

  /// Returns the Firestore collection reference for the current user's aquariums.
  CollectionReference<Map<String, dynamic>> get _aquariumsRef =>
      _firestore.collection('users').doc(_uid).collection('aquariums');

  // ─── CREATE ───

  /// Adds a new aquarium document to Firestore.
  ///
  /// Automatically sets [createdAt] and [updatedAt] to [DateTime.now()].
  /// Returns the newly created document's ID.
  Future<String> addAquarium({
    required String name,
    required String type,
    required double length,
    required double width,
    required double height,
    required String unit,
    required double volumeLitres,
    required String description,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = await _aquariumsRef.add({
        'name': name,
        'type': type,
        'length': length,
        'width': width,
        'height': height,
        'unit': unit,
        'volumeLitres': volumeLitres,
        'description': description,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save aquarium: $e');
    }
  }

  // ─── READ ───

  /// Returns a real-time stream of all aquariums for the current user,
  /// ordered by creation date (newest first).
  Stream<List<AquariumModel>> getAquariums() {
    return _aquariumsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AquariumModel.fromFirestore(doc))
            .toList());
  }

  // ─── UPDATE ───

  /// Updates an existing aquarium document in Firestore.
  ///
  /// Automatically updates the [updatedAt] timestamp.
  Future<void> updateAquarium({
    required String aquariumId,
    required String name,
    required String type,
    required double length,
    required double width,
    required double height,
    required String unit,
    required double volumeLitres,
    required String description,
  }) async {
    try {
      await _aquariumsRef.doc(aquariumId).update({
        'name': name,
        'type': type,
        'length': length,
        'width': width,
        'height': height,
        'unit': unit,
        'volumeLitres': volumeLitres,
        'description': description,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      });
    } catch (e) {
      throw Exception('Failed to update aquarium: $e');
    }
  }

  // ─── DELETE ───

  /// Permanently deletes a single aquarium document.
  ///
  /// Only deletes the specific [aquariumId] document.
  /// Does NOT delete the user account or other aquariums.
  Future<void> deleteAquarium(String aquariumId) async {
    try {
      await _aquariumsRef.doc(aquariumId).delete();
    } catch (e) {
      throw Exception('Failed to delete aquarium: $e');
    }
  }
}
