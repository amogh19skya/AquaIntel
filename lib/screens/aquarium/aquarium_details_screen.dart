import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../../models/aquarium_model.dart';
import '../../services/aquarium_service.dart';
import 'edit_aquarium_screen.dart';

/// Full-detail view of a single aquarium.
/// Provides Edit and Delete options via the AppBar action menu.
class AquariumDetailsScreen extends StatelessWidget {
  final AquariumModel aquarium;

  const AquariumDetailsScreen({super.key, required this.aquarium});

  // AquaIntel colours
  static const Color backgroundColor = Color(0xFF0A2236);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color primaryColor = Color(0xFF29A8DF);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF70A9CC);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: Text(
          aquarium.name,
          style: const TextStyle(color: textColor, fontWeight: FontWeight.w600),
        ),
        actions: [
          // ── Edit button ──
          IconButton(
            icon: const Icon(Icons.edit_outlined, color: primaryColor),
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
          // ── Delete button ──
          IconButton(
            icon: Icon(Icons.delete_outline, color: Colors.red.shade400),
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

              // ─── Hero Volume Card ───
              _buildHeroCard(),

              const SizedBox(height: 24),

              // ─── Details Card ───
              _buildDetailsCard(),

              const SizedBox(height: 24),

              // ─── Dates Card ───
              _buildDatesCard(),

            ],
          ),
        ),
      ),
    );
  }

  // ─── Hero Volume Card ───
  Widget _buildHeroCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF1E6B9A), Color(0xFF29A8DF)],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: primaryColor.withValues(alpha: 0.3),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 52,
                height: 52,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.2),
                  borderRadius: BorderRadius.circular(14),
                ),
                child: const Icon(Icons.water, color: Colors.white, size: 28),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      aquarium.name,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 3),
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.2),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        aquarium.type.toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
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
          const SizedBox(height: 24),
          const Text(
            'Tank Volume',
            style: TextStyle(
              color: Colors.white70,
              fontSize: 13,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '${aquarium.volumeLitres.toStringAsFixed(1)} Litres',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 32,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }

  // ─── Details Card ───
  Widget _buildDetailsCard() {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: primaryColor.withValues(alpha: 0.1),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Tank Specifications',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
              Icons.straighten, 'Dimensions',
              '${aquarium.length} × ${aquarium.width} × ${aquarium.height} ${aquarium.unit}'),
          const Divider(color: Colors.white12, height: 24),
          _buildDetailRow(Icons.water_drop_outlined, 'Volume',
              '${aquarium.volumeLitres.toStringAsFixed(1)} L'),
          const Divider(color: Colors.white12, height: 24),
          _buildDetailRow(
              Icons.category_outlined, 'Type', aquarium.type),
          if (aquarium.description.isNotEmpty) ...[
            const Divider(color: Colors.white12, height: 24),
            _buildDetailRow(
                Icons.notes_outlined, 'Description', aquarium.description),
          ],
        ],
      ),
    );
  }

  // ─── Dates Card ───
  Widget _buildDatesCard() {
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: primaryColor.withValues(alpha: 0.1)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Record Info',
            style: TextStyle(
              color: textColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
          const SizedBox(height: 16),
          _buildDetailRow(
              Icons.add_circle_outline,
              'Created',
              dateFormat.format(aquarium.createdAt)),
          const Divider(color: Colors.white12, height: 24),
          _buildDetailRow(
              Icons.update,
              'Last Updated',
              dateFormat.format(aquarium.updatedAt)),
        ],
      ),
    );
  }

  Widget _buildDetailRow(IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, color: primaryColor, size: 18),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                label,
                style: const TextStyle(
                  color: secondaryTextColor,
                  fontSize: 12,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                value,
                style: const TextStyle(
                  color: textColor,
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

  // ─── Delete Confirmation Dialog ───
  void _confirmDelete(BuildContext context) {
    showDialog(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text(
          'Delete Aquarium?',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Text(
          'This will permanently delete "${aquarium.name}" and all its data. '
          'This action cannot be undone.',
          style: const TextStyle(color: secondaryTextColor, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext),
            child: const Text(
              'Cancel',
              style: TextStyle(color: primaryColor),
            ),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.red.shade600,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () async {
              Navigator.pop(dialogContext); // close dialog first
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
      await AquariumService().deleteAquarium(aquarium.id);
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('"${aquarium.name}" deleted successfully.'),
          backgroundColor: Colors.green.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      // Pop back to Dashboard (the stream will auto-update)
      Navigator.pop(context);
    } catch (e) {
      if (!context.mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error deleting aquarium: $e'),
          backgroundColor: Colors.red.shade700,
          behavior: SnackBarBehavior.floating,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }
}
