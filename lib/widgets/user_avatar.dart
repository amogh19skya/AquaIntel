import 'package:flutter/material.dart';
import '../models/user_model.dart';
import '../theme/app_theme.dart';

/// Reusable circular 3D Cartoon Avatar widget for AquaIntel.
///
/// Features:
/// - Displays one of 20 predefined avatars from `assets/images/avatars/`.
/// - Automatic fallback to `avatar_01` if [avatarId] is null or invalid.
/// - Circular clipping with [BoxFit.cover] and subtle container background.
/// - Optional customizable border (e.g. cyan accent highlight).
/// - Optional tap gesture handler.
class UserAvatar extends StatelessWidget {
  final String? avatarId;
  final double size;
  final bool showBorder;
  final Color? borderColor;
  final double borderWidth;
  final VoidCallback? onTap;
  final List<BoxShadow>? boxShadow;
  final Color? backgroundColor;

  const UserAvatar({
    super.key,
    this.avatarId,
    this.size = 40.0,
    this.showBorder = false,
    this.borderColor,
    this.borderWidth = 2.0,
    this.onTap,
    this.boxShadow,
    this.backgroundColor,
  });

  @override
  Widget build(BuildContext context) {
    final effectiveBorderColor = borderColor ?? AquaColors.accent;
    final effectiveBgColor = backgroundColor ?? AquaColors.cardElevated;
    final assetPath = UserModel.avatarAssetPath(avatarId);

    Widget avatarWidget = Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        color: effectiveBgColor,
        shape: BoxShape.circle,
        border: showBorder
            ? Border.all(
                color: effectiveBorderColor,
                width: borderWidth,
              )
            : null,
        boxShadow: boxShadow,
      ),
      child: ClipOval(
        child: Image.asset(
          assetPath,
          width: size,
          height: size,
          fit: BoxFit.cover,
          errorBuilder: (context, error, stackTrace) {
            // Fallback gracefully to default avatar asset or person icon if missing
            return Image.asset(
              UserModel.avatarAssetPath(UserModel.defaultAvatarId),
              width: size,
              height: size,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => Center(
                child: Icon(
                  Icons.person,
                  size: size * 0.6,
                  color: AquaColors.accent,
                ),
              ),
            );
          },
        ),
      ),
    );

    if (onTap != null) {
      return GestureDetector(
        onTap: onTap,
        behavior: HitTestBehavior.opaque,
        child: avatarWidget,
      );
    }

    return avatarWidget;
  }
}

