import 'package:flutter/material.dart';
import 'dart:math' as math;
import '../constants/app_colors.dart';

/// A custom loading animation featuring roots growing upward
/// Aligned with Kapok branding using primary blue colors
class RootsLoadingAnimation extends StatefulWidget {
  final double size;
  final Color? color;
  final Duration duration;

  const RootsLoadingAnimation({
    super.key,
    this.size = 80.0,
    this.color,
    this.duration = const Duration(milliseconds: 2000),
  });

  @override
  State<RootsLoadingAnimation> createState() => _RootsLoadingAnimationState();
}

class _RootsLoadingAnimationState extends State<RootsLoadingAnimation>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: widget.duration,
      vsync: this,
    )..repeat();

    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final color = widget.color ?? AppColors.primary;
    
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, child) {
          return CustomPaint(
            painter: RootsPainter(
              progress: _animation.value,
              color: color,
            ),
          );
        },
      ),
    );
  }
}

class RootsPainter extends CustomPainter {
  final double progress;
  final Color color;

  RootsPainter({
    required this.progress,
    required this.color,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = 3.0
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final centerX = size.width / 2;
    final centerY = size.height / 2;
    final radius = size.width * 0.3;

    // Draw main root trunk (grows from bottom center)
    final trunkProgress = math.min(progress * 1.2, 1.0);
    final trunkStartY = size.height;
    final trunkEndY = centerY - radius * 0.3;
    final trunkCurrentY = trunkStartY - (trunkStartY - trunkEndY) * trunkProgress;

    if (trunkProgress > 0) {
      paint.strokeWidth = 4.0;
      canvas.drawLine(
        Offset(centerX, trunkStartY),
        Offset(centerX, trunkCurrentY),
        paint,
      );
    }

    // Draw branching roots
    if (trunkProgress > 0.3) {
      final branchProgress = math.min((progress - 0.25) * 1.5, 1.0);
      
      // Left branch
      _drawBranch(
        canvas,
        paint,
        Offset(centerX, trunkCurrentY),
        -math.pi / 4, // -45 degrees
        radius * 0.6,
        branchProgress,
      );

      // Right branch
      _drawBranch(
        canvas,
        paint,
        Offset(centerX, trunkCurrentY),
        math.pi / 4, // 45 degrees
        radius * 0.6,
        branchProgress,
      );

      // Center branch (grows upward)
      if (branchProgress > 0.3) {
        final centerBranchProgress = math.min((branchProgress - 0.3) * 1.4, 1.0);
        _drawBranch(
          canvas,
          paint,
          Offset(centerX, trunkCurrentY),
          -math.pi / 2, // -90 degrees (upward)
          radius * 0.5,
          centerBranchProgress,
        );
      }
    }

    // Draw small rootlets (fine details)
    if (progress > 0.6) {
      paint.strokeWidth = 2.0;
      final rootletProgress = (progress - 0.6) / 0.4;
      
      // Add small rootlets to branches
      _drawRootlets(canvas, paint, centerX, trunkCurrentY, rootletProgress);
    }

    // Draw subtle glow effect
    if (progress > 0.5) {
      final glowPaint = Paint()
        ..color = color.withValues(alpha: 0.2)
        ..style = PaintingStyle.fill;
      
      canvas.drawCircle(
        Offset(centerX, trunkCurrentY),
        radius * 0.3 * (progress - 0.5) * 2,
        glowPaint,
      );
    }
  }

  void _drawBranch(
    Canvas canvas,
    Paint paint,
    Offset start,
    double angle,
    double length,
    double progress,
  ) {
    if (progress <= 0) return;

    final currentLength = length * progress;
    final endX = start.dx + math.cos(angle) * currentLength;
    final endY = start.dy + math.sin(angle) * currentLength;

    canvas.drawLine(
      start,
      Offset(endX, endY),
      paint,
    );

    // Add sub-branches if main branch is mostly grown
    if (progress > 0.6 && currentLength > length * 0.3) {
      paint.strokeWidth = 2.0;
      final subProgress = (progress - 0.6) / 0.4;
      final subLength = length * 0.4;
      
      _drawBranch(
        canvas,
        paint,
        Offset(endX, endY),
        angle + math.pi / 6,
        subLength,
        subProgress,
      );
      
      _drawBranch(
        canvas,
        paint,
        Offset(endX, endY),
        angle - math.pi / 6,
        subLength,
        subProgress,
      );
    }
  }

  void _drawRootlets(Canvas canvas, Paint paint, double centerX, double trunkY, double progress) {
    final rootletCount = 4;
    for (int i = 0; i < rootletCount; i++) {
      final angle = (math.pi * 2 * i / rootletCount) + (progress * math.pi);
      final length = 8.0 * progress;
      final startX = centerX + math.cos(angle) * 15;
      final startY = trunkY + math.sin(angle) * 15;
      final endX = startX + math.cos(angle) * length;
      final endY = startY + math.sin(angle) * length;

      canvas.drawLine(
        Offset(startX, startY),
        Offset(endX, endY),
        paint,
      );
    }
  }

  @override
  bool shouldRepaint(RootsPainter oldDelegate) {
    return oldDelegate.progress != progress || oldDelegate.color != color;
  }
}

