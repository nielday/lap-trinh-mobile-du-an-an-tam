import 'package:flutter/material.dart';
import '../theme/app_colors.dart';

/// Mascot avatar widget - the cute character icon for An Tâm app
/// Matches the design with rounded shoulders and simple face
class MascotAvatar extends StatelessWidget {
  const MascotAvatar({
    super.key,
    this.size = 120,
  });

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _MascotPainter(),
      ),
    );
  }
}

class _MascotPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final Paint strokePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2.5
      ..strokeCap = StrokeCap.round
      ..strokeJoin = StrokeJoin.round;

    final double centerX = size.width / 2;
    final double headRadius = size.width * 0.25;
    final double headCenterY = size.height * 0.28;

    // Draw head (circle)
    canvas.drawCircle(
      Offset(centerX, headCenterY),
      headRadius,
      strokePaint,
    );

    // Draw eyes - small filled dots
    final double eyeY = headCenterY - headRadius * 0.15;
    final double eyeSpacing = headRadius * 0.5;
    final double eyeRadius = size.width * 0.022;

    final Paint eyePaint = Paint()
      ..color = AppColors.primaryGreen
      ..style = PaintingStyle.fill;

    // Left eye
    canvas.drawCircle(
      Offset(centerX - eyeSpacing, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Right eye
    canvas.drawCircle(
      Offset(centerX + eyeSpacing, eyeY),
      eyeRadius,
      eyePaint,
    );

    // Draw smile - curved arc
    final double smileY = headCenterY + headRadius * 0.2;
    final double smileWidth = headRadius * 0.5;

    final Path smilePath = Path()
      ..moveTo(centerX - smileWidth, smileY)
      ..quadraticBezierTo(
        centerX,
        smileY + headRadius * 0.35,
        centerX + smileWidth,
        smileY,
      );

    canvas.drawPath(
      smilePath,
      strokePaint..strokeWidth = 2.0,
    );

    // Draw body - simple U-shape with rounded shoulders
    final double bodyStartY = headCenterY + headRadius + size.height * 0.03;
    final double shoulderWidth = size.width * 0.15;
    final double bodyDepth = size.height * 0.38;

    final Path bodyPath = Path()
      // Start from left shoulder top
      ..moveTo(centerX - shoulderWidth, bodyStartY)
      // Left shoulder and side
      ..quadraticBezierTo(
        centerX - shoulderWidth * 2.2,
        bodyStartY + bodyDepth * 0.25,
        centerX - shoulderWidth * 2,
        bodyStartY + bodyDepth * 0.7,
      )
      // Bottom curve
      ..quadraticBezierTo(
        centerX,
        bodyStartY + bodyDepth,
        centerX + shoulderWidth * 2,
        bodyStartY + bodyDepth * 0.7,
      )
      // Right shoulder and side
      ..quadraticBezierTo(
        centerX + shoulderWidth * 2.2,
        bodyStartY + bodyDepth * 0.25,
        centerX + shoulderWidth,
        bodyStartY,
      );

    canvas.drawPath(bodyPath, strokePaint..strokeWidth = 2.5);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
