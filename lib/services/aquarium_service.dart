import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/aquarium_model.dart';

/// Abstract contract for Aquarium CRUD operations (DIP).
abstract class IAquariumService {
  String newAquariumId();

  Future<String> addAquarium({
    required String name,
    required String type,
    required double length,
    required double width,
    required double height,
    required String unit,
    required double volumeLitres,
    required String description,
    String? imageUrl,
    String? aquariumId,
  });

  Stream<List<AquariumModel>> getAquariums();

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
    // Sentinel distinguishes "not supplied" from "explicitly null".
    Object? imageUrl,
  });

  Future<void> deleteAquarium(String aquariumId);
}

/// Sentinel so callers can distinguish "caller did not supply imageUrl"
/// from "caller explicitly passed null (remove image)".
const Object imageUrlUnset = Object();

/// Service class for all Aquarium CRUD operations in Cloud Firestore.
///
/// Data is stored at: `users/{userId}/aquariums/{aquariumId}`
///
/// Every method safely handles the case where the user is not
/// authenticated by throwing a descriptive [Exception].
class AquariumService implements IAquariumService {
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

  /// Returns a new unused Firestore document ID for an aquarium.
  @override
  String newAquariumId() => _aquariumsRef.doc().id;

  // ─── CREATE ───

  /// Adds a new aquarium document to Firestore.
  ///
  /// Automatically sets [createdAt] and [updatedAt] to [DateTime.now()].
  /// Returns the newly created document's ID.
  /// Pass [imageUrl] to associate a Firebase Storage download URL immediately.
  /// Pass [aquariumId] to set a pre-generated document ID (e.g., after Storage upload).
  @override
  Future<String> addAquarium({
    required String name,
    required String type,
    required double length,
    required double width,
    required double height,
    required String unit,
    required double volumeLitres,
    required String description,
    String? imageUrl,
    String? aquariumId,
  }) async {
    try {
      final now = DateTime.now();
      final docRef = aquariumId != null ? _aquariumsRef.doc(aquariumId) : _aquariumsRef.doc();
      await docRef.set({
        'name': name,
        'type': type,
        'length': length,
        'width': width,
        'height': height,
        'unit': unit,
        'volumeLitres': volumeLitres,
        'description': description,
        'imageUrl': imageUrl,
        'createdAt': Timestamp.fromDate(now),
        'updatedAt': Timestamp.fromDate(now),
      });
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to save aquarium: $e');
    }
  }

  // ─── READ ───

  @override
  Stream<List<AquariumModel>> getAquariums() {
    return _aquariumsRef
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => AquariumModel.fromFirestore(doc))
            .toList());
  }

  // ─── UPDATE ───

  /// Updates an existing aquarium document.
  ///
  /// Pass [imageUrl] as a [String] to set/replace the image URL.
  /// Pass [imageUrl] as `null` to explicitly clear the image URL.
  /// Omit [imageUrl] (or pass [imageUrlUnset]) to leave it unchanged.
  @override
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
    Object? imageUrl = imageUrlUnset,
  }) async {
    try {
      final data = <String, dynamic>{
        'name': name,
        'type': type,
        'length': length,
        'width': width,
        'height': height,
        'unit': unit,
        'volumeLitres': volumeLitres,
        'description': description,
        'updatedAt': Timestamp.fromDate(DateTime.now()),
      };

      // Only write imageUrl when the caller explicitly supplied it.
      if (!identical(imageUrl, imageUrlUnset)) {
        data['imageUrl'] = imageUrl as String?;
      }

      await _aquariumsRef.doc(aquariumId).update(data);
    } catch (e) {
      throw Exception('Failed to update aquarium: $e');
    }
  }

  // ─── DELETE ───

  @override
  Future<void> deleteAquarium(String aquariumId) async {
    try {
      await _aquariumsRef.doc(aquariumId).delete();
    } catch (e) {
      throw Exception('Failed to delete aquarium: $e');
    }
  }
}
