import 'package:flutter/material.dart';
import '../../models/community_post.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';
import '../../widgets/community/post_card.dart';
import 'create_post_screen.dart';

/// Main community feed screen.
/// Displays a real-time stream of community posts ordered newest first.
class CommunityFeedScreen extends StatefulWidget {
  const CommunityFeedScreen({super.key});

  @override
  State<CommunityFeedScreen> createState() => _CommunityFeedScreenState();
}

class _CommunityFeedScreenState extends State<CommunityFeedScreen> {
  final CommunityService _svc = CommunityService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // ─── App bar ───
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                child: Row(
                  children: [
                    Container(
                      width: 36,
                      height: 36,
                      decoration: BoxDecoration(
                        color: AquaColors.accent.withValues(alpha: 0.15),
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: AquaColors.accent.withValues(alpha: 0.25),
                        ),
                      ),
                      child: Icon(
                        Icons.people_outline,
                        color: AquaColors.accent,
                        size: 18,
                      ),
                    ),
                    const SizedBox(width: 10),
                    Text(
                      'Community',
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.5,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Subtitle ───
            SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Aquarists Near You',
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        letterSpacing: -0.3,
                      ),
                    ),
                    SizedBox(height: 4),
                    Text(
                      'Share your aquarium with the community.',
                      style: TextStyle(
                        color: AquaColors.textSecondary,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // ─── Post feed ───
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 100),
              sliver: SliverToBoxAdapter(
                child: StreamBuilder<List<CommunityPost>>(
                  stream: _svc.feedStream(),
                  builder: (context, snap) {
                    if (snap.connectionState == ConnectionState.waiting) {
                      return Padding(
                        padding: EdgeInsets.symmetric(vertical: 60),
                        child: Center(
                          child: CircularProgressIndicator(color: AquaColors.accent),
                        ),
                      );
                    }

                    if (snap.hasError) {
                      return _buildErrorState(snap.error.toString());
                    }

                    final posts = snap.data ?? [];

                    if (posts.isEmpty) {
                      return _buildEmptyState();
                    }

                    return Column(
                      children: posts
                          .map((p) => PostCard(post: p))
                          .toList(),
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),

      // ─── Share FAB ───
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(bottom: 8, right: 4),
        child: GestureDetector(
          onTap: () => Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const CreatePostScreen()),
          ),
          child: Container(
            width: 54,
            height: 54,
            decoration: BoxDecoration(
              color: AquaColors.accent,
              borderRadius: BorderRadius.circular(18),
              boxShadow: [
                BoxShadow(
                  color: AquaColors.accent.withValues(alpha: 0.35),
                  blurRadius: 14,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: const Icon(Icons.add, color: Colors.white, size: 26),
          ),
        ),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endFloat,
    );
  }

  Widget _buildEmptyState() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Container(
            width: 76,
            height: 76,
            decoration: BoxDecoration(
              color: AquaColors.card,
              shape: BoxShape.circle,
              border: Border.all(color: AquaColors.border),
            ),
            child: Icon(Icons.people_outline, size: 36, color: AquaColors.textMuted),
          ),
          const SizedBox(height: 20),
          Text(
            'No Posts Yet',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 18,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Be the first to share your aquarium\nwith the community!',
            style: TextStyle(color: AquaColors.textSecondary, fontSize: 14),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 24),
          ElevatedButton.icon(
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const CreatePostScreen()),
            ),
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Share Aquarium'),
          ),
        ],
      ),
    );
  }

  Widget _buildErrorState(String error) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 60),
      child: Column(
        children: [
          Icon(Icons.error_outline, size: 48, color: AquaColors.error),
          const SizedBox(height: 16),
          Text(
            'Could not load the feed',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            error,
            style: TextStyle(color: AquaColors.textSecondary, fontSize: 12),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
