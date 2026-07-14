import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The Proxi brand mark: radar rings around a "P", matching the generated
/// app icon (see docs/BRANDING.md).
class ProxiMark extends StatelessWidget {
  const ProxiMark({super.key, this.size = 96});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: size,
      height: size,
      child: CustomPaint(
        painter: _RadarPainter(),
        child: Center(
          child: Text(
            'P',
            style: TextStyle(
              fontSize: size * 0.46,
              fontWeight: FontWeight.w800,
              color: Colors.white,
              height: 1,
            ),
          ),
        ),
      ),
    );
  }
}

class _RadarPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final maxRadius = size.shortestSide / 2;

    final bgPaint = Paint()..color = AppColors.deepNavy;
    canvas.drawCircle(center, maxRadius, bgPaint);

    for (var i = 3; i >= 1; i--) {
      final radius = maxRadius * 0.9 * i / 3;
      final paint = Paint()
        ..color = AppColors.radarGreen.withValues(alpha: 0.15 + 0.15 * (3 - i))
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.02;
      canvas.drawCircle(center, radius, paint);
    }

    final dotPaint = Paint()..color = AppColors.radarGreen;
    canvas.drawCircle(center, size.shortestSide * 0.05, dotPaint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
