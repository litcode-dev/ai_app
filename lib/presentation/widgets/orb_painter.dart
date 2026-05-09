import 'dart:math';
import 'dart:ui' as ui;

import 'package:flutter/material.dart';

import '../../core/theme/colors.dart';

class OrbPainter extends CustomPainter {
  final List<double> ringAngles;
  final double breathe;
  final double coreBreathe;
  final AccentColors accent;

  const OrbPainter({
    required this.ringAngles,
    required this.breathe,
    required this.coreBreathe,
    required this.accent,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final R = size.width / 2;
    final breatheScale = 1.0 + sin(breathe * pi) * 0.08;

    _drawBackgroundGlow(canvas, center, R, breatheScale);
    _drawRings(canvas, center, R);
    _drawCore(canvas, center, R);
  }

  void _drawBackgroundGlow(Canvas canvas, Offset center, double R, double scale) {
    final effectiveR = R * 0.92 * scale;
    final rect = Rect.fromCircle(center: center, radius: effectiveR);
    final paint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(0, 0.1),
            radius: 0.62,
            colors: [accent.glow, accent.glowMid, Colors.transparent],
            stops: const [0.0, 0.28, 0.62],
          ).createShader(rect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 16);
    canvas.drawCircle(center, effectiveR, paint);
  }

  void _drawRings(Canvas canvas, Offset center, double R) {
    final configs = [
      (inset: 0.14, opacity: 1.0),
      (inset: 0.22, opacity: 1.0),
      (inset: 0.28, opacity: 0.85),
      (inset: 0.34, opacity: 0.70),
      (inset: 0.40, opacity: 0.60),
    ];

    for (int i = 0; i < configs.length; i++) {
      final cfg = configs[i];
      final outerR = R * (1 - cfg.inset);
      final innerR = (outerR - 2.0).clamp(0.0, outerR);

      final path =
          Path()
            ..fillType = PathFillType.evenOdd
            ..addOval(Rect.fromCircle(center: center, radius: outerR))
            ..addOval(Rect.fromCircle(center: center, radius: innerR));

      final rotation = ringAngles[i];
      final colors = [
        Colors.transparent,
        accent.line.withValues(alpha: cfg.opacity),
        Colors.transparent,
        accent.line.withValues(alpha: cfg.opacity),
        Colors.transparent,
        accent.line.withValues(alpha: cfg.opacity),
        Colors.transparent,
      ];
      const stops = [0.0, 40 / 360, 90 / 360, 200 / 360, 250 / 360, 320 / 360, 1.0];

      final paint =
          Paint()
            ..shader = ui.Gradient.sweep(
              center,
              colors,
              stops,
              TileMode.clamp,
              rotation,
              rotation + 2 * pi,
            )
            ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 0.6);

      canvas.drawPath(path, paint);
    }
  }

  void _drawCore(Canvas canvas, Offset center, double R) {
    final coreScale = 1.0 + sin(coreBreathe * pi) * 0.08;
    final coreR = R * 0.64 * coreScale;
    final rect = Rect.fromCircle(center: center, radius: coreR);
    final paint =
        Paint()
          ..shader = RadialGradient(
            center: const Alignment(-0.2, -0.3),
            radius: 0.8,
            colors: [
              Colors.white.withValues(alpha: 0.9),
              accent.core.withValues(alpha: 0.8),
              accent.glow,
              Colors.transparent,
            ],
            stops: const [0.0, 0.22, 0.60, 0.80],
          ).createShader(rect)
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 8);
    canvas.drawCircle(center, coreR, paint);
  }

  @override
  bool shouldRepaint(OrbPainter old) =>
      ringAngles != old.ringAngles ||
      breathe != old.breathe ||
      coreBreathe != old.coreBreathe ||
      accent != old.accent;
}
