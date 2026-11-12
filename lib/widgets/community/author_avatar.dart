import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../theme/app_theme.dart';
import '../user_avatar.dart';

/// Reusable Author Avatar widget for Community posts, post details, and comments.
///
/// Features:
/// - Retrieves the author's selected 3D avatar by [authorUid] via [UserService].
/// - Reuses existing avatar assets and [UserAvatar] component.
/// - Retains the original initials-based circle as fallback when:
///   - No avatar has been selected.
///   - Profile data is unavailable / loading.
///   - Avatar ID or asset path is invalid.
/// - Uses in-memory caching and shared broadcast streams to prevent redundant
///   Firestore reads.
/// - Automatically updates if the author updates their avatar.
class AuthorAvatar extends StatelessWidget {
  final String authorUid;
  final String authorName;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;

  const AuthorAvatar({
    super.key,
    required this.authorUid,
    required this.authorName,
    this.size = 40.0,
    this.showBorder = true,
    this.borderColor,
    this.borderWidth = 1.0,
    this.onTap,
  });

  String get _initials {
    final trimmed = authorName.trim();
    if (trimmed.isEmpty) return '?';
    final parts = trimmed.split(RegExp(r'\s+'));
    if (parts.length >= 2 && parts[0].isNotEmpty && parts[1].isNotEmpty) {
      return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
    }
    return trimmed[0].toUpperCase();
  }

  Widget _buildInitials() {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: AquaColors.accent.withValues(alpha: 0.15),
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: borderColor ?? AquaColors.accent.withValues(alpha: 0.25),
                width: borderWidth,
              )
            : null,
      ),
      child: Center(
        child: Text(
          _initials,
          style: TextStyle(
            color: AquaColors.accent,
            fontSize: size * 0.375,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (authorUid.isEmpty) {
      return _buildInitials();
    }

    final userService = UserService();
    final cachedAvatar = userService.getCachedAvatarId(authorUid);

    return StreamBuilder<String?>(
      initialData: cachedAvatar,
      stream: userService.watchUserAvatarId(authorUid),
      builder: (context, snapshot) {
        final avatarId = snapshot.data;

        if (avatarId == null || !UserModel.isValidAvatarId(avatarId)) {
          return _buildInitials();
        }

        return UserAvatar(
          avatarId: avatarId,
          size: size,
          showBorder: showBorder,
          borderColor: borderColor ?? AquaColors.accent.withValues(alpha: 0.25),
          borderWidth: borderWidth,
          backgroundColor: AquaColors.cardElevated,
          fallback: _buildInitials(),
          onTap: onTap,
        );
      },
    );
  }
}

