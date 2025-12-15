import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../../../core/constants/app_colors.dart';

/// Animated splash screen showing Kapok tree roots growing
/// Displays while the app initializes
class SplashScreen extends StatefulWidget {
  final VoidCallback onInitializationComplete;

  const SplashScreen({
    super.key,
    required this.onInitializationComplete,
  });

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();

    // Create looping animation controller
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2500),
      vsync: this,
    );

    // Curved animation for natural growing effect
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );

    // Loop the animation
    _controller.repeat();

    // Complete initialization after minimum display time
    Future.delayed(const Duration(milliseconds: 3000), () {
      if (mounted) {
        widget.onInitializationComplete();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.primary,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Animated Kapok roots
            SizedBox(
              width: 200,
              height: 200,
              child: AnimatedBuilder(
                animation: _animation,
                builder: (context, child) {
                  return CustomPaint(
                    painter: KapokRootsPainter(
                      progress: _animation.value,
                    ),
                  );
                },
              ),
            ),
            const SizedBox(height: 32),
            // App name
            const Text(
              'KAPOK',
              style: TextStyle(
                fontSize: 32,
                fontWeight: FontWeight.bold,
                color: Colors.white,
                letterSpacing: 4,
              ),
            ),
            const SizedBox(height: 8),
            // Tagline
            const Text(
              'Disaster Relief Coordination',
              style: TextStyle(
                fontSize: 14,
                color: Colors.white70,
                letterSpacing: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// Custom painter for Kapok tree roots growing animation
class KapokRootsPainter extends CustomPainter {
  final double progress;

  KapokRootsPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.white.withOpacity(0.9)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final center = Offset(size.width / 2, size.height / 2);

    // Draw central trunk/base
    final trunkPath = Path();
    trunkPath.moveTo(center.dx, center.dy - 40);
    final trunkProgress = (progress * 1.2).clamp(0.0, 1.0);
    trunkPath.lineTo(
      center.dx,
      center.dy - 40 + (80 * trunkProgress),
    );
    canvas.drawPath(trunkPath, paint..strokeWidth = 4);

    // Draw multiple roots growing from the base
    _drawRoot(
      canvas,
      paint,
      center,
      angle: -math.pi / 4, // 45 degrees left
      length: 70,
      startDelay: 0.1,
    );

    _drawRoot(
      canvas,
      paint,
      center,
      angle: math.pi / 4, // 45 degrees right
      length: 70,
      startDelay: 0.15,
    );

    _drawRoot(
      canvas,
      paint,
      center,
      angle: -math.pi / 6, // 30 degrees left
      length: 60,
      startDelay: 0.2,
    );

    _drawRoot(
      canvas,
      paint,
      center,
      angle: math.pi / 6, // 30 degrees right
      length: 60,
      startDelay: 0.25,
    );

    _drawRoot(
      canvas,
      paint,
      center,
      angle: -math.pi / 3, // 60 degrees left
      length: 50,
      startDelay: 0.3,
    );

    _drawRoot(
      canvas,
      paint,
      center,
      angle: math.pi / 3, // 60 degrees right
      length: 50,
      startDelay: 0.35,
    );

    // Draw smaller secondary roots
    _drawRoot(
      canvas,
      paint..strokeWidth = 2,
      center,
      angle: -math.pi / 8,
      length: 40,
      startDelay: 0.4,
    );

    _drawRoot(
      canvas,
      paint..strokeWidth = 2,
      center,
      angle: math.pi / 8,
      length: 40,
      startDelay: 0.45,
    );
  }

  /// Draw a single root with growth animation
  void _drawRoot(
    Canvas canvas,
    Paint paint,
    Offset center,
    {
    required double angle,
    required double length,
    required double startDelay,
  }) {
    // Calculate progress for this root (with delay)
    final rootProgress = ((progress - startDelay) / (1 - startDelay))
        .clamp(0.0, 1.0);

    if (rootProgress <= 0) return;

    final path = Path();
    path.moveTo(center.dx, center.dy + 40); // Start from base of trunk

    // Calculate end point with some curve
    final endX = center.dx + math.cos(angle) * length * rootProgress;
    final endY = center.dy + 40 + math.sin(angle).abs() * length * rootProgress;

    // Add slight curve for organic look
    final controlX = center.dx + math.cos(angle) * (length / 2) * rootProgress;
    final controlY = center.dy + 40 + math.sin(angle).abs() * (length / 3) * rootProgress;

    path.quadraticBezierTo(
      controlX,
      controlY,
      endX,
      endY,
    );

    canvas.drawPath(path, paint);

    // Draw small root tips (nodes) at the end
    if (rootProgress >= 0.8) {
      final tipPaint = Paint()
        ..color = Colors.white.withOpacity(0.9)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(
        Offset(endX, endY),
        2,
        tipPaint,
      );
    }
  }

  @override
  bool shouldRepaint(KapokRootsPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
