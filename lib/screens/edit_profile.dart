import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../routes/app_routes.dart';

class EditProfileScreen extends StatefulWidget {
  const EditProfileScreen({super.key});

  @override
  State<EditProfileScreen> createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen>
    with SingleTickerProviderStateMixin {
  // ─── AquaIntel Color Palette ───
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);
  static const Color surfaceDark = Color(0xFF142F45);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;

  // ─── Controllers ───
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  // ─── State ───
  DateTime? _selectedDob;
  bool _isSaving = false;

  // ─── Sample user data (replace with actual user data) ───
  late UserModel _currentUser;

  @override
  void initState() {
    super.initState();

    _animController = AnimationController(
      duration: const Duration(milliseconds: 700),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _animController.forward();

    // Initialize with sample data
    _currentUser = UserModel(
      fullName: 'Amogh',
      dateOfBirth: DateTime(2004, 11, 16),
      email: 'amogh123@gmail.com',
    );

    _nameController.text = _currentUser.fullName;
    _selectedDob = _currentUser.dateOfBirth;
    if (_selectedDob != null) {
      _dobController.text = DateFormat('dd MMM, yyyy').format(_selectedDob!);
    }
    _emailController.text = _currentUser.email;
  }

  @override
  void dispose() {
    _animController.dispose();
    _nameController.dispose();
    _dobController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: FadeTransition(
          opacity: _fadeAnim,
          child: Stack(
            children: [
              // ═══════════════════════════════════════
              // TOP GRADIENT BACKGROUND
              // ═══════════════════════════════════════
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: 280,
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        topColor,
                        Color(0xFF174A6A),
                        backgroundColor,
                      ],
                      stops: [0.0, 0.6, 1.0],
                    ),
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(30),
                      bottomRight: Radius.circular(30),
                    ),
                  ),
                ),
              ),

              // ═══════════════════════════════════════
              // MAIN CONTENT
              // ═══════════════════════════════════════
              CustomScrollView(
                physics: const BouncingScrollPhysics(),
                slivers: [
                  // ─── TOP BAR ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: Row(
                        children: [
                          // Back button
                          GestureDetector(
                            onTap: () => Navigator.pop(context),
                            child: Container(
                              width: 38,
                              height: 38,
                              decoration: BoxDecoration(
                                color: cardColor.withValues(alpha: 0.6),
                                shape: BoxShape.circle,
                                border: Border.all(
                                  color: primaryBlue.withValues(alpha: 0.15),
                                  width: 1,
                                ),
                              ),
                              child: const Icon(
                                Icons.arrow_back_ios_new,
                                color: textBlue,
                                size: 16,
                              ),
                            ),
                          ),
                          const SizedBox(width: 12),
                          // Logo
                          Container(
                            width: 36,
                            height: 36,
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.2),
                              shape: BoxShape.circle,
                            ),
                            child: const Icon(
                              Icons.water_drop,
                              color: primaryBlue,
                              size: 20,
                            ),
                          ),
                          const SizedBox(width: 10),
                          const Text(
                            'AquaIntel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.5,
                            ),
                          ),
                          const Spacer(),
                        ],
                      ),
                    ),
                  ),

                  // ─── TITLE ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            'Edit Profile',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 28,
                              fontWeight: FontWeight.bold,
                              letterSpacing: -0.5,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Text(
                            'Update your personal information.',
                            style: TextStyle(
                              color: textBlue.withValues(alpha: 0.85),
                              fontSize: 14,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  // ─── AVATAR SECTION ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: Center(
                        child: _buildAvatarSection(),
                      ),
                    ),
                  ),

                  // ─── PROFILE FORM CARD ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: _buildProfileFormCard(),
                    ),
                  ),

                  // ─── SAVE BUTTON ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 28, 20, 0),
                      child: _buildSaveButton(),
                    ),
                  ),

                  // ─── LOGOUT BUTTON ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                      child: _buildLogoutButton(),
                    ),
                  ),

                  // ─── FOOTER ───
                  SliverToBoxAdapter(
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(20, 40, 20, 40),
                      child: Column(
                        children: [
                          Container(
                            width: 40,
                            height: 40,
                            decoration: BoxDecoration(
                              color: primaryBlue.withValues(alpha: 0.1),
                              shape: BoxShape.circle,
                            ),
                            child: Icon(
                              Icons.water_drop,
                              color: primaryBlue.withValues(alpha: 0.4),
                              size: 20,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'AquaIntel v1.0.0',
                            style: TextStyle(
                              color: textBlue.withValues(alpha: 0.4),
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // AVATAR SECTION
  // ══════════════════════════════════════════════
  Widget _buildAvatarSection() {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        // Avatar circle with gradient border
        Container(
          width: 110,
          height: 110,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                Color(0xFF29A8DF),
                Color(0xFF00E5FF),
                Color(0xFF1B8FC4),
              ],
            ),
            boxShadow: [
              BoxShadow(
                color: primaryBlue.withValues(alpha: 0.35),
                blurRadius: 24,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.all(3),
            child: Container(
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: backgroundColor,
              ),
              child: Padding(
                padding: const EdgeInsets.all(3),
                child: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: primaryBlue.withValues(alpha: 0.15),
                  ),
                  child: const Icon(
                    Icons.person,
                    color: primaryBlue,
                    size: 48,
                  ),
                ),
              ),
            ),
          ),
        ),
        // Camera button
        Positioned(
          bottom: 2,
          right: 2,
          child: GestureDetector(
            onTap: () {
              HapticFeedback.lightImpact();
              _showSnackBar('Photo picker coming soon!');
            },
            child: Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Color(0xFF29A8DF), Color(0xFF1B8FC4)],
                ),
                shape: BoxShape.circle,
                border: Border.all(
                  color: backgroundColor,
                  width: 3,
                ),
                boxShadow: [
                  BoxShadow(
                    color: primaryBlue.withValues(alpha: 0.4),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(
                Icons.camera_alt,
                color: Colors.white,
                size: 16,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // PROFILE FORM CARD
  // ══════════════════════════════════════════════
  Widget _buildProfileFormCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: primaryBlue.withValues(alpha: 0.1),
          width: 1,
        ),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.15),
            blurRadius: 16,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        children: [
          // Full Name field
          _buildFormField(
            label: 'Full Name',
            controller: _nameController,
            icon: Icons.person_outline,
            hintText: 'Enter your full name',
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: primaryBlue.withValues(alpha: 0.08),
          ),

          const SizedBox(height: 20),

          // Date of Birth field
          _buildDateField(
            label: 'Date of Birth',
            controller: _dobController,
            icon: Icons.calendar_today_outlined,
            hintText: 'Select your date of birth',
          ),

          const SizedBox(height: 20),

          // Divider
          Container(
            height: 1,
            color: primaryBlue.withValues(alpha: 0.08),
          ),

          const SizedBox(height: 20),

          // Email field (read-only)
          _buildFormField(
            label: 'Email (Read-Only)',
            controller: _emailController,
            icon: Icons.email_outlined,
            hintText: 'Your email address',
            readOnly: true,
          ),
        ],
      ),
    );
  }

  // ══════════════════════════════════════════════
  // FORM FIELD
  // ══════════════════════════════════════════════
  Widget _buildFormField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
    bool readOnly = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: readOnly
                    ? textBlue.withValues(alpha: 0.4)
                    : primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: readOnly
                    ? textBlue.withValues(alpha: 0.5)
                    : textBlue.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
            if (readOnly) ...[
              const SizedBox(width: 6),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 6,
                  vertical: 2,
                ),
                decoration: BoxDecoration(
                  color: textBlue.withValues(alpha: 0.1),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: Text(
                  'LOCKED',
                  style: TextStyle(
                    color: textBlue.withValues(alpha: 0.4),
                    fontSize: 9,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 10),
        // Input
        Container(
          decoration: BoxDecoration(
            color: readOnly
                ? surfaceDark.withValues(alpha: 0.5)
                : surfaceDark,
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: readOnly
                  ? primaryBlue.withValues(alpha: 0.05)
                  : primaryBlue.withValues(alpha: 0.12),
              width: 1,
            ),
          ),
          child: TextField(
            controller: controller,
            readOnly: readOnly,
            style: TextStyle(
              color: readOnly
                  ? textBlue.withValues(alpha: 0.5)
                  : Colors.white,
              fontSize: 15,
              fontWeight: FontWeight.w500,
            ),
            decoration: InputDecoration(
              prefixIcon: Padding(
                padding: const EdgeInsets.only(left: 14, right: 10),
                child: Icon(
                  icon,
                  color: readOnly
                      ? textBlue.withValues(alpha: 0.3)
                      : primaryBlue,
                  size: 20,
                ),
              ),
              prefixIconConstraints: const BoxConstraints(
                minWidth: 44,
                minHeight: 44,
              ),
              hintText: hintText,
              hintStyle: TextStyle(
                color: textBlue.withValues(alpha: 0.3),
                fontSize: 14,
                fontWeight: FontWeight.w400,
              ),
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                vertical: 14,
                horizontal: 0,
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // DATE FIELD (with picker)
  // ══════════════════════════════════════════════
  Widget _buildDateField({
    required String label,
    required TextEditingController controller,
    required IconData icon,
    required String hintText,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Label
        Row(
          children: [
            Container(
              width: 3,
              height: 14,
              decoration: BoxDecoration(
                color: primaryBlue,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(width: 8),
            Text(
              label,
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.7),
                fontSize: 12,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        // Date input
        GestureDetector(
          onTap: () => _pickDate(),
          child: Container(
            decoration: BoxDecoration(
              color: surfaceDark,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(
                color: primaryBlue.withValues(alpha: 0.12),
                width: 1,
              ),
            ),
            child: AbsorbPointer(
              child: TextField(
                controller: controller,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                  fontWeight: FontWeight.w500,
                ),
                decoration: InputDecoration(
                  prefixIcon: Padding(
                    padding: const EdgeInsets.only(left: 14, right: 10),
                    child: Icon(
                      icon,
                      color: primaryBlue,
                      size: 20,
                    ),
                  ),
                  prefixIconConstraints: const BoxConstraints(
                    minWidth: 44,
                    minHeight: 44,
                  ),
                  suffixIcon: Padding(
                    padding: const EdgeInsets.only(right: 10),
                    child: Icon(
                      Icons.keyboard_arrow_down_rounded,
                      color: textBlue.withValues(alpha: 0.4),
                      size: 22,
                    ),
                  ),
                  suffixIconConstraints: const BoxConstraints(
                    minWidth: 32,
                    minHeight: 44,
                  ),
                  hintText: hintText,
                  hintStyle: TextStyle(
                    color: textBlue.withValues(alpha: 0.3),
                    fontSize: 14,
                    fontWeight: FontWeight.w400,
                  ),
                  border: InputBorder.none,
                  contentPadding: const EdgeInsets.symmetric(
                    vertical: 14,
                    horizontal: 0,
                  ),
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // ══════════════════════════════════════════════
  // SAVE BUTTON
  // ══════════════════════════════════════════════
  Widget _buildSaveButton() {
    return GestureDetector(
      onTap: _isSaving ? null : _handleSave,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: _isSaving
                ? [
                    primaryBlue.withValues(alpha: 0.4),
                    const Color(0xFF1B8FC4).withValues(alpha: 0.4),
                  ]
                : [
                    const Color(0xFF29A8DF),
                    const Color(0xFF1B8FC4),
                    const Color(0xFF1E6B9A),
                  ],
          ),
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: primaryBlue.withValues(alpha: _isSaving ? 0.1 : 0.35),
              blurRadius: 20,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        child: Center(
          child: _isSaving
              ? const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(
                    color: Colors.white,
                    strokeWidth: 2.5,
                  ),
                )
              : const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.check_circle_outline,
                      color: Colors.white,
                      size: 20,
                    ),
                    SizedBox(width: 10),
                    Text(
                      'Save Changes',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 0.3,
                      ),
                    ),
                  ],
                ),
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // LOGOUT BUTTON
  // ══════════════════════════════════════════════
  Widget _buildLogoutButton() {
    return GestureDetector(
      onTap: () => _showLogoutDialog(),
      child: Container(
        width: double.infinity,
        height: 54,
        decoration: BoxDecoration(
          color: cardColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: const Color(0xFFEF5350).withValues(alpha: 0.25),
            width: 1,
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.08),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.logout_rounded,
              color: Color(0xFFEF5350),
              size: 20,
            ),
            SizedBox(width: 10),
            Text(
              'Logout',
              style: TextStyle(
                color: Color(0xFFEF5350),
                fontSize: 15,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ══════════════════════════════════════════════
  // ACTIONS
  // ══════════════════════════════════════════════

  Future<void> _pickDate() async {
    HapticFeedback.lightImpact();
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDob ?? DateTime(2000, 1, 1),
      firstDate: DateTime(1920),
      lastDate: DateTime.now(),
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.dark(
              primary: primaryBlue,
              onPrimary: Colors.white,
              surface: cardColor,
              onSurface: Colors.white,
            ),
            dialogTheme: DialogThemeData(
              backgroundColor: backgroundColor,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
            ),
          ),
          child: child!,
        );
      },
    );

    if (picked != null) {
      setState(() {
        _selectedDob = picked;
        _dobController.text = DateFormat('dd MMM, yyyy').format(picked);
      });
    }
  }

  void _handleSave() {
    HapticFeedback.mediumImpact();

    if (_nameController.text.trim().isEmpty) {
      _showSnackBar('Please enter your full name');
      return;
    }

    setState(() => _isSaving = true);

    // Build updated user model
    final updatedUser = _currentUser.copyWith(
      fullName: _nameController.text.trim(),
      dateOfBirth: _selectedDob,
      updatedAt: DateTime.now(),
    );

    // Simulate save delay
    Future.delayed(const Duration(milliseconds: 1200), () {
      if (mounted) {
        setState(() {
          _isSaving = false;
          _currentUser = updatedUser;
        });
        _showSnackBar('Profile updated successfully! ✓');
      }
    });
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: cardColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Row(
          children: [
            Icon(Icons.logout_rounded, color: Color(0xFFEF5350), size: 22),
            SizedBox(width: 10),
            Text(
              'Log Out',
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to log out of AquaIntel?',
          style: TextStyle(
            color: textBlue.withValues(alpha: 0.8),
            height: 1.5,
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Cancel',
              style: TextStyle(
                color: textBlue.withValues(alpha: 0.6),
              ),
            ),
          ),
          ElevatedButton(
            onPressed: () async {
              Navigator.pop(ctx);
              await FirebaseAuth.instance.signOut();
              if (!mounted) return;
              Navigator.pushNamedAndRemoveUntil(
                context,
                AppRoutes.signIn,
                (route) => false,
              );
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFEF5350),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
            ),
            child: const Text('Log Out'),
          ),
        ],
      ),
    );
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          message,
          style: const TextStyle(color: Colors.white),
        ),
        backgroundColor: cardColor,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 2),
      ),
    );
  }
}
