import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/app_theme.dart';

/// A radial OEE gauge with an animated sweep and a colour that reflects the
/// score band (good / warning / poor).
class OeeGauge extends StatelessWidget {
  final double value; // 0..100
  final double size;
  final String label;
  final double strokeWidth;

  const OeeGauge({
    super.key,
    required this.value,
    this.size = 160,
    this.label = 'OEE',
    this.strokeWidth = 14,
  });

  // Single flat light-blue arc (no health-band colours, no gradient).
  Color get _bandColor => AppColors.brand;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final onSurface = Theme.of(context).colorScheme.onSurface;
    final onVar = Theme.of(context).colorScheme.onSurfaceVariant;

    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: value.clamp(0, 100)),
      duration: const Duration(milliseconds: 900),
      curve: Curves.easeOutCubic,
      builder: (context, v, _) {
        return SizedBox(
          width: size,
          height: size,
          child: Stack(alignment: Alignment.center, children: [
            CustomPaint(
              size: Size(size, size),
              painter: _GaugePainter(
                value: v,
                color: _bandColor,
                track: isDark ? AppColors.slate800 : AppColors.slate100,
                strokeWidth: strokeWidth,
              ),
            ),
            Column(mainAxisSize: MainAxisSize.min, children: [
              Text(
                '${v.toStringAsFixed(1)}%',
                style: GoogleFonts.poppins(
                  color: onSurface,
                  fontSize: size * 0.2,
                  fontWeight: FontWeight.w800,
                ),
              ),
              Text(
                label,
                style: GoogleFonts.poppins(
                  color: onVar,
                  fontSize: size * 0.08,
                  fontWeight: FontWeight.w500,
                  letterSpacing: 1.5,
                ),
              ),
            ]),
          ]),
        );
      },
    );
  }
}

class _GaugePainter extends CustomPainter {
  final double value;
  final Color color;
  final Color track;
  final double strokeWidth;

  _GaugePainter({
    required this.value,
    required this.color,
    required this.track,
    required this.strokeWidth,
  });

  // 270° arc, starting bottom-left.
  static const double _start = math.pi * 0.75;
  static const double _sweep = math.pi * 1.5;

  @override
  void paint(Canvas canvas, Size size) {
    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );

    final trackPaint = Paint()
      ..color = track
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep, false, trackPaint);

    final valuePaint = Paint()
      ..color = color
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawArc(rect, _start, _sweep * (value / 100), false, valuePaint);
  }

  @override
  bool shouldRepaint(covariant _GaugePainter old) =>
      old.value != value || old.color != color || old.track != track;
}
