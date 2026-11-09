import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';

/// A self-contained image picker widget that fits into the Add/Edit
/// Aquarium forms.
///
/// Shows:
/// - An upload prompt when no image is selected/provided.
/// - A preview of [existingImageUrl] (Firebase Storage) when editing.
/// - A preview of [pickedFile] when the user has selected a local file.
/// - A "Change / Remove" action strip when an image is present.
///
/// The parent widget receives changes via [onImagePicked] (new local file)
/// and [onImageRemoved] (clear the image).
class AquariumImagePicker extends StatefulWidget {
  /// Pre-existing remote image URL (from Firestore). Used in Edit mode.
  final String? existingImageUrl;

  /// Called when the user picks a new image file from the gallery.
  final void Function(File file) onImagePicked;

  /// Called when the user removes the current image.
  final void Function() onImageRemoved;

  const AquariumImagePicker({
    super.key,
    this.existingImageUrl,
    required this.onImagePicked,
    required this.onImageRemoved,
  });

  @override
  State<AquariumImagePicker> createState() => _AquariumImagePickerState();
}

class _AquariumImagePickerState extends State<AquariumImagePicker> {
  File? _pickedFile;
  final ImagePicker _picker = ImagePicker();

  bool get _hasLocalFile => _pickedFile != null;
  bool get _hasRemoteImage =>
      widget.existingImageUrl != null &&
      widget.existingImageUrl!.isNotEmpty;
  bool get _hasAnyImage => _hasLocalFile || _hasRemoteImage;

  Future<void> _pickImage() async {
    try {
      final XFile? picked = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 85,
        maxWidth: 1920,
        maxHeight: 1080,
      );
      if (picked == null) return; // user cancelled

      final file = File(picked.path);

      // Client-side size guard (5 MB) — mirrors the service guard.
      final bytes = await file.length();
      if (bytes > 5 * 1024 * 1024) {
        if (mounted) {
          _showError('Image is too large. Please choose a photo under 5 MB.');
        }
        return;
      }

      setState(() => _pickedFile = file);
      widget.onImagePicked(file);
    } catch (e) {
      if (mounted) {
        _showError('Could not open the image. Please try again.');
      }
    }
  }

  void _removeImage() {
    setState(() => _pickedFile = null);
    widget.onImageRemoved();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AquaColors.error,
        behavior: SnackBarBehavior.floating,
        shape:
            RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── Image Preview / Upload Zone ───
        ClipRRect(
          borderRadius: BorderRadius.circular(14),
          child: AspectRatio(
            aspectRatio: 16 / 9,
            child: _hasLocalFile
                ? Image.file(_pickedFile!, fit: BoxFit.cover)
                : _hasRemoteImage
                    ? Image.network(
                        widget.existingImageUrl!,
                        fit: BoxFit.cover,
                        loadingBuilder: (ctx, child, progress) {
                          if (progress == null) return child;
                          return _buildPlaceholder(isLoading: true);
                        },
                        errorBuilder: (_, __, ___) =>
                            _buildPlaceholder(isLoading: false),
                      )
                    : _buildPlaceholder(isLoading: false),
          ),
        ),

        const SizedBox(height: 10),

        // ─── Action Buttons ───
        Row(
          children: [
            Expanded(
              child: OutlinedButton.icon(
                onPressed: _pickImage,
                icon: Icon(
                  _hasAnyImage ? Icons.photo_library_outlined : Icons.add_photo_alternate_outlined,
                  size: 18,
                ),
                label: Text(_hasAnyImage ? 'Change Photo' : 'Upload Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AquaColors.accent,
                  side: const BorderSide(color: AquaColors.accent, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
            if (_hasAnyImage) ...[
              const SizedBox(width: 10),
              OutlinedButton.icon(
                onPressed: _removeImage,
                icon: const Icon(Icons.delete_outline, size: 18),
                label: const Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AquaColors.error,
                  side: BorderSide(
                      color: AquaColors.error.withValues(alpha: 0.6),
                      width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  textStyle: const TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),
        const Text(
          'JPG, PNG or WEBP · Max 5 MB',
          style: TextStyle(
            color: AquaColors.textMuted,
            fontSize: 11,
          ),
        ),
      ],
    );
  }

  Widget _buildPlaceholder({required bool isLoading}) {
    return Container(
      color: AquaColors.input,
      child: Center(
        child: isLoading
            ? const CircularProgressIndicator(
                color: AquaColors.accent,
                strokeWidth: 2.5,
              )
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    width: 52,
                    height: 52,
                    decoration: BoxDecoration(
                      color: AquaColors.accent.withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: AquaColors.accent.withValues(alpha: 0.2),
                      ),
                    ),
                    child: const Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AquaColors.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    'Add Aquarium Photo',
                    style: TextStyle(
                      color: AquaColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Tap "Upload Photo" to get started',
                    style: TextStyle(
                      color: AquaColors.textMuted,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
      ),
    );
  }
}

