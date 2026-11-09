import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';

/// Handles uploading and deleting aquarium photographs in Firebase Storage.
///
/// Storage path layout:
///   users/{uid}/aquariums/{aquariumId}/aquarium_image.jpg
///
/// Security is enforced by Firebase Storage Security Rules (see
/// storage.rules) which restrict each user to their own UID prefix.
class AquariumImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Helpers ───

  String get _uid {
    final user = _auth.currentUser;
    if (user == null) throw Exception('User is not authenticated.');
    return user.uid;
  }

  /// Returns the Storage [Reference] for [aquariumId].
  Reference _ref(String aquariumId) => _storage
      .ref()
      .child('users')
      .child(_uid)
      .child('aquariums')
      .child(aquariumId)
      .child('aquarium_image.jpg');

  // ─── Upload ───

  /// Uploads the image at [file] to Firebase Storage and returns the
  /// public download URL.
  ///
  /// Validates that the file is ≤ 5 MB and has a supported MIME type.
  /// Accepts JPEG, PNG, WEBP and GIF files.
  ///
  /// Pass [onProgress] to receive upload progress in the range [0.0, 1.0].
  Future<String> uploadImage({
    required File file,
    required String aquariumId,
    void Function(double progress)? onProgress,
  }) async {
    // ── Size guard (5 MB) ──
    final bytes = await file.length();
    if (bytes > 5 * 1024 * 1024) {
      throw Exception(
          'Image is too large. Please choose a photo under 5 MB.');
    }

    // ── MIME type guard ──
    final ext = file.path.split('.').last.toLowerCase();
    const supportedExts = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
    if (!supportedExts.contains(ext)) {
      throw Exception(
          'Unsupported image format. Please use JPG, PNG, WEBP or GIF.');
    }

    final metadata = SettableMetadata(
      contentType: ext == 'png'
          ? 'image/png'
          : ext == 'webp'
              ? 'image/webp'
              : ext == 'gif'
                  ? 'image/gif'
                  : 'image/jpeg',
    );

    final task = _ref(aquariumId).putFile(file, metadata);

    if (onProgress != null) {
      task.snapshotEvents.listen((snap) {
        if (snap.totalBytes > 0) {
          onProgress(snap.bytesTransferred / snap.totalBytes);
        }
      });
    }

    await task;
    return await _ref(aquariumId).getDownloadURL();
  }

  // ─── Delete ───

  /// Deletes the aquarium image from Firebase Storage.
  /// Silently succeeds if the file does not exist.
  Future<void> deleteImage(String aquariumId) async {
    try {
      await _ref(aquariumId).delete();
    } on FirebaseException catch (e) {
      // object-not-found is expected when no image was ever uploaded
      if (e.code != 'object-not-found') rethrow;
    }
  }
}

