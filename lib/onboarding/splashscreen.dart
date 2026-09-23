import 'dart:async';
import 'package:flutter/material.dart';
import '../routes/app_routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    // Navigate to the login screen after 4 seconds
    Timer(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, AppRoutes.login);
    });
  }

  @override
  Widget build(BuildContext context) {
    // UI Theme Colors[cite: 1]
    const Color bgColor = Color(0xFF0A2236);
    const Color curveColor = Color(0xFF102D45);
    const Color subtitleColor = Color(0xFF7A9BB8);

    return Scaffold(
      backgroundColor: bgColor,
      body: Stack(
        children: [
          // Top Background Arc Shape[cite: 1]
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: CustomPaint(
              size: Size(MediaQuery.of(context).size.width, 220),
              painter: TopCurvePainter(color: curveColor),
            ),
          ),

          // Central Content Layer[cite: 1]
          Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // Logo or Custom Paint Logo[cite: 1]
                SizedBox(
                  width: 90,
                  height: 90,
                  child: CustomPaint(
                    painter: LogoPainter(),
                  ),
                ),
                const SizedBox(height: 32),

                // App Name[cite: 1]
                const Text(
                  'AquaIntel',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w600,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 10),

                // Tagline[cite: 1]
                const Text(
                  'Your smart management system',
                  style: TextStyle(
                    color: subtitleColor,
                    fontSize: 15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: 0.2,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// Custom Painter for Top Background Arc[cite: 1]
class TopCurvePainter extends CustomPainter {
  final Color color;

  TopCurvePainter({required this.color});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;

    final path = Path();
    path.lineTo(0, size.height * 0.4);
    path.quadraticBezierTo(
      size.width / 2,
      size.height,
      size.width,
      size.height * 0.4,
    );
    path.lineTo(size.width, 0);
    path.close();

    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

// Custom Painter for AquaIntel Logo[cite: 1]
class LogoPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    // Right Slanted Bar[cite: 1]
    final rightPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.82, h * 0.85)
      ..lineTo(w * 0.62, h * 0.85)
      ..close();
    canvas.drawPath(rightPath, paint);

    // Left Stepped Bar[cite: 1]
    final leftPath = Path()
      ..moveTo(w * 0.5, h * 0.1)
      ..lineTo(w * 0.38, h * 0.32)
      ..lineTo(w * 0.44, h * 0.32)
      ..lineTo(w * 0.33, h * 0.50)
      ..lineTo(w * 0.39, h * 0.50)
      ..lineTo(w * 0.26, h * 0.68)
      ..lineTo(w * 0.32, h * 0.68)
      ..lineTo(w * 0.18, h * 0.85)
      ..lineTo(w * 0.38, h * 0.85)
      ..close();
    canvas.drawPath(leftPath, paint);

    // Fish Crossbar Outline[cite: 1]
    final fishPath = Path()
      ..moveTo(w * 0.34, h * 0.82)
      ..quadraticBezierTo(w * 0.55, h * 0.62, w * 0.72, h * 0.78)
      ..quadraticBezierTo(w * 0.55, h * 0.94, w * 0.34, h * 0.82)
      ..close();
    canvas.drawPath(fishPath, paint);

    // Fish Eye Cutout[cite: 1]
    final eyePaint = Paint()
      ..color = const Color(0xFF0A2236)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(Offset(w * 0.64, h * 0.78), w * 0.025, eyePaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}