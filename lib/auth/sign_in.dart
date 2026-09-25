import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SignInScreen extends StatefulWidget {
  const SignInScreen({super.key});

  @override
  State<SignInScreen> createState() => _SignInScreenState();
}

class _SignInScreenState extends State<SignInScreen> {
  final TextEditingController emailController = TextEditingController();
  final TextEditingController passwordController = TextEditingController();

  bool obscurePassword = true;

  // AquaIntel colors
  static const Color backgroundColor = Color(0xFF0D2D47);
  static const Color topColor = Color(0xFF205779);
  static const Color cardColor = Color(0xFF1C4667);
  static const Color inputColor = Color(0xFF163B5A);
  static const Color primaryBlue = Color(0xFF29A8DF);
  static const Color textBlue = Color(0xFF70A9CC);

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }

  void signIn() {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please enter your email and password'),
        ),
      );
      return;
    }

    // TODO:
    // Connect this to your FastAPI + MongoDB login API.
    debugPrint('Email: $email');
    debugPrint('Password: $password');

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Sign in processing...'),
      ),
    );

    // Navigate to home screen
    Navigator.pushNamedAndRemoveUntil(
      context,
      AppRoutes.home,
      (route) => false,
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
            SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 55,
                ),
                child: Column(
                  children: [

                    // =========================
                    // LOGO
                    // =========================
                    Container(
                      width: 45,
                      height: 45,
                      decoration: BoxDecoration(
                        color: const Color(0xFF1A4A70),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.water,
                        color: Colors.white,
                        size: 25,
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

                    const SizedBox(height: 35),

                    // =========================
                    // LOGIN CARD
                    // =========================
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.fromLTRB(
                        20,
                        27,
                        20,
                        25,
                      ),
                      decoration: BoxDecoration(
                        color: cardColor,
                        borderRadius: BorderRadius.circular(23),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          // Welcome
                          const Text(
                            'Welcome back',
                            style: TextStyle(
                              color: Colors.white,
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),

                          const SizedBox(height: 5),

                          const Text(
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
                          const Text(
                            'Email',
                            style: TextStyle(
                              color: textBlue,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Email field
                          TextField(
                            controller: emailController,
                            keyboardType: TextInputType.emailAddress,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'you@example.com',
                              hintStyle: const TextStyle(
                                color: Color(0xFF6D99B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.email_outlined,
                                color: Color(0xFF77A5C1),
                                size: 19,
                              ),
                              filled: true,
                              fillColor: inputColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
                          ),

                          const SizedBox(height: 15),

                          // =========================
                          // PASSWORD LABEL
                          // =========================
                          const Text(
                            'Password',
                            style: TextStyle(
                              color: textBlue,
                              fontSize: 12,
                            ),
                          ),

                          const SizedBox(height: 8),

                          // Password field
                          TextField(
                            controller: passwordController,
                            obscureText: obscurePassword,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 13,
                            ),
                            decoration: InputDecoration(
                              hintText: 'Enter your password',
                              hintStyle: const TextStyle(
                                color: Color(0xFF6D99B8),
                              ),
                              prefixIcon: const Icon(
                                Icons.lock_outline,
                                color: Color(0xFF77A5C1),
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
                                  color: const Color(0xFF77A5C1),
                                  size: 19,
                                ),
                              ),
                              filled: true,
                              fillColor: inputColor,
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(13),
                                borderSide: BorderSide.none,
                              ),
                              contentPadding: const EdgeInsets.symmetric(
                                vertical: 15,
                              ),
                            ),
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
                              child: const Text(
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
                              onPressed: signIn,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: primaryBlue,
                                foregroundColor: Colors.white,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
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
// SIGN UP
// =========================
Center(
  child: RichText(
    text: TextSpan(
      style: const TextStyle(
        color: textBlue,
        fontSize: 12,
      ),
    ),
  ),
),
                          const SizedBox(height: 25),

                          // =========================
                          // SIGN UP
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
                                    text: "Don't have an account? ",
                                  ),
                                  WidgetSpan(
                                    child: GestureDetector(
                                      onTap: () {
                                        Navigator.pushNamed(context, AppRoutes.signUp);
                                      },
                                      child: const Text(
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
          ],
        ),
      ),
    );
  }

  // ==================================================
  // SOCIAL BUTTON
  // ==================================================

  Widget _socialButton({
    required IconData icon,
    required String text,
    required VoidCallback onTap,
    Color? border,
  }) {
    return SizedBox(
      height: 38,
      child: OutlinedButton(
        onPressed: onTap,
        style: OutlinedButton.styleFrom(
          backgroundColor: inputColor,
          side: BorderSide(
            color: border ?? Colors.transparent,
            width: border != null ? 1 : 0,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              icon,
              color: Colors.white,
              size: 16,
            ),
            const SizedBox(width: 7),
            Text(
              text,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 11,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}