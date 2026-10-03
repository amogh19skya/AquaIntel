import 'package:flutter/material.dart';
import '../../services/aquarium_service.dart';

/// Screen for adding a new aquarium.
/// Saves the aquarium to Cloud Firestore under the authenticated user's UID.
class AddAquariumScreen extends StatefulWidget {
  const AddAquariumScreen({super.key});

  @override
  State<AddAquariumScreen> createState() => _AddAquariumScreenState();
}

class _AddAquariumScreenState extends State<AddAquariumScreen> {
  final _formKey = GlobalKey<FormState>();
  final _aquariumService = AquariumService();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _lengthController = TextEditingController();
  final TextEditingController _widthController = TextEditingController();
  final TextEditingController _heightController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

  String _selectedUnit = 'cm';
  String _selectedType = 'Freshwater';
  double? _volumeLitres;
  bool _isSaving = false;

  // AquaIntel colours
  static const Color backgroundColor = Color(0xFF0A2236);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryColor = Color(0xFF29A8DF);
  static const Color textColor = Colors.white;
  static const Color secondaryTextColor = Color(0xFF70A9CC);

  // ─── Volume Calculation ───
  void _calculateVolume() {
    final length = double.tryParse(_lengthController.text);
    final width = double.tryParse(_widthController.text);
    final height = double.tryParse(_heightController.text);

    if (length == null || width == null || height == null) {
      _showSnackBar('Please enter valid tank dimensions.', isError: true);
      return;
    }

    if (length <= 0 || width <= 0 || height <= 0) {
      _showSnackBar('Dimensions must be positive numbers.', isError: true);
      return;
    }

    double volume;
    if (_selectedUnit == 'cm') {
      volume = (length * width * height) / 1000;
    } else {
      // inches to litres
      volume = length * width * height * 0.0163871;
    }

    setState(() {
      _volumeLitres = volume;
    });
  }

  // ─── Save to Firestore ───
  Future<void> _saveAquarium() async {
    if (!_formKey.currentState!.validate()) return;

    if (_volumeLitres == null) {
      _showSnackBar('Please calculate the tank volume first.', isError: true);
      return;
    }

    setState(() => _isSaving = true);

    try {
      await _aquariumService.addAquarium(
        name: _nameController.text.trim(),
        type: _selectedType,
        length: double.parse(_lengthController.text),
        width: double.parse(_widthController.text),
        height: double.parse(_heightController.text),
        unit: _selectedUnit,
        volumeLitres: _volumeLitres!,
        description: _descriptionController.text.trim(),
      );

      if (!mounted) return;
      _showSnackBar('Aquarium saved successfully! 🐠');
      Navigator.pop(context);
    } catch (e) {
      if (!mounted) return;
      _showSnackBar(e.toString(), isError: true);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  void _showSnackBar(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? Colors.red.shade700 : const Color(0xFF29A8DF),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _lengthController.dispose();
    _widthController.dispose();
    _heightController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          'Add Aquarium',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      body: SafeArea(
        child: Form(
          key: _formKey,
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                const Text(
                  'Aquarium Information',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),

                const SizedBox(height: 8),

                const Text(
                  'Add your aquarium details to manage your tank.',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 14,
                  ),
                ),

                const SizedBox(height: 25),

                _buildLabel('Aquarium Name'),

                _buildTextField(
                  controller: _nameController,
                  hint: 'e.g. My Community Tank',
                  icon: Icons.water,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Please enter aquarium name';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: 25),

                const Text(
                  'Tank Dimensions',
                  style: TextStyle(
                    color: textColor,
                    fontSize: 18,
                    fontWeight: FontWeight.w600,
                  ),
                ),

                const SizedBox(height: 6),

                const Text(
                  'Enter the length, width and height of your aquarium.',
                  style: TextStyle(
                    color: secondaryTextColor,
                    fontSize: 13,
                  ),
                ),

                const SizedBox(height: 15),

                Row(
                  children: [
                    Expanded(
                      child: _buildDimensionField(
                        controller: _lengthController,
                        label: 'Length',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDimensionField(
                        controller: _widthController,
                        label: 'Width',
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: _buildDimensionField(
                        controller: _heightController,
                        label: 'Height',
                      ),
                    ),
                  ],
                ),

                const SizedBox(height: 15),

                _buildLabel('Measurement Unit'),

                _buildDropdown(
                  value: _selectedUnit,
                  items: const ['cm', 'inch'],
                  icon: Icons.straighten,
                  onChanged: (value) {
                    setState(() {
                      _selectedUnit = value!;
                      _volumeLitres = null; // reset volume on unit change
                    });
                  },
                ),

                const SizedBox(height: 18),

                SizedBox(
                  width: double.infinity,
                  height: 52,
                  child: ElevatedButton.icon(
                    onPressed: _calculateVolume,
                    icon: const Icon(Icons.calculate),
                    label: const Text(
                      'Calculate Tank Volume',
                      style: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(14),
                      ),
                    ),
                  ),
                ),

                const SizedBox(height: 18),

                // ─── Volume Result Card ───
                if (_volumeLitres != null)
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(18),
                    decoration: BoxDecoration(
                      color: cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: primaryColor.withValues(alpha: 0.4),
                      ),
                    ),
                    child: Row(
                      children: [
                        Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: primaryColor.withValues(alpha: 0.15),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.water_drop,
                            color: primaryColor,
                            size: 26,
                          ),
                        ),
                        const SizedBox(width: 15),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Estimated Water Volume',
                                style: TextStyle(
                                  color: secondaryTextColor,
                                  fontSize: 13,
                                ),
                              ),
                              SizedBox(height: 4),
                              Text(
                                'Calculated Tank Capacity',
                                style: TextStyle(
                                  color: textColor,
                                  fontSize: 15,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          '${_volumeLitres!.toStringAsFixed(1)} L',
                          style: const TextStyle(
                            color: primaryColor,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 25),

                _buildLabel('Aquarium Type'),

                _buildDropdown(
                  value: _selectedType,
                  items: const ['Freshwater', 'Saltwater', 'Brackish'],
                  icon: Icons.category_outlined,
                  onChanged: (value) {
                    setState(() => _selectedType = value!);
                  },
                ),

                const SizedBox(height: 25),

                _buildLabel('Description (optional)'),

                _buildTextField(
                  controller: _descriptionController,
                  hint: 'Add a short description',
                  icon: Icons.notes_outlined,
                  maxLines: 4,
                ),

                const SizedBox(height: 30),

                // ─── Save Button ───
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveAquarium,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: primaryColor,
                      foregroundColor: Colors.white,
                      disabledBackgroundColor: primaryColor.withValues(alpha: 0.5),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSaving
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2.5,
                            ),
                          )
                        : const Text(
                            'Save Aquarium',
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                  ),
                ),

              ],
            ),
          ),
        ),
      ),
    );
  }

  // ─── Reusable UI Helpers ───

  Widget _buildLabel(String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Text(
        text,
        style: const TextStyle(
          color: textColor,
          fontSize: 14,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    String? Function(String?)? validator,
    int maxLines = 1,
  }) {
    return TextFormField(
      controller: controller,
      validator: validator,
      maxLines: maxLines,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(color: secondaryTextColor),
        prefixIcon: Icon(icon, color: secondaryTextColor),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor, width: 1.5),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent),
      ),
    );
  }

  Widget _buildDimensionField({
    required TextEditingController controller,
    required String label,
  }) {
    return TextFormField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true),
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        labelText: label,
        labelStyle: const TextStyle(color: secondaryTextColor),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: primaryColor),
        ),
        errorStyle: const TextStyle(color: Colors.redAccent, fontSize: 10),
      ),
      validator: (value) {
        if (value == null || value.isEmpty) return 'Required';
        final parsed = double.tryParse(value);
        if (parsed == null) return 'Invalid';
        if (parsed <= 0) return '> 0';
        return null;
      },
    );
  }

  Widget _buildDropdown({
    required String value,
    required List<String> items,
    required IconData icon,
    required void Function(String?) onChanged,
  }) {
    return DropdownButtonFormField<String>(
      initialValue: value,
      dropdownColor: cardColor,
      iconEnabledColor: secondaryTextColor,
      style: const TextStyle(color: Colors.white),
      decoration: InputDecoration(
        prefixIcon: Icon(icon, color: secondaryTextColor),
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide.none,
        ),
      ),
      items: items.map((item) {
        return DropdownMenuItem(value: item, child: Text(item));
      }).toList(),
      onChanged: onChanged,
    );
  }
}