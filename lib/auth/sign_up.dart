import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import 'auth_service.dart';

class SignupPage extends StatefulWidget {
  const SignupPage({super.key});

  @override
  State<SignupPage> createState() => _SignupPageState();
}

class _SignupPageState extends State<SignupPage>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final TextEditingController confirmPasswordController =
      TextEditingController();
  final AuthService _authService = AuthService();

  bool hidePassword = true;
  bool hideConfirmPassword = true;
  bool _isLoading = false;

  // AquaIntel colors (matching sign_in)
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  late AnimationController _animController;
  late Animation<double> _fadeAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );
    _fadeAnim = CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    );
    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _animController,
      curve: Curves.easeOut,
    ));
    _animController.forward();
  }

  @override
  void dispose() {
    _animController.dispose();
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final name = nameController.text.trim();
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _authService.registerWithEmailAndPassword(
        name: name,
        email: email,
        password: password,
      );

      if (!mounted) return;

      // Navigate to home, remove all auth routes from stack
      Navigator.pushNamedAndRemoveUntil(
        context,
        AppRoutes.home,
        (route) => false,
      );
    } on AuthException catch (e) {
      if (!mounted) return;
      _showErrorSnackBar(e.message);
    } catch (e) {
      if (!mounted) return;
      _showErrorSnackBar('Something went wrong. Please try again.');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).hideCurrentSnackBar();
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: const Color(0xFFD32F2F),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: backgroundColor,
      body: SafeArea(
        child: Stack(
          children: [

            // =========================
            // TOP CURVED BACKGROUND
            // =========================
            Align(
              alignment: Alignment.topCenter,
              child: Container(
                height: 85,
                decoration: const BoxDecoration(
                  color: topColor,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(100),
                    bottomRight: Radius.circular(100),
                  ),
                ),
              ),
            ),

            // =========================
            // MAIN CONTENT
            // =========================
            FadeTransition(
              opacity: _fadeAnim,
              child: SlideTransition(
                position: _slideAnim,
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 45,
                    ),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        children: [

                          // =========================
                          // LOGO
                          // =========================
                          Container(
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                begin: Alignment.topLeft,
                                end: Alignment.bottomRight,
                                colors: [
                                  primaryBlue.withValues(alpha: 0.3),
                                  const Color(0xFF1A4A70),
                                ],
                              ),
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(
                                  color: primaryBlue.withValues(alpha: 0.2),
                                  blurRadius: 16,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: const Icon(
                              Icons.water,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =========================
                          // APP NAME
                          // =========================
                          const Text(
                            'AquaIntel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 4),

                          const Text(
                            'Your smart management system',
                            style: TextStyle(
                              color: textBlue,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 28),

                          // =========================
                          // SIGN UP CARD
                          // =========================
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.fromLTRB(
                              20, 27, 20, 25,
                            ),
                            decoration: BoxDecoration(
                              color: cardColor,
                              borderRadius: BorderRadius.circular(23),
                              border: Border.all(
                                color: primaryBlue.withValues(alpha: 0.08),
                                width: 1,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withValues(alpha: 0.2),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                // Title
                                const Text(
                                  'Create Account',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                const Text(
                                  'Join AquaIntel and manage your aquarium smarter',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // =========================
                                // NAME
                                // =========================
                                const Text(
                                  'Full Name',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextFormField(
                                  controller: nameController,
                                  hint: 'Enter your full name',
                                  icon: Icons.person_outline,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter your name';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                // =========================
                                // EMAIL
                                // =========================
                                const Text(
                                  'Email',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextFormField(
                                  controller: emailController,
                                  hint: 'you@example.com',
                                  icon: Icons.email_outlined,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    );
                                    if (!emailRegex
                                        .hasMatch(value.trim())) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                // =========================
                                // PASSWORD
                                // =========================
                                const Text(
                                  'Password',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextFormField(
                                  controller: passwordController,
                                  hint: 'Minimum 6 characters',
                                  icon: Icons.lock_outline,
                                  obscure: hidePassword,
                                  textInputAction: TextInputAction.next,
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hidePassword = !hidePassword;
                                      });
                                    },
                                    icon: Icon(
                                      hidePassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF77A5C1),
                                      size: 19,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please enter a password';
                                    }
                                    if (value.trim().length < 6) {
                                      return 'Password must contain at least 6 characters';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                // =========================
                                // CONFIRM PASSWORD
                                // =========================
                                const Text(
                                  'Confirm Password',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                _buildTextFormField(
                                  controller: confirmPasswordController,
                                  hint: 'Re-enter your password',
                                  icon: Icons.lock_outline,
                                  obscure: hideConfirmPassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signUp(),
                                  suffixIcon: IconButton(
                                    onPressed: () {
                                      setState(() {
                                        hideConfirmPassword =
                                            !hideConfirmPassword;
                                      });
                                    },
                                    icon: Icon(
                                      hideConfirmPassword
                                          ? Icons.visibility_off_outlined
                                          : Icons.visibility_outlined,
                                      color: const Color(0xFF77A5C1),
                                      size: 19,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null ||
                                        value.trim().isEmpty) {
                                      return 'Please confirm your password';
                                    }
                                    if (value.trim() !=
                                        passwordController.text.trim()) {
                                      return 'Passwords do not match';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 25),

                                // =========================
                                // SIGN UP BUTTON
                                // =========================
                                SizedBox(
                                  width: double.infinity,
                                  height: 47,
                                  child: ElevatedButton(
                                    onPressed:
                                        _isLoading ? null : _signUp,
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: primaryBlue,
                                      foregroundColor: Colors.white,
                                      disabledBackgroundColor:
                                          primaryBlue.withValues(alpha: 0.5),
                                      elevation: 0,
                                      shape: RoundedRectangleBorder(
                                        borderRadius:
                                            BorderRadius.circular(25),
                                      ),
                                    ),
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 20,
                                            height: 20,
                                            child:
                                                CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Create Account',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // =========================
                                // SIGN IN LINK
                                // =========================
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: const TextStyle(
                                        color: textBlue,
                                        fontSize: 12,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text:
                                              'Already have an account? ',
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pop(context);
                                            },
                                            child: const Text(
                                              'Sign in',
                                              style: TextStyle(
                                                color: primaryBlue,
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================================
  // REUSABLE TEXT FORM FIELD (matches AquaIntel dark theme)
  // ==========================================================
  Widget _buildTextFormField({
    required TextEditingController controller,
    required String hint,
    required IconData icon,
    bool obscure = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction textInputAction = TextInputAction.next,
    String? Function(String?)? validator,
    void Function(String)? onFieldSubmitted,
  }) {
    return TextFormField(
      controller: controller,
      obscureText: obscure,
      keyboardType: keyboardType,
      textInputAction: textInputAction,
      onFieldSubmitted: onFieldSubmitted,
      style: const TextStyle(
        color: Colors.white,
        fontSize: 13,
      ),
      decoration: InputDecoration(
        hintText: hint,
        hintStyle: const TextStyle(
          color: Color(0xFF6D99B8),
        ),
        prefixIcon: Icon(
          icon,
          color: const Color(0xFF77A5C1),
          size: 19,
        ),
        suffixIcon: suffixIcon,
        filled: true,
        fillColor: inputColor,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: BorderSide.none,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: primaryBlue,
            width: 1.5,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFEF5350),
            width: 1,
          ),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(13),
          borderSide: const BorderSide(
            color: Color(0xFFEF5350),
            width: 1.5,
          ),
        ),
        errorStyle: const TextStyle(
          fontSize: 11,
          color: Color(0xFFEF9A9A),
        ),
        contentPadding: const EdgeInsets.symmetric(
          vertical: 15,
        ),
      ),
      validator: validator,
    );
  }
}