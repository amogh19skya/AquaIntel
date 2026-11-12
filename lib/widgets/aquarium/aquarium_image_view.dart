import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import '../../theme/app_theme.dart';

/// A universal, resilient aquarium image widget that automatically detects and
/// renders photos from any source:
/// 1. Base64 Data URIs (`data:image/...;base64,...` or raw base64) — zero Firebase Storage needed
/// 2. Remote HTTP/HTTPS URLs (Firebase Storage, Unsplash, external web links)
/// 3. Local device file paths (`/data/user/...` or `C:\...`)
class AquariumImageView extends StatelessWidget {
  final String imageUrl;
  final BoxFit fit;
  final double? width;
  final double? height;
  final Widget? placeholder;
  final Widget Function(BuildContext, Object?, StackTrace?)? errorBuilder;

  const AquariumImageView({
    super.key,
    required this.imageUrl,
    this.fit = BoxFit.cover,
    this.width,
    this.height,
    this.placeholder,
    this.errorBuilder,
  });

  bool get _isBase64 {
    final trimmed = imageUrl.trim();
    return trimmed.startsWith('data:image/') ||
        trimmed.startsWith('data:application/') ||
        trimmed.contains(';base64,');
  }

  bool get _isNetwork {
    final lower = imageUrl.trim().toLowerCase();
    return lower.startsWith('http://') || lower.startsWith('https://');
  }

  Uint8List? _decodeBase64(String uri) {
    try {
      final commaIndex = uri.indexOf(',');
      final clean = commaIndex != -1 ? uri.substring(commaIndex + 1) : uri;
      return base64Decode(clean.trim());
    } catch (_) {
      return null;
    }
  }

  @override
  Widget build(BuildContext context) {
    final cleanUrl = imageUrl.trim();
    if (cleanUrl.isEmpty) {
      return placeholder ?? const SizedBox.shrink();
    }

    // ── 1. Base64 Data URI (offline-safe, zero Firebase Storage dependency) ──
    if (_isBase64) {
      final bytes = _decodeBase64(cleanUrl);
      if (bytes != null && bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder ??
              (_, __, ___) => placeholder ?? const SizedBox.shrink(),
        );
      }
    }

    // ── 2. Remote Network Image (Firebase Storage URL or direct web link) ──
    if (_isNetwork) {
      return Image.network(
        cleanUrl,
        fit: fit,
        width: width,
        height: height,
        loadingBuilder: (context, child, loadingProgress) {
          if (loadingProgress == null) return child;
          return placeholder ??
              const Center(
                child: SizedBox(
                  width: 24,
                  height: 24,
                  child: CircularProgressIndicator(
                    strokeWidth: 2,
                    color: AquaColors.accent,
                  ),
                ),
              );
        },
        errorBuilder: errorBuilder ??
            (_, __, ___) => placeholder ?? const SizedBox.shrink(),
      );
    }

    // ── 3. Local File Path on Device ──
    try {
      final file = File(cleanUrl);
      if (file.existsSync()) {
        return Image.file(
          file,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder ??
              (_, __, ___) => placeholder ?? const SizedBox.shrink(),
        );
      }
    } catch (_) {
      // Fall through to raw base64 try
    }

    // ── 4. Raw base64 string fallback (no prefix) ──
    if (cleanUrl.length > 80 && !cleanUrl.contains(' ')) {
      final bytes = _decodeBase64(cleanUrl);
      if (bytes != null && bytes.isNotEmpty) {
        return Image.memory(
          bytes,
          fit: fit,
          width: width,
          height: height,
          errorBuilder: errorBuilder ??
              (_, __, ___) => placeholder ?? const SizedBox.shrink(),
        );
      }
    }

    return placeholder ?? const SizedBox.shrink();
  }
}

