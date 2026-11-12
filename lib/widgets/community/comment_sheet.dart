import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';
import 'author_avatar.dart';

/// Modal bottom sheet that displays and allows adding/deleting comments
/// for a given [CommunityPost].
///
/// Usage: `CommentSheet.show(context, post: post);`
class CommentSheet extends StatefulWidget {
  final CommunityPost post;

  const CommentSheet({super.key, required this.post});

  static Future<void> show(BuildContext context, {required CommunityPost post}) {
    return showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => CommentSheet(post: post),
    );
  }

  @override
  State<CommentSheet> createState() => _CommentSheetState();
}

class _CommentSheetState extends State<CommentSheet> {
  final CommunityService _svc = CommunityService();
  final TextEditingController _ctrl = TextEditingController();
  final FocusNode _focus = FocusNode();
  bool _sending = false;

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';

  @override
  void dispose() {
    _ctrl.dispose();
    _focus.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _ctrl.text.trim();
    if (text.isEmpty) return;
    setState(() => _sending = true);
    try {
      await _svc.addComment(widget.post.id, text);
      _ctrl.clear();
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  Future<void> _deleteComment(String commentId) async {
    try {
      await _svc.deleteComment(widget.post.id, commentId);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottom = MediaQuery.of(context).viewInsets.bottom;

    return Container(
      margin: const EdgeInsets.fromLTRB(0, 60, 0, 0),
      decoration: BoxDecoration(
        color: AquaColors.bgSecondary,
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 12, bottom: 6),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: AquaColors.border,
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          // Header
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 6, 20, 12),
            child: Row(
              children: [
                Text(
                  'Comments',
                  style: TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const Spacer(),
                GestureDetector(
                  onTap: () => Navigator.pop(context),
                  child: Icon(Icons.close, color: AquaColors.textMuted, size: 20),
                ),
              ],
            ),
          ),
          Divider(color: AquaColors.border, height: 1),
          // Comment list
          Expanded(
            child: StreamBuilder<List<PostComment>>(
              stream: _svc.commentsStream(widget.post.id),
              builder: (context, snap) {
                if (snap.connectionState == ConnectionState.waiting) {
                  return const Center(
                    child: CircularProgressIndicator(color: AquaColors.accent),
                  );
                }
                final comments = snap.data ?? [];
                if (comments.isEmpty) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          Icons.chat_bubble_outline,
                          color: AquaColors.textMuted,
                          size: 40,
                        ),
                        const SizedBox(height: 12),
                        Text(
                          'No comments yet.\nBe the first to comment!',
                          style: TextStyle(
                            color: AquaColors.textSecondary,
                            fontSize: 14,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  );
                }
                return ListView.separated(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  itemCount: comments.length,
                  separatorBuilder: (_, __) => Divider(
                    color: AquaColors.border,
                    height: 1,
                    indent: 48,
                  ),
                  itemBuilder: (_, i) => _CommentTile(
                    comment: comments[i],
                    isOwn: comments[i].authorUid == _currentUid,
                    onDelete: () => _deleteComment(comments[i].id),
                  ),
                );
              },
            ),
          ),
          // Input row
          Container(
            padding: EdgeInsets.fromLTRB(16, 10, 16, 16 + bottom),
            decoration: BoxDecoration(
              color: AquaColors.bgSecondary,
              border: Border(top: BorderSide(color: AquaColors.border)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    focusNode: _focus,
                    maxLength: 1000,
                    maxLines: null,
                    style: TextStyle(
                      color: AquaColors.textPrimary,
                      fontSize: 14,
                    ),
                    decoration: InputDecoration(
                      hintText: 'Add a comment…',
                      counterText: '',
                      contentPadding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    textInputAction: TextInputAction.send,
                    onSubmitted: (_) => _send(),
                  ),
                ),
                const SizedBox(width: 10),
                AnimatedSwitcher(
                  duration: const Duration(milliseconds: 200),
                  child: _sending
                      ? const SizedBox(
                          width: 36,
                          height: 36,
                          child: CircularProgressIndicator(
                            color: AquaColors.accent,
                            strokeWidth: 2,
                          ),
                        )
                      : GestureDetector(
                          onTap: _send,
                          child: Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: AquaColors.accent,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.send_rounded,
                              color: Colors.white,
                              size: 18,
                            ),
                          ),
                        ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Single comment tile ──────────────────────────────────────────────────────

class _CommentTile extends StatelessWidget {
  final PostComment comment;
  final bool isOwn;
  final VoidCallback onDelete;

  const _CommentTile({
    required this.comment,
    required this.isOwn,
    required this.onDelete,
  });


  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return '${diff.inDays}d ago';
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Avatar
          AuthorAvatar(
            authorUid: comment.authorUid,
            authorName: comment.authorName,
            size: 32,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Text(
                      comment.authorName,
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    const SizedBox(width: 6),
                    Text(
                      _timeAgo(comment.createdAt),
                      style: TextStyle(
                        color: AquaColors.textMuted,
                        fontSize: 11,
                      ),
                    ),
                    if (isOwn) ...[
                      const Spacer(),
                      GestureDetector(
                        onTap: () => _confirmDelete(context),
                        child: Icon(
                          Icons.delete_outline,
                          color: AquaColors.error,
                          size: 16,
                        ),
                      ),
                    ],
                  ],
                ),
                const SizedBox(height: 4),
                Text(
                  comment.text,
                  style: TextStyle(
                    color: AquaColors.textSecondary,
                    fontSize: 13,
                    height: 1.4,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AquaColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text('Delete comment?',
            style: TextStyle(color: AquaColors.textPrimary, fontSize: 16, fontWeight: FontWeight.bold)),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AquaColors.error),
            onPressed: () {
              Navigator.pop(ctx);
              onDelete();
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
