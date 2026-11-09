import 'package:flutter/material.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';

/// Animated heart button that reads like state and count from [CommunityService.likesStream].
/// Uses a single subcollection stream so liked-state and count are always in sync.
class LikeButton extends StatefulWidget {
  final String postId;
  final bool compact;

  const LikeButton({
    super.key,
    required this.postId,
    this.compact = false,
  });

  @override
  State<LikeButton> createState() => _LikeButtonState();
}

class _LikeButtonState extends State<LikeButton>
    with SingleTickerProviderStateMixin {
  final CommunityService _svc = CommunityService();
  late AnimationController _ctrl;
  late Animation<double> _scale;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 140),
      lowerBound: 0.80,
      upperBound: 1.0,
      value: 1.0,
    );
    _scale = CurvedAnimation(parent: _ctrl, curve: Curves.easeOut);
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onTap(bool currentlyLiked) async {
    if (_busy) return;
    setState(() => _busy = true);
    // Bounce animation
    await _ctrl.reverse();
    _ctrl.forward();
    try {
      await _svc.toggleLike(widget.postId, currentlyLiked: currentlyLiked);
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update like. Try again.')),
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<LikesState>(
      stream: _svc.likesStream(widget.postId),
      builder: (context, snap) {
        final liked = snap.data?.isLiked ?? false;
        final count = snap.data?.count ?? 0;
        final loading = snap.connectionState == ConnectionState.waiting;

        return ScaleTransition(
          scale: _scale,
          child: GestureDetector(
            onTap: loading || _busy ? null : () => _onTap(liked),
            behavior: HitTestBehavior.opaque,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  transitionBuilder: (child, anim) =>
                      ScaleTransition(scale: anim, child: child),
                  child: Icon(
                    liked ? Icons.favorite_rounded : Icons.favorite_border_rounded,
                    key: ValueKey(liked),
                    color: liked
                        ? const Color(0xFFE05555)
                        : AquaColors.textMuted,
                    size: widget.compact ? 18 : 20,
                  ),
                ),
                const SizedBox(width: 5),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 180),
                  child: Text(
                    '$count',
                    key: ValueKey(count),
                    style: TextStyle(
                      color: AquaColors.textSecondary,
                      fontSize: widget.compact ? 12 : 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
