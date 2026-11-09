import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/aquarium_model.dart';
import '../../services/aquarium_service.dart';
import '../../theme/app_theme.dart';
import 'edit_aquarium_screen.dart';
import '../community/create_post_screen.dart';

/// Full-detail view of a single aquarium.
class AquariumDetailsScreen extends StatelessWidget {
  final AquariumModel aquarium;
  final IAquariumService aquariumService;

  AquariumDetailsScreen({
    super.key,
    required this.aquarium,
    IAquariumService? aquariumService,
  }) : aquariumService = aquariumService ?? AquariumService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AquaColors.bg,
      appBar: AppBar(
        backgroundColor: AquaColors.bg,
        elevation: 0,
        iconTheme: const IconThemeData(color: AquaColors.textPrimary),
        title: Text(
          aquarium.name,
          style: const TextStyle(
            color: AquaColors.textPrimary,
            fontWeight: FontWeight.w600,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: AquaColors.accent),
            tooltip: 'Edit Aquarium',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => EditAquariumScreen(aquarium: aquarium),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.people_outline, color: AquaColors.accent),
            tooltip: 'Share to Community',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (_) => CreatePostScreen(initialAquarium: aquarium),
                ),
              );
            },
          ),
          IconButton(
            icon: const Icon(Icons.delete_outline, color: AquaColors.error),
            tooltip: 'Delete Aquarium',
            onPressed: () => _confirmDelete(context),
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ─── Aquarium Image (if present) ───
              if (aquarium.imageUrl != null && aquarium.imageUrl!.trim().isNotEmpty) ...[
                ClipRRect(
                  borderRadius: BorderRadius.circular(20),
                  child: AspectRatio(
                    aspectRatio: 16 / 9,
                    child: Image.network(
                      aquarium.imageUrl!,
                      fit: BoxFit.cover,
                      errorBuilder: (_, __, ___) => const SizedBox.shrink(),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
              ],
              // ─── Hero Card ───
              _buildHeroCard(),
              const SizedBox(height: 20),
              // ─── Details Card ───
              _buildDetailsCard(),
              const SizedBox(height: 20),
              // ─── Dates Card ───
              _buildDatesCard(),
              const SizedBox(height: 20),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: AquaColors.border),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.2),
            blurRadius: 18,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 50,
                height: 50,
                decoration: BoxDecoration(
                  color: AquaColors.accent.withValues(alpha: 0.12),
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: AquaColors.accent.withValues(alpha: 0.2)),
                ),
                child: const Icon(
                  Icons.water,
                  color: AquaColors.accent,
                  size: 26,
                ),
              ),
              const SizedBox(width: 14),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aquarium.name,
                      style: const TextStyle(
                        color: AquaColors.textPrimary,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: AquaColors.accent.withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: AquaColors.accent.withValues(alpha: 0.2)),
                      ),
                      child: Text(
                        aquarium.type.toUpperCase(),
                        style: const TextStyle(
                          color: AquaColors.accent,
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 22),
          const Text(
            'Tank Volume',
            style: TextStyle(
              color: AquaColors.textSecondary,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${aquarium.volumeLitres.toStringAsFixed(1)} Litres',
            style: const TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AquaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tank Specifications',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.straighten,
            'Dimensions',
            '${aquarium.length} × ${aquarium.width} × ${aquarium.height} ${aquarium.unit}',
          ),
          Divider(
            color: AquaColors.border,
            height: 24,
          ),
          _buildDetailRow(
            Icons.water_drop_outlined,
            'Volume',
            '${aquarium.volumeLitres.toStringAsFixed(1)} L',
          ),
          Divider(
            color: AquaColors.border,
            height: 24,
          ),
          _buildDetailRow(
            Icons.category_outlined,
            'Type',
            aquarium.type,
          ),
          if (aquarium.description.isNotEmpty) ...[
            Divider(
              color: AquaColors.border,
              height: 24,
            ),
            _buildDetailRow(
              Icons.notes_outlined,
              'Description',
              aquarium.description,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildDatesCard() {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AquaColors.card,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AquaColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record Info',
            style: TextStyle(
              color: AquaColors.textPrimary,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
            Icons.add_circle_outline,
            'Created',
            dateFormat.format(aquarium.createdAt),
          ),
          Divider(color: AquaColors.border, height: 24),
          _buildDetailRow(
            Icons.update,
            'Last Updated',
            dateFormat.format(aquarium.updatedAt),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: AquaColors.accent, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: AquaColors.textSecondary,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: AquaColors.textPrimary,
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AquaColors.card,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Aquarium?',
          style: TextStyle(color: AquaColors.textPrimary, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently delete "${aquarium.name}" and all its data. '
          'This action cannot be undone.',
          style: const TextStyle(color: AquaColors.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AquaColors.error,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext);
              await _deleteAquarium(context);
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }

  Future<void> _deleteAquarium(BuildContext context) async {
    try {
      await aquariumService.deleteAquarium(aquarium.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${aquarium.name}" deleted successfully.'),
          backgroundColor: AquaColors.success,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting aquarium: $e'),
          backgroundColor: AquaColors.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
