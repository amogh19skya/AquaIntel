import 'package:flutter/material.dart';
import '../../models/aquarium_model.dart';
import '../../services/aquarium_service.dart';
import '../../services/community_service.dart';
import '../../theme/app_theme.dart';

/// Two-step screen for creating a community post.
///
/// Step 1 — Aquarium selection (skipped if [initialAquarium] is provided).
/// Step 2 — Caption entry + visible-field toggles + preview + publish.
///
/// Aquarium ownership is enforced both client-side (AquariumService always
/// scopes to `users/{currentUid}/aquariums`) and server-side by Firestore
/// Security Rules (`exists(/users/{uid}/aquariums/{aquariumId})`).
class CreatePostScreen extends StatefulWidget {
  /// Pre-selects an aquarium when navigating from AquariumDetailsScreen.
  final AquariumModel? initialAquarium;

  const CreatePostScreen({super.key, this.initialAquarium});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final AquariumService _aquariumSvc = AquariumService();
  final CommunityService _communitySvc = CommunityService();
  final TextEditingController _captionCtrl = TextEditingController();

  AquariumModel? _selected;
  // ignore: prefer_final_fields
  Set<String> _visibleFields = {'name', 'type', 'volumeLitres'};
  bool _publishing = false;

  static const _allFields = [
    ('name', 'Tank Name'),
    ('type', 'Tank Type'),
    ('volumeLitres', 'Volume'),
    ('description', 'Description'),
  ];

  @override
  void initState() {
    super.initState();
    _selected = widget.initialAquarium;
  }

  @override
  void dispose() {
    _captionCtrl.dispose();
    super.dispose();
  }

  // ─── Publish ───

  Future<void> _publish() async {
    if (_selected == null) return;
    final caption = _captionCtrl.text.trim();
    if (caption.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter a caption.')),
      );
      return;
    }
    if (_visibleFields.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Select at least one detail to share.')),
      );
      return;
    }

    setState(() => _publishing = true);
    try {
      await _communitySvc.createPost(
        aquarium: _selected!,
        caption: caption,
        visibleFields: _visibleFields.toList(),
      );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Post shared with the community! 🐟')),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _publishing = false);
    }
  }

  // ─── Build ───

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.bg,
        iconTheme: IconThemeData(color: AquaColors.textPrimary),
        title: Text(
          'Share Aquarium',
          style: TextStyle(color: AquaColors.textPrimary, fontWeight: FontWeight.w600),
        ),
        actions: [
          if (_selected != null)
            Padding(
              padding: const EdgeInsets.only(right: 16),
              child: _publishing
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                          color: AquaColors.accent, strokeWidth: 2),
                    )
                  : TextButton(
                      onPressed: _publish,
                      child: Text(
                        'Post',
                        style: TextStyle(
                          color: AquaColors.accent,
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
            ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Step 1: Aquarium picker ───
              _buildSectionLabel('Select Aquarium'),
              const SizedBox(height: 12),
              _buildAquariumPicker(),

              if (_selected != null) ...[
                const SizedBox(height: 28),

                // ─── Step 2: Visible fields ───
                _buildSectionLabel('What to share'),
                const SizedBox(height: 4),
                Text(
                  'Choose which details will appear in your post.',
                  style: TextStyle(color: AquaColors.textSecondary, fontSize: 13),
                ),
                const SizedBox(height: 12),
                _buildFieldToggles(),

                const SizedBox(height: 28),

                // ─── Step 3: Caption ───
                _buildSectionLabel('Caption'),
                const SizedBox(height: 12),
                _buildCaptionField(),

                const SizedBox(height: 28),

                // ─── Step 4: Preview ───
                _buildSectionLabel('Preview'),
                const SizedBox(height: 12),
                _buildPreview(),

                const SizedBox(height: 32),

                // ─── Publish button ───
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: _publishing ? null : _publish,
                    icon: _publishing
                        ? const SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                                color: Colors.white, strokeWidth: 2),
                          )
                        : const Icon(Icons.public, size: 18),
                    label: Text(_publishing ? 'Publishing…' : 'Share with Community'),
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  // ─── Section label ───

  Widget _buildSectionLabel(String text) {
    return Text(
      text,
      style: TextStyle(
        color: AquaColors.textPrimary,
        fontSize: 16,
        fontWeight: FontWeight.bold,
      ),
    );
  }

  // ─── Aquarium picker ───

  Widget _buildAquariumPicker() {
    return StreamBuilder<List<AquariumModel>>(
      stream: _aquariumSvc.getAquariums(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: AquaColors.accent),
          );
        }
        final aquariums = snap.data ?? [];
        if (aquariums.isEmpty) {
          return Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AquaColors.card,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AquaColors.border),
            ),
            child: Text(
              'You have no aquariums yet. Add one from the Dashboard first.',
              style: TextStyle(color: AquaColors.textSecondary, fontSize: 14),
              textAlign: TextAlign.center,
            ),
          );
        }
        return Column(
          children: aquariums.map((a) => _buildAquariumOption(a)).toList(),
        );
      },
    );
  }

  Widget _buildAquariumOption(AquariumModel a) {
    final isSelected = _selected?.id == a.id;
    return GestureDetector(
      onTap: () => setState(() => _selected = a),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: isSelected
              ? AquaColors.accent.withValues(alpha: 0.08)
              : AquaColors.card,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: isSelected ? AquaColors.accent : AquaColors.border,
            width: isSelected ? 1.5 : 1,
          ),
        ),
        child: Row(
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                color: AquaColors.accent.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.water, color: AquaColors.accent, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    a.name,
                    style: TextStyle(
                      color: AquaColors.textPrimary,
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    '${a.type}  ·  ${a.volumeLitres.toStringAsFixed(1)} L',
                    style: TextStyle(
                      color: AquaColors.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                ],
              ),
            ),
            if (isSelected)
              Icon(Icons.check_circle, color: AquaColors.accent, size: 20),
          ],
        ),
      ),
    );
  }

  // ─── Field toggles ───

  Widget _buildFieldToggles() {
    return Wrap(
      spacing: 8,
      runSpacing: 8,
      children: _allFields.map(((String key, String label) field) {
        final selected = _visibleFields.contains(field.$1);
        return GestureDetector(
          onTap: () => setState(() {
            if (selected) {
              _visibleFields.remove(field.$1);
            } else {
              _visibleFields.add(field.$1);
            }
          }),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 180),
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              color: selected
                  ? AquaColors.accent.withValues(alpha: 0.12)
                  : AquaColors.card,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(
                color: selected ? AquaColors.accent : AquaColors.border,
                width: selected ? 1.5 : 1,
              ),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (selected)
                  Padding(
                    padding: EdgeInsets.only(right: 6),
                    child: Icon(Icons.check, color: AquaColors.accent, size: 14),
                  ),
                Text(
                  field.$2,
                  style: TextStyle(
                    color: selected ? AquaColors.accent : AquaColors.textSecondary,
                    fontSize: 13,
                    fontWeight: selected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  // ─── Caption field ───

  Widget _buildCaptionField() {
    // NOTE: Do NOT call setState here. Flutter's built-in maxLength counter
    // updates itself without a rebuild. Adding onChanged: setState caused a
    // full-screen rebuild on every keystroke — the primary cause of the shake.
    return TextField(
      controller: _captionCtrl,
      maxLength: 500,
      minLines: 4,
      maxLines: 6,
      style: TextStyle(color: AquaColors.textPrimary, fontSize: 14),
      decoration: InputDecoration(
        hintText: "Tell the community about your tank…",
        counterStyle: TextStyle(color: AquaColors.textMuted),
      ),
    );
  }

  // ─── Preview card ───

  Widget _buildPreview() {
    if (_selected == null) return const SizedBox.shrink();
    final a = _selected!;
    return Container(
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AquaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Caption preview — scoped to ValueListenableBuilder so only this
          // Text widget rebuilds on each keystroke, not the whole screen.
          // The ConstrainedBox gives the area a stable minimum height so the
          // card does not jump when the field is empty or when text wraps.
          ValueListenableBuilder<TextEditingValue>(
            valueListenable: _captionCtrl,
            builder: (context, value, _) {
              final trimmed = value.text.trim();
              return ConstrainedBox(
                constraints: const BoxConstraints(minHeight: 24),
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 16, 16, 0),
                  child: Text(
                    trimmed,
                    style: TextStyle(
                      color: trimmed.isEmpty
                          ? AquaColors.textMuted
                          : AquaColors.textPrimary,
                      fontSize: 14,
                      height: 1.5,
                      fontStyle: trimmed.isEmpty ? FontStyle.italic : FontStyle.normal,
                    ),
                  ),
                ),
              );
            },
          ),
          // Aquarium detail preview
          Padding(
            padding: const EdgeInsets.all(16),
            child: Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: AquaColors.bg,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AquaColors.border),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_visibleFields.contains('name'))
                    Text(
                      a.name,
                      style: TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  if (_visibleFields.contains('type')) ...[
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AquaColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        a.type.toUpperCase(),
                        style: TextStyle(
                          color: AquaColors.accent,
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                  if (_visibleFields.contains('volumeLitres')) ...[
                    const SizedBox(height: 8),
                    Text(
                      'Volume: ${a.volumeLitres.toStringAsFixed(1)} L',
                      style: TextStyle(
                        color: AquaColors.textSecondary,
                        fontSize: 12,
                      ),
                    ),
                  ],
                  if (_visibleFields.contains('description') &&
                      a.description.isNotEmpty) ...[
                    const SizedBox(height: 6),
                    Text(
                      a.description,
                      style: TextStyle(
                        color: AquaColors.textSecondary,
                        fontSize: 12,
                      ),
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                  if (_visibleFields.isEmpty)
                    Text(
                      'No details selected.',
                      style: TextStyle(color: AquaColors.textMuted, fontSize: 12),
                    ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
