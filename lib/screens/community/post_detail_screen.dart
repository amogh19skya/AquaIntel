import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/community/like_button.dart';
import '../../widgets/community/comment_sheet.dart';

/// Full-detail view for a single [CommunityPost].
/// Shows the complete post, like button, comment count,
/// and owner actions (edit caption / delete post).
class PostDetailScreen extends StatefulWidget {
  final CommunityPost post;

  const PostDetailScreen({super.key, required this.post});

  @override
  State<PostDetailScreen> createState() => _PostDetailScreenState();
}

class _PostDetailScreenState extends State<PostDetailScreen> {
  final CommunityService _svc = CommunityService();
  late CommunityPost _post;

  @override
  void initState() {
    super.initState();
    _post = widget.post;
  }

  String get _currentUid => FirebaseAuth.instance.currentUser?.uid ?? '';
  bool get _isAuthor => _currentUid == _post.authorUid;

  String _formatDate(DateTime dt) =>
      DateFormat('d MMM yyyy, h:mm a').format(dt);

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.bg,
        iconTheme: const IconThemeData(color: AquaColors.textPrimary),
        title: const Text(
          'Post',
          style: TextStyle(color: AquaColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_isAuthor)
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, color: AquaColors.textMuted),
              color: AquaColors.cardElevated,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              itemBuilder: (_) => [
                const PopupMenuItem(
                  value: 'edit',
                  child: Row(children: [
                    Icon(Icons.edit_outlined, color: AquaColors.accent, size: 18),
                    SizedBox(width: 10),
                    Text('Edit caption',
                        style: TextStyle(color: AquaColors.textPrimary, fontSize: 13)),
                  ]),
                ),
                const PopupMenuItem(
                  value: 'delete',
                  child: Row(children: [
                    Icon(Icons.delete_outline, color: AquaColors.error, size: 18),
                    SizedBox(width: 10),
                    Text('Delete post',
                        style: TextStyle(color: AquaColors.error, fontSize: 13)),
                  ]),
                ),
              ],
              onSelected: (val) {
                if (val == 'edit') _showEditDialog(context);
                if (val == 'delete') _confirmDelete(context);
              },
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildAuthorRow(),
              const SizedBox(height: 16),
              if (_post.caption.isNotEmpty) ...[
                Text(
                  _post.caption,
                  style: const TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 15,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 16),
              ],
              _buildAquariumCard(),
              const SizedBox(height: 20),
              _buildActionRow(context),
              const SizedBox(height: 20),
              const Divider(color: AquaColors.border),
              const SizedBox(height: 8),
              Text(
                'Posted ${_formatDate(_post.createdAt)}',
                style: const TextStyle(color: AquaColors.textMuted, fontSize: 12),
              ),
              if (_post.updatedAt != _post.createdAt) ...[
                const SizedBox(height: 4),
                Text(
                  'Edited ${_formatDate(_post.updatedAt)}',
                  style: const TextStyle(color: AquaColors.textMuted, fontSize: 12),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Author row ───

  Widget _buildAuthorRow() {
    final initials = () {
      final parts = _post.authorName.trim().split(' ');
      if (parts.length >= 2) return '${parts[0][0]}${parts[1][0]}'.toUpperCase();
      return _post.authorName.isNotEmpty ? _post.authorName[0].toUpperCase() : '?';
    }();

    return Row(
      children: [
        Container(
          width: 46,
          height: 46,
          decoration: BoxDecoration(
            color: AquaColors.accent.withValues(alpha: 0.15),
            shape: BoxShape.circle,
            border: Border.all(color: AquaColors.accent.withValues(alpha: 0.25)),
          ),
          child: Center(
            child: Text(
              initials,
              style: const TextStyle(
                color: AquaColors.accent,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              _post.authorName,
              style: const TextStyle(
                color: AquaColors.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              _formatDate(_post.createdAt),
              style: const TextStyle(color: AquaColors.textMuted, fontSize: 12),
            ),
          ],
        ),
      ],
    );
  }

  // ─── Aquarium card ───

  Widget _buildAquariumCard() {
    final snap = _post.aquariumSnapshot;
    final visible = _post.visibleFields;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AquaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: AquaColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.water, color: AquaColors.accent, size: 18),
              ),
              const SizedBox(width: 10),
              const Text(
                'Shared Aquarium',
                style: TextStyle(
                  color: AquaColors.textSecondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          if (visible.contains('name')) ...[
            Text(
              snap.name,
              style: const TextStyle(
                color: AquaColors.textPrimary,
                fontSize: 17,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 6),
          ],
          if (visible.contains('type')) ...[
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 3),
              decoration: BoxDecoration(
                color: AquaColors.accent.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AquaColors.accent.withValues(alpha: 0.2)),
              ),
              child: Text(
                snap.type.toUpperCase(),
                style: const TextStyle(
                  color: AquaColors.accent,
                  fontSize: 10,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.5,
                ),
              ),
            ),
            const SizedBox(height: 12),
          ],
          if (visible.contains('volumeLitres')) ...[
            const Divider(color: AquaColors.border, height: 1),
            const SizedBox(height: 12),
            _detailRow(Icons.water_drop_outlined, 'Volume',
                '${snap.volumeLitres.toStringAsFixed(1)} L'),
          ],
          if (visible.contains('description') && snap.description.isNotEmpty) ...[
            const SizedBox(height: 10),
            _detailRow(Icons.notes_outlined, 'Description', snap.description),
          ],
        ],
      ),
    );
  }

  Widget _detailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AquaColors.accent, size: 16),
        const SizedBox(width: 8),
        Text(
          '$label: ',
          style: const TextStyle(color: AquaColors.textSecondary, fontSize: 13),
        ),
        Expanded(
          child: Text(
            value,
            style: const TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
            maxLines: 4,
            overflow: TextOverflow.ellipsis,
          ),
        ),
      ],
    );
  }

  // ─── Action row ───

  Widget _buildActionRow(BuildContext context) {
    return Row(
      children: [
        LikeButton(postId: _post.id),
        const SizedBox(width: 20),
        GestureDetector(
          onTap: () => CommentSheet.show(context, post: _post),
          behavior: HitTestBehavior.opaque,
          child: const Row(
            children: [
              Icon(Icons.chat_bubble_outline_rounded,
                  color: AquaColors.textMuted, size: 20),
              SizedBox(width: 6),
              Text(
                'Comments',
                style: TextStyle(color: AquaColors.textSecondary, fontSize: 13),
              ),
            ],
          ),
        ),
      ],
    );
  }

  // ─── Dialogs ───

  void _showEditDialog(BuildContext context) {
    final ctrl = TextEditingController(text: _post.caption);
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AquaColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text('Edit Caption',
            style: TextStyle(
                color: AquaColors.textPrimary, fontWeight: FontWeight.bold)),
        content: TextField(
          controller: ctrl,
          maxLength: 500,
          maxLines: 4,
          style: const TextStyle(color: AquaColors.textPrimary, fontSize: 14),
          decoration: const InputDecoration(
            hintText: "What's on your mind?",
            counterStyle: TextStyle(color: AquaColors.textMuted),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _svc.editCaption(_post.id, ctrl.text);
                if (mounted) {
                  setState(() => _post = _post.copyWith(
                        caption: ctrl.text.trim(),
                        updatedAt: DateTime.now(),
                      ));
                }
                messenger.showSnackBar(
                  const SnackBar(content: Text('Caption updated.')),
                );
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
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
        title: const Text('Delete Post?',
            style: TextStyle(
                color: AquaColors.textPrimary, fontWeight: FontWeight.bold)),
        content: const Text(
          'This permanently deletes your post, all likes and all comments.',
          style: TextStyle(
              color: AquaColors.textSecondary, fontSize: 14, height: 1.5),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AquaColors.error),
            onPressed: () async {
              Navigator.pop(ctx);
              final nav = Navigator.of(context);
              final messenger = ScaffoldMessenger.of(context);
              try {
                await _svc.deletePost(_post.id);
                if (mounted) nav.pop();
              } catch (e) {
                messenger.showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
