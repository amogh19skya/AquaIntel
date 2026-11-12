import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';
import 'author_avatar.dart';
import 'like_button.dart';
import 'comment_sheet.dart';

/// Feed card for a single [CommunityPost].
/// Shows: author, time, caption, aquarium preview (respecting visibleFields),
/// like button (live stream), comment count (AggregateQuery), and owner actions.
class PostCard extends StatelessWidget {
  final CommunityPost post;
  final VoidCallback? onDeleted;

  const PostCard({
    super.key,
    required this.post,
    this.onDeleted,
  });

  // ─── Helpers ───

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inSeconds < 60) return 'just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    if (diff.inDays < 7) return '${diff.inDays}d ago';
    return DateFormat('d MMM').format(dt);
  }


  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    final currentUid = FirebaseAuth.instance.currentUser?.uid;
    final isAuthor = currentUid == post.authorUid;

    return Container(
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AquaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.18),
            blurRadius: 12,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _buildHeader(context, isAuthor),
          if (post.caption.isNotEmpty) _buildCaption(),
          _buildAquariumPreview(),
          _buildActionRow(context),
        ],
      ),
    );
  }

  // ─── Header (avatar + author + time + menu) ───

  Widget _buildHeader(BuildContext context, bool isAuthor) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 8, 12),
      child: Row(
        children: [
          // Avatar
          AuthorAvatar(
            authorUid: post.authorUid,
            authorName: post.authorName,
            size: 40,
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  post.authorName,
                  style: TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  _timeAgo(post.createdAt),
                  style: TextStyle(
                    color: AquaColors.textMuted,
                    fontSize: 11,
                  ),
                ),
              ],
            ),
          ),
          if (isAuthor) _buildOwnerMenu(context),
        ],
      ),
    );
  }

  Widget _buildOwnerMenu(BuildContext context) {
    return PopupMenuButton<String>(
      icon: Icon(Icons.more_horiz, color: AquaColors.textMuted, size: 20),
      color: AquaColors.cardElevated,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      itemBuilder: (_) => [
        PopupMenuItem(
          value: 'edit',
          child: Row(children: [
            Icon(Icons.edit_outlined, color: AquaColors.accent, size: 18),
            SizedBox(width: 10),
            Text('Edit caption', style: TextStyle(color: AquaColors.textPrimary, fontSize: 13)),
          ]),
        ),
        const PopupMenuItem(
          value: 'delete',
          child: Row(children: [
            Icon(Icons.delete_outline, color: AquaColors.error, size: 18),
            SizedBox(width: 10),
            Text('Delete post', style: TextStyle(color: AquaColors.error, fontSize: 13)),
          ]),
        ),
      ],
      onSelected: (val) {
        if (val == 'edit') _showEditDialog(context);
        if (val == 'delete') _confirmDelete(context);
      },
    );
  }

  // ─── Caption ───

  Widget _buildCaption() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      child: Text(
        post.caption,
        style: TextStyle(
          color: AquaColors.textPrimary,
          fontSize: 14,
          height: 1.5,
        ),
      ),
    );
  }

  // ─── Aquarium preview ───

  Widget _buildAquariumPreview() {
    final snap = post.aquariumSnapshot;
    final visible = post.visibleFields;

    return Container(
      margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AquaColors.bg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AquaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Type badge + name
          Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: AquaColors.accent.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.water, color: AquaColors.accent, size: 16),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    if (visible.contains('name'))
                      Text(
                        snap.name,
                        style: TextStyle(
                          color: AquaColors.textPrimary,
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    if (visible.contains('type'))
                      Container(
                        margin: const EdgeInsets.only(top: 2),
                        padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                        decoration: BoxDecoration(
                          color: AquaColors.accent.withValues(alpha: 0.1),
                          borderRadius: BorderRadius.circular(20),
                          border: Border.all(color: AquaColors.accent.withValues(alpha: 0.2)),
                        ),
                        child: Text(
                          snap.type.toUpperCase(),
                          style: TextStyle(
                            color: AquaColors.accent,
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
          // Detail rows
          if (visible.contains('volumeLitres')) ...[
            const SizedBox(height: 10),
            Divider(color: AquaColors.border, height: 1),
            const SizedBox(height: 10),
            _detailRow('Volume', '${snap.volumeLitres.toStringAsFixed(1)} L'),
          ],
          if (visible.contains('description') && snap.description.isNotEmpty) ...[
            const SizedBox(height: 8),
            _detailRow('Note', snap.description, multiLine: true),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(String label, String value, {bool multiLine = false}) {
    return Row(
      crossAxisAlignment:
          multiLine ? CrossAxisAlignment.start : CrossAxisAlignment.center,
      children: [
        Text(
          '$label: ',
          style: TextStyle(color: AquaColors.textMuted, fontSize: 12),
        ),
        Expanded(
          child: Text(
            value,
            style: TextStyle(
              color: AquaColors.textSecondary,
              fontSize: 12,
              fontWeight: FontWeight.w500,
            ),
            maxLines: multiLine ? 3 : 1,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─── Action row ───

  Widget _buildActionRow(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 14),
      child: Row(
        children: [
          LikeButton(postId: post.id, compact: true),
          const SizedBox(width: 18),
          _CommentCountButton(
            postId: post.id,
            onTap: () => CommentSheet.show(context, post: post),
          ),
        ],
      ),
    );
  }

  // ─── Dialogs ───

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: post.caption);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AquaColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Edit Caption',
            style: TextStyle(color: AquaColors.textPrimary, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLength: 500,
          maxLines: 4,
          style: TextStyle(color: AquaColors.textPrimary, fontSize: 14),
          decoration: InputDecoration(
            hintText: 'What\'s on your mind?',
            counterStyle: TextStyle(color: AquaColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await CommunityService().editCaption(post.id, ctrl.text);
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Caption updated.')),
                  );
                }
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Save'),
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
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: Text('Delete Post?',
            style: TextStyle(color: AquaColors.textPrimary, fontWeight: FontWeight.bold)),
        content: Text(
          'This will permanently delete your post, all likes and all comments. This cannot be undone.',
          style: TextStyle(color: AquaColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AquaColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              try {
                await CommunityService().deletePost(post.id);
                onDeleted?.call();
              } catch (e) {
                if (context.mounted) {
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text('Error: $e')),
                  );
                }
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}

// ─── Comment count button ─────────────────────────────────────────────────────

/// Listens to the comments subcollection in real time so the count updates
/// immediately when any user adds or deletes a comment, without any schema
/// change to the post document. Mirrors the pattern used by [LikeButton].
class _CommentCountButton extends StatelessWidget {
  final String postId;
  final VoidCallback onTap;

  const _CommentCountButton({required this.postId, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      behavior: HitTestBehavior.opaque,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.chat_bubble_outline_rounded,
              color: AquaColors.textMuted, size: 18),
          const SizedBox(width: 5),
          StreamBuilder<int>(
            stream: CommunityService().commentCountStream(postId),
            builder: (context, snap) => Text(
              snap.hasData ? '${snap.data}' : '--',
              style: TextStyle(
                color: AquaColors.textSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
