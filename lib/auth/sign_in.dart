import 'package:flutter/material.dart';
import '../routes/app_routes.dart';
import '../theme/app_theme.dart';
import 'auth_service.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();
  final IAuthService _authService;

  _SignInScreenState({IAuthService? authService})
      : _authService = authService ?? AuthService();

  bool obscurePassword = true;
  bool _isLoading = false;

  // AquaIntel colors
  static Color get backgroundColor => AquaColors.bg;
  static Color get topColor => AquaColors.bgSecondary;
  static Color get cardColor => AquaColors.card;
  static Color get inputColor => AquaColors.input;
  static Color get primaryBlue => AquaColors.accent;
  static Color get textBlue => AquaColors.textSecondary;

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
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  Future<void> _signIn() async {
    if (!_formKey.currentState!.validate()) return;
    if (_isLoading) return;

    setState(() => _isLoading = true);

    try {
      final email = emailController.text.trim();
      final password = passwordController.text.trim();

      await _authService.signInWithEmailAndPassword(
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
            Icon(Icons.error_outline, color: Colors.white, size: 18),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                message,
                style: TextStyle(fontSize: 13),
              ),
            ),
          ],
        ),
        backgroundColor: AquaColors.error,
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
                decoration: BoxDecoration(
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
                      vertical: 55,
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
                                  AquaColors.cardElevated,
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
                            child: Icon(
                              Icons.water,
                              color: Colors.white,
                              size: 26,
                            ),
                          ),

                          const SizedBox(height: 14),

                          // =========================
                          // APP NAME
                          // =========================
                          Text(
                            'AquaIntel',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.3,
                            ),
                          ),

                          const SizedBox(height: 4),

                          Text(
                            'Your smart management system',
                            style: TextStyle(
                              color: textBlue,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 35),

                          // =========================
                          // LOGIN CARD
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
                                color: AquaColors.border,
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

                                // Welcome
                                Text(
                                  'Welcome back',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),

                                const SizedBox(height: 5),

                                Text(
                                  'Sign in to your account to continue',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 22),

                                // =========================
                                // EMAIL LABEL
                                // =========================
                                Text(
                                  'Email',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Email field
                                TextFormField(
                                  controller: emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  textInputAction: TextInputAction.next,
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'you@example.com',
                                    hintStyle: TextStyle(
                                      color: AquaColors.textMuted,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.email_outlined,
                                      color: AquaColors.textSecondary,
                                      size: 19,
                                    ),
                                    filled: true,
                                    fillColor: inputColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: primaryBlue,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.error,
                                        width: 1,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.error,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      fontSize: 11,
                                      color: AquaColors.error,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your email';
                                    }
                                    final emailRegex = RegExp(
                                      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                                    );
                                    if (!emailRegex.hasMatch(value.trim())) {
                                      return 'Please enter a valid email address';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 15),

                                // =========================
                                // PASSWORD LABEL
                                // =========================
                                Text(
                                  'Password',
                                  style: TextStyle(
                                    color: textBlue,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                // Password field
                                TextFormField(
                                  controller: passwordController,
                                  obscureText: obscurePassword,
                                  textInputAction: TextInputAction.done,
                                  onFieldSubmitted: (_) => _signIn(),
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 13,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: 'Enter your password',
                                    hintStyle: TextStyle(
                                      color: AquaColors.textMuted,
                                    ),
                                    prefixIcon: Icon(
                                      Icons.lock_outline,
                                      color: AquaColors.textSecondary,
                                      size: 19,
                                    ),
                                    suffixIcon: IconButton(
                                      onPressed: () {
                                        setState(() {
                                          obscurePassword = !obscurePassword;
                                        });
                                      },
                                      icon: Icon(
                                        obscurePassword
                                            ? Icons.visibility_off_outlined
                                            : Icons.visibility_outlined,
                                        color: AquaColors.textSecondary,
                                        size: 19,
                                      ),
                                    ),
                                    filled: true,
                                    fillColor: inputColor,
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.border,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: primaryBlue,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.error,
                                        width: 1,
                                      ),
                                    ),
                                    focusedErrorBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(13),
                                      borderSide: BorderSide(
                                        color: AquaColors.error,
                                        width: 1.5,
                                      ),
                                    ),
                                    errorStyle: TextStyle(
                                      fontSize: 11,
                                      color: AquaColors.error,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      vertical: 15,
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Please enter your password';
                                    }
                                    return null;
                                  },
                                ),

                                const SizedBox(height: 13),

                                // =========================
                                // FORGOT PASSWORD
                                // =========================
                                Align(
                                  alignment: Alignment.centerRight,
                                  child: GestureDetector(
                                    onTap: () {
                                      // TODO: Navigate to forgot password
                                    },
                                    child: Text(
                                      'Forgot password?',
                                      style: TextStyle(
                                        color: primaryBlue,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 21),

                                // =========================
                                // SIGN IN BUTTON
                                // =========================
                                SizedBox(
                                  width: double.infinity,
                                  height: 47,
                                  child: ElevatedButton(
                                    onPressed: _isLoading ? null : _signIn,
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
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 13,
                                              fontWeight: FontWeight.bold,
                                            ),
                                          ),
                                  ),
                                ),

                                const SizedBox(height: 25),

                                // =========================
                                // SIGN UP LINK
                                // =========================
                                Center(
                                  child: RichText(
                                    text: TextSpan(
                                      style: TextStyle(
                                        color: textBlue,
                                        fontSize: 12,
                                      ),
                                      children: [
                                        const TextSpan(
                                          text: "Don't have an account? ",
                                        ),
                                        WidgetSpan(
                                          child: GestureDetector(
                                            onTap: () {
                                              Navigator.pushNamed(
                                                context,
                                                AppRoutes.signUp,
                                              );
                                            },
                                            child: Text(
                                              'Sign up',
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
}