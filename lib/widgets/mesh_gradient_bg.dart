import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

/// Animated mesh-gradient backdrop. Slow-drifting radial blobs behind the
/// frosted-glass content. Dark mode leans into a technical cyan/blue/amber
/// palette that suits a control-room feel; light mode uses soft pastels.
class MeshGradientBg extends StatefulWidget {
  final Widget child;
  const MeshGradientBg({super.key, required this.child});

  @override
  State<MeshGradientBg> createState() => _MeshGradientBgState();
}

class _MeshGradientBgState extends State<MeshGradientBg>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: const Duration(seconds: 20))
          ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Container(
          decoration: BoxDecoration(
            // Light mode: one flat light-blue ("biru muda"), no colourful mesh.
            color: isDark ? null : const Color(0xFFDCEDFC),
            gradient: isDark
                ? const LinearGradient(
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                    colors: [Color(0xFF0F172A), Color(0xFF111C33), Color(0xFF020617)],
                  )
                : null,
          ),
          child: CustomPaint(
            painter: _MeshPainter(_controller.value, isDark),
            child: widget.child,
          ),
        );
      },
    );
  }
}

class _MeshPainter extends CustomPainter {
  final double t;
  final bool isDark;
  _MeshPainter(this.t, this.isDark);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final a = t * 2 * math.pi;

    void blob(Offset c, double r, Color color) {
      paint.shader = RadialGradient(
        colors: [color, color.withOpacity(0.0)],
      ).createShader(Rect.fromCircle(center: c, radius: r));
      canvas.drawCircle(c, r, paint);
    }

    if (isDark) {
      blob(
        Offset(size.width * (0.22 + 0.15 * math.sin(a)),
            size.height * (0.14 + 0.10 * math.cos(a))),
        size.width * 0.55,
        AppColors.cyan.withOpacity(0.13),
      );
      blob(
        Offset(size.width * (0.80 + 0.10 * math.cos(a + 1.5)),
            size.height * (0.48 + 0.12 * math.sin(a + 1.5))),
        size.width * 0.48,
        AppColors.blue.withOpacity(0.11),
      );
      blob(
        Offset(size.width * (0.5 + 0.18 * math.sin(a + 3.0)),
            size.height * (0.88 + 0.06 * math.cos(a + 3.0))),
        size.width * 0.42,
        AppColors.amber.withOpacity(0.08),
      );
    }
    // Light mode: intentionally no blobs — a single flat light-blue backdrop.
  }

  @override
  bool shouldRepaint(covariant _MeshPainter old) =>
      old.t != t || old.isDark != isDark;
}
