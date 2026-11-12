import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/user_model.dart';
import '../services/user_service.dart';
import '../theme/app_theme.dart';
import '../widgets/user_avatar.dart';

/// Full-screen Avatar Selection screen featuring 20 3D cartoon avatars.
///
/// Provides:
/// - A responsive grid of all 20 avatars.
/// - Live top profile preview of the selected character.
/// - Cyan border highlight with checkmark badge on selected avatar.
/// - Smooth selection bounce animation.
/// - Save Changes and Cancel actions.
/// - Unsaved changes guard (dialog on back if selection was modified).
class AvatarSelectionScreen extends StatefulWidget {
  final String? initialAvatarId;
  final String? userName;

  const AvatarSelectionScreen({
    super.key,
    this.initialAvatarId,
    this.userName,
  });

  @override
  State<AvatarSelectionScreen> createState() => _AvatarSelectionScreenState();
}

class _AvatarSelectionScreenState extends State<AvatarSelectionScreen>
    with SingleTickerProviderStateMixin {
  late String _selectedAvatarId;
  late String _savedAvatarId;
  bool _isSaving = false;
  final UserService _userService = UserService();

  late AnimationController _previewAnimController;
  late Animation<double> _previewScaleAnim;

  @override
  void initState() {
    super.initState();
    _savedAvatarId = UserModel.sanitizeAvatarId(widget.initialAvatarId);
    _selectedAvatarId = _savedAvatarId;

    _previewAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );
    _previewScaleAnim = Tween<double>(begin: 0.92, end: 1.0).animate(
      CurvedAnimation(
        parent: _previewAnimController,
        curve: Curves.easeOutBack,
      ),
    );
    _previewAnimController.forward();
  }

  @override
  void dispose() {
    _previewAnimController.dispose();
    super.dispose();
  }

  bool get _hasUnsavedChanges => _selectedAvatarId != _savedAvatarId;

  void _onAvatarTapped(String avatarId) {
    if (_selectedAvatarId == avatarId) return;

    HapticFeedback.lightImpact();
    setState(() {
      _selectedAvatarId = avatarId;
    });

    _previewAnimController.reset();
    _previewAnimController.forward();
  }

  Future<bool> _onWillPop() async {
    if (!_hasUnsavedChanges) return true;

    final discard = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AquaColors.card,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: AquaColors.border),
        ),
        title: Text(
          'Discard Avatar Changes?',
          style: TextStyle(
            color: AquaColors.textPrimary,
            fontWeight: FontWeight.w600,
            fontSize: 18,
          ),
        ),
        content: Text(
          'You have selected a new avatar without saving. Are you sure you want to exit?',
          style: TextStyle(
            color: AquaColors.textSecondary,
            fontSize: 14,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: Text(
              'Keep Editing',
              style: TextStyle(color: AquaColors.textSecondary),
            ),
          ),
          ElevatedButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            style: ElevatedButton.styleFrom(
              backgroundColor: AquaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Discard'),
          ),
        ],
      ),
    );

    return discard ?? false;
  }

  Future<void> _handleBackNavigation() async {
    final navigator = Navigator.of(context);
    final shouldPop = await _onWillPop();
    if (shouldPop) {
      navigator.pop();
    }
  }

  Future<void> _handleSave() async {
    if (_isSaving) return;

    HapticFeedback.mediumImpact();
    setState(() => _isSaving = true);

    try {
      await _userService.updateAvatarId(_selectedAvatarId);
      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Avatar updated successfully! ✓'),
          backgroundColor: AquaColors.cardElevated,
          behavior: SnackBarBehavior.floating,
          duration: Duration(seconds: 2),
        ),
      );

      Navigator.of(context).pop(_selectedAvatarId);
    } catch (e) {
      if (!mounted) return;
      setState(() => _isSaving = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to save avatar: $e'),
          backgroundColor: AquaColors.error,
          behavior: SnackBarBehavior.floating,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: !_hasUnsavedChanges,
      onPopInvokedWithResult: (didPop, _) {
        if (didPop) return;
        _handleBackNavigation();
      },
      child: Scaffold(
        backgroundColor: AquaColors.bg,
        appBar: AppBar(
          backgroundColor: AquaColors.bg,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios_new, color: AquaColors.textSecondary, size: 20),
            onPressed: _handleBackNavigation,
          ),
          title: Text(
            'Choose Your Avatar',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
          centerTitle: true,
        ),
        body: Column(
          children: [
            // Subtitle
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20, vertical: 4),
              child: Text(
                'Select a character that represents you.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: AquaColors.textSecondary,
                  fontSize: 14,
                ),
              ),
            ),

            const SizedBox(height: 12),

            // Live Preview Card
            _buildLivePreviewCard(),

            const SizedBox(height: 16),

            // Responsive Avatar Grid
            Expanded(
              child: _buildAvatarGrid(),
            ),

            // Bottom Actions: Cancel and Save Changes
            _buildBottomActionBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildLivePreviewCard() {
    final avatarNumber = _selectedAvatarId.replaceAll('avatar_', '');

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: AquaColors.accent.withValues(alpha: 0.35),
          width: 1.5,
        ),
        boxShadow: [
          BoxShadow(
            color: AquaColors.accent.withValues(alpha: 0.12),
            blurRadius: 18,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          ScaleTransition(
            scale: _previewScaleAnim,
            child: Container(
              padding: const EdgeInsets.all(3.5),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: const LinearGradient(
                  colors: [AquaColors.accent, AquaColors.accentDim],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                boxShadow: [
                  BoxShadow(
                    color: AquaColors.accent.withValues(alpha: 0.4),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: UserAvatar(
                avatarId: _selectedAvatarId,
                size: 68,
                backgroundColor: AquaColors.bgSecondary,
              ),
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  widget.userName != null && widget.userName!.trim().isNotEmpty
                      ? widget.userName!
                      : 'Aquarist Profile',
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: AquaColors.textPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AquaColors.accent.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Text(
                    'Character #$avatarNumber',
                    style: TextStyle(
                      color: AquaColors.accent,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          if (_hasUnsavedChanges)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: AquaColors.accent.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                'Modified',
                style: TextStyle(
                  color: AquaColors.accent,
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildAvatarGrid() {
    final avatarIds = UserModel.allAvatarIds;

    return LayoutBuilder(
      builder: (context, constraints) {
        // Compute cross axis count based on screen width (4 on small phones, 5 on wider)
        final crossAxisCount = constraints.maxWidth > 420 ? 5 : 4;

        return GridView.builder(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 16),
          physics: const BouncingScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: crossAxisCount,
            crossAxisSpacing: 14,
            mainAxisSpacing: 14,
            childAspectRatio: 1.0,
          ),
          itemCount: avatarIds.length,
          itemBuilder: (context, index) {
            final avatarId = avatarIds[index];
            final isSelected = avatarId == _selectedAvatarId;

            return _buildAvatarGridItem(avatarId, isSelected);
          },
        );
      },
    );
  }

  Widget _buildAvatarGridItem(String avatarId, bool isSelected) {
    return GestureDetector(
      onTap: () => _onAvatarTapped(avatarId),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        curve: Curves.easeInOut,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AquaColors.card,
          border: Border.all(
            color: isSelected ? AquaColors.accent : AquaColors.border,
            width: isSelected ? 3.0 : 1.2,
          ),
          boxShadow: isSelected
              ? [
                  BoxShadow(
                    color: AquaColors.accent.withValues(alpha: 0.45),
                    blurRadius: 10,
                    offset: const Offset(0, 2),
                  ),
                ]
              : [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.2),
                    blurRadius: 4,
                    offset: const Offset(0, 2),
                  ),
                ],
        ),
        child: Stack(
          alignment: Alignment.center,
          children: [
            // Circular Avatar Image
            Padding(
              padding: const EdgeInsets.all(2.0),
              child: ClipOval(
                child: Image.asset(
                  UserModel.avatarAssetPath(avatarId),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                  errorBuilder: (_, __, ___) => Icon(
                    Icons.person,
                    color: AquaColors.textSecondary,
                  ),
                ),
              ),
            ),

            // Checkmark overlay badge on selected avatar
            if (isSelected)
              Positioned(
                bottom: 2,
                right: 2,
                child: Container(
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: AquaColors.accent,
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                    Icons.check,
                    color: AquaColors.bg,
                    size: 15,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomActionBar() {
    return Container(
      padding: EdgeInsets.fromLTRB(
        20,
        14,
        20,
        14 + MediaQuery.of(context).padding.bottom,
      ),
      decoration: BoxDecoration(
        color: AquaColors.card,
        border: Border(
          top: BorderSide(
            color: AquaColors.border.withValues(alpha: 0.8),
          ),
        ),
      ),
      child: Row(
        children: [
          // Cancel button
          Expanded(
            flex: 1,
            child: OutlinedButton(
              onPressed: _handleBackNavigation,
              style: OutlinedButton.styleFrom(
                foregroundColor: AquaColors.textSecondary,
                side: BorderSide(color: AquaColors.border),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
              ),
              child: Text(
                'Cancel',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),

          const SizedBox(width: 14),

          // Save Changes button
          Expanded(
            flex: 2,
            child: ElevatedButton(
              onPressed: _isSaving ? null : _handleSave,
              style: ElevatedButton.styleFrom(
                backgroundColor: AquaColors.accent,
                foregroundColor: AquaColors.bg,
                disabledBackgroundColor: AquaColors.accent.withValues(alpha: 0.5),
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 3,
              ),
              child: _isSaving
                  ? SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(AquaColors.bg),
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
            ),
          ),
        ],
      ),
    );
  }
}
