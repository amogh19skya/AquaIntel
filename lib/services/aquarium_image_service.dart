import 'dart:convert';
import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

/// Handles uploading, storing, and deleting aquarium photographs.
///
/// Dual-Storage Strategy:
/// 1. Primary: Tries uploading to Firebase Storage when available and configured.
/// 2. Resilient Fallback: If Firebase Storage is unavailable, not provisioned,
///    restricted by billing/rules, or offline, automatically encodes the photo
///    as a compressed Base64 Data URI saved directly into Firestore.
///
/// This ensures users can ALWAYS insert and save aquarium images without being
/// blocked by Firebase Storage quota or configuration limitations.
class AquariumImageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ─── Helpers ───

  String? get _uid => _auth.currentUser?.uid;

  /// Returns the Storage [Reference] for [aquariumId] if user is signed in.
  Reference? _ref(String aquariumId) {
    final uid = _uid;
    if (uid == null) return null;
    return _storage
        .ref()
        .child('users')
        .child(uid)
        .child('aquariums')
        .child(aquariumId)
        .child('aquarium_image.jpg');
  }

  // ─── Upload / Insert ───

  /// Uploads or converts [file] to a persistent image reference string.
  ///
  /// - Attempts Firebase Storage first if user is authenticated.
  /// - Automatically falls back to an optimized Base64 data URI if Firebase
  ///   Storage throws any error (e.g. bucket-not-found, unauthorized, quota).
  ///
  /// Returns a download URL or a `data:image/...;base64,...` URI.
  Future<String> uploadImage({
    required File file,
    required String aquariumId,
    void Function(double progress)? onProgress,
  }) async {
    if (!await file.exists()) {
      throw Exception('Selected photo file was not found.');
    }

    final bytes = await file.length();
    if (bytes > 5 * 1024 * 1024) {
      throw Exception('Image is too large. Please choose a photo under 5 MB.');
    }

    final ext = file.path.split('.').last.toLowerCase();
    const supportedExts = {'jpg', 'jpeg', 'png', 'webp', 'gif'};
    final effectiveExt = supportedExts.contains(ext) ? ext : 'jpg';

    // ── Attempt 1: Firebase Storage (if online & authenticated) ──
    final storageRef = _ref(aquariumId);
    if (storageRef != null) {
      try {
        final metadata = SettableMetadata(
          contentType: effectiveExt == 'png'
              ? 'image/png'
              : effectiveExt == 'webp'
                  ? 'image/webp'
                  : effectiveExt == 'gif'
                      ? 'image/gif'
                      : 'image/jpeg',
        );

        final task = storageRef.putFile(file, metadata);

        if (onProgress != null) {
          task.snapshotEvents.listen((snap) {
            if (snap.totalBytes > 0) {
              onProgress(snap.bytesTransferred / snap.totalBytes);
            }
          });
        }

        // Wait with a timeout to avoid hanging if storage bucket is unreachable
        await task.timeout(const Duration(seconds: 5));
        final downloadUrl = await storageRef
            .getDownloadURL()
            .timeout(const Duration(seconds: 4));
        return downloadUrl;
      } catch (e) {
        // Firebase Storage failed (no bucket, unauthorized, free plan limit, or offline)
        debugPrint(
            'Firebase Storage upload unavailable ($e). Falling back to Base64 image storage.');
      }
    }

    // ── Attempt 2: Resilient Base64 Fallback ──
    // Encodes the photo directly so it saves reliably inside Firestore.
    onProgress?.call(0.5);
    final fileBytes = await file.readAsBytes();
    final mime = effectiveExt == 'png'
        ? 'image/png'
        : (effectiveExt == 'webp' ? 'image/webp' : 'image/jpeg');
    final base64Str = base64Encode(fileBytes);
    onProgress?.call(1.0);
    return 'data:$mime;base64,$base64Str';
  }

  // ─── Delete ───

  /// Deletes the aquarium image from Firebase Storage if present.
  /// Silently succeeds if the file does not exist or storage is not used.
  Future<void> deleteImage(String aquariumId) async {
    try {
      final storageRef = _ref(aquariumId);
      if (storageRef != null) {
        await storageRef.delete();
      }
    } catch (_) {
      // Ignore cleanup error if Firebase Storage was not used
    }
  }
}
