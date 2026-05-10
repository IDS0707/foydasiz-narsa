import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class ProgressRing extends StatelessWidget {
  const ProgressRing({
    super.key,
    required this.progress,
    this.size = 120,
    this.strokeWidth = 12,
    this.gradient = AppColors.primaryGradient,
    this.trackColor,
    this.center,
  });

  final double progress;
  final double size;
  final double strokeWidth;
  final Gradient gradient;
  final Color? trackColor;
  final Widget? center;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return SizedBox(
      width: size,
      height: size,
      child: Stack(
        alignment: Alignment.center,
        children: <Widget>[
          CustomPaint(
            size: Size.square(size),
            painter: _RingPainter(
              progress: progress.clamp(0, 1),
              strokeWidth: strokeWidth,
              gradient: gradient,
              trackColor: trackColor ??
                  (isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFEEF0F5)),
            ),
          ),
          if (center != null) center!,
        ],
      ),
    );
  }
}

class _RingPainter extends CustomPainter {
  _RingPainter({
    required this.progress,
    required this.strokeWidth,
    required this.gradient,
    required this.trackColor,
  });

  final double progress;
  final double strokeWidth;
  final Gradient gradient;
  final Color trackColor;

  @override
  void paint(Canvas canvas, Size size) {
    final Offset center = Offset(size.width / 2, size.height / 2);
    final double radius = (size.shortestSide - strokeWidth) / 2;
    final Rect rect = Rect.fromCircle(center: center, radius: radius);

    final Paint track = Paint()
      ..color = trackColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;
    canvas.drawCircle(center, radius, track);

    final Paint arc = Paint()
      ..shader = gradient.createShader(rect)
      ..style = PaintingStyle.stroke
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawArc(rect, -math.pi / 2, 2 * math.pi * progress, false, arc);
  }

  @override
  bool shouldRepaint(covariant _RingPainter old) =>
      old.progress != progress ||
      old.strokeWidth != strokeWidth ||
      old.trackColor != trackColor;
}
