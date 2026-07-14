import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

/// The Proxi brand mark: radar rings around a "P", matching the generated
/// app icon (see docs/BRANDING.md). Optionally animates a looping radar
/// pulse, reinforcing the "proximity" concept.
class ProxiMark extends StatefulWidget {
  const ProxiMark({super.key, this.size = 96, this.animate = true});

  final double size;
  final bool animate;

  @override
  State<ProxiMark> createState() => _ProxiMarkState();
}

class _ProxiMarkState extends State<ProxiMark> with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(seconds: 2),
  );

  @override
  void initState() {
    super.initState();
    if (widget.animate) _controller.repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: widget.size,
      height: widget.size,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          return CustomPaint(
            painter: _RadarPainter(pulse: widget.animate ? _controller.value : 0),
            child: child,
          );
        },
        child: Center(
          child: Text(
            'P',
            style: TextStyle(
              fontSize: widget.size * 0.46,
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
  _RadarPainter({required this.pulse});

  /// 0..1 looping progress used to animate an outward radar pulse.
  final double pulse;

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

    if (pulse > 0) {
      final pulseRadius = maxRadius * 0.3 + (maxRadius * 0.65 * pulse);
      final pulseOpacity = (1 - pulse).clamp(0.0, 1.0) * 0.5;
      final pulsePaint = Paint()
        ..color = AppColors.radarGreen.withValues(alpha: pulseOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = size.shortestSide * 0.03;
      canvas.drawCircle(center, pulseRadius, pulsePaint);
    }

    final dotPaint = Paint()..color = AppColors.radarGreen;
    canvas.drawCircle(center, size.shortestSide * 0.05, dotPaint);
  }

  @override
  bool shouldRepaint(covariant _RadarPainter oldDelegate) => oldDelegate.pulse != pulse;
}
