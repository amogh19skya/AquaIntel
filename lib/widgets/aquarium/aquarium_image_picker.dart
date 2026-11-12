import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../theme/app_theme.dart';
import 'aquarium_image_view.dart';

/// A self-contained, flexible image picker widget that fits into the Add/Edit
/// Aquarium forms.
///
/// Supports:
/// - Picking photos from the device gallery.
/// - Taking photos using the camera.
/// - Providing a direct web image URL (offline/storage bypass).
/// - Universal preview via [AquariumImageView] supporting Base64, URLs, and local files.
class AquariumImagePicker extends StatefulWidget {
  /// Pre-existing remote image URL (from Firestore). Used in Edit mode.
  final String? existingImageUrl;

  /// Called when the user picks a new image file from gallery or camera.
  final void Function(File file) onImagePicked;

  /// Called when the user removes the current image.
  final void Function() onImageRemoved;

  /// Optional callback when a direct image URL or Base64 is provided.
  final void Function(String url)? onImageUrlProvided;

  const AquariumImagePicker({
    super.key,
    this.existingImageUrl,
    required this.onImagePicked,
    required this.onImageRemoved,
    this.onImageUrlProvided,
  });

  @override
  State<AquariumImagePicker> createState() => _AquariumImagePickerState();
}

class _AquariumImagePickerState extends State<AquariumImagePicker> {
  File? _pickedFile;
  String? _directImageUrl;
  final ImagePicker _picker = ImagePicker();

  bool get _hasLocalFile => _pickedFile != null;
  bool get _hasDirectUrl => _directImageUrl != null && _directImageUrl!.isNotEmpty;
  bool get _hasRemoteImage =>
      widget.existingImageUrl != null &&
      widget.existingImageUrl!.isNotEmpty &&
      !_isRemoved;
  bool _isRemoved = false;

  bool get _hasAnyImage => _hasLocalFile || _hasDirectUrl || _hasRemoteImage;

  Future<void> _pickFromSource(ImageSource source) async {
    Navigator.of(context, rootNavigator: true).pop(); // Close bottom sheet
    try {
      final XFile? picked = await _picker.pickImage(
        source: source,
        imageQuality: 75,
        maxWidth: 1024,
        maxHeight: 768,
      );
      if (picked == null) return; // user cancelled

      final file = File(picked.path);

      // Client-side size guard (5 MB)
      final bytes = await file.length();
      if (bytes > 5 * 1024 * 1024) {
        if (mounted) {
          _showError('Image is too large. Please choose a photo under 5 MB.');
        }
        return;
      }

      setState(() {
        _pickedFile = file;
        _directImageUrl = null;
        _isRemoved = false;
      });
      widget.onImagePicked(file);
    } catch (e) {
      if (mounted) {
        _showError('Could not access image. Please check camera/gallery permissions.');
      }
    }
  }

  void _promptImageUrl() {
    Navigator.of(context, rootNavigator: true).pop(); // Close bottom sheet
    final controller = TextEditingController();

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AquaColors.cardElevated,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Insert Image URL',
          style: TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paste a direct link to an aquarium photo (e.g. https://... or Unsplash):',
              style: TextStyle(color: AquaColors.textSecondary, fontSize: 13),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: controller,
              style: TextStyle(color: Colors.white, fontSize: 14),
              decoration: InputDecoration(
                hintText: 'https://images.unsplash.com/...',
                hintStyle: TextStyle(color: AquaColors.textMuted, fontSize: 13),
                filled: true,
                fillColor: AquaColors.input,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AquaColors.border),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AquaColors.border),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(10),
                  borderSide: BorderSide(color: AquaColors.accent),
                ),
                contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text('Cancel', style: TextStyle(color: AquaColors.textMuted)),
          ),
          ElevatedButton(
            onPressed: () {
              final url = controller.text.trim();
              if (url.isNotEmpty) {
                setState(() {
                  _directImageUrl = url;
                  _pickedFile = null;
                  _isRemoved = false;
                });
                widget.onImageUrlProvided?.call(url);
              }
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: AquaColors.accent,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            child: const Text('Insert URL'),
          ),
        ],
      ),
    );
  }

  void _showImageSourceModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (ctx) => Container(
        padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
        decoration: BoxDecoration(
          color: AquaColors.cardElevated,
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              child: Text(
                'Add Aquarium Photograph',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 8),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AquaColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.photo_library_outlined, color: AquaColors.accent, size: 20),
              ),
              title: Text('Choose from Gallery', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Select a saved tank photo from your phone', style: TextStyle(color: AquaColors.textMuted, fontSize: 12)),
              onTap: () => _pickFromSource(ImageSource.gallery),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AquaColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.camera_alt_outlined, color: AquaColors.accent, size: 20),
              ),
              title: Text('Take a Photo (Camera)', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Capture a live picture of your aquarium right now', style: TextStyle(color: AquaColors.textMuted, fontSize: 12)),
              onTap: () => _pickFromSource(ImageSource.camera),
            ),
            ListTile(
              leading: Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: AquaColors.accent.withValues(alpha: 0.15),
                  shape: BoxShape.circle,
                ),
                child: Icon(Icons.link_rounded, color: AquaColors.accent, size: 20),
              ),
              title: Text('Insert Image Web Link (URL)', style: TextStyle(color: Colors.white, fontSize: 14)),
              subtitle: Text('Paste any direct photo link without uploading', style: TextStyle(color: AquaColors.textMuted, fontSize: 12)),
              onTap: _promptImageUrl,
            ),
          ],
        ),
      ),
    );
  }

  void _removeImage() {
    setState(() {
      _pickedFile = null;
      _directImageUrl = null;
      _isRemoved = true;
    });
    widget.onImageRemoved();
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AquaColors.error,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
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
                : _hasDirectUrl
                    ? AquariumImageView(
                        imageUrl: _directImageUrl!,
                        fit: BoxFit.cover,
                        placeholder: _buildPlaceholder(isLoading: true),
                        errorBuilder: (_, __, ___) => _buildPlaceholder(isLoading: false),
                      )
                    : _hasRemoteImage
                        ? AquariumImageView(
                            imageUrl: widget.existingImageUrl!,
                            fit: BoxFit.cover,
                            placeholder: _buildPlaceholder(isLoading: true),
                            errorBuilder: (_, __, ___) => _buildPlaceholder(isLoading: false),
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
                onPressed: _showImageSourceModal,
                icon: Icon(
                  _hasAnyImage ? Icons.photo_library_outlined : Icons.add_photo_alternate_outlined,
                  size: 18,
                ),
                label: Text(_hasAnyImage ? 'Change Photo' : 'Upload / Insert Photo'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AquaColors.accent,
                  side: BorderSide(color: AquaColors.accent, width: 1.2),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  textStyle: TextStyle(
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
                icon: Icon(Icons.delete_outline, size: 18),
                label: Text('Remove'),
                style: OutlinedButton.styleFrom(
                  foregroundColor: AquaColors.error,
                  side: BorderSide(
                    color: AquaColors.error.withValues(alpha: 0.6),
                    width: 1.2,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 14),
                  textStyle: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ],
        ),

        const SizedBox(height: 4),
        Text(
          'Gallery, Camera, or Web URL · Auto-compressed & stored safely',
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
                    child: Icon(
                      Icons.add_photo_alternate_outlined,
                      color: AquaColors.accent,
                      size: 26,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    'Add Aquarium Photo',
                    style: TextStyle(
                      color: AquaColors.textSecondary,
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Tap to pick from Gallery, Camera, or URL',
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
