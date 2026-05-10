import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class OnbBackground extends StatelessWidget {
  const OnbBackground({super.key});

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -120,
              right: -100,
              child: _Blob(
                color: AppColors.primary
                    .withValues(alpha: isDark ? 0.42 : 0.22),
                size: 360,
              ),
            ),
            Positioned(
              top: 100,
              left: -120,
              child: _Blob(
                color: AppColors.indigo
                    .withValues(alpha: isDark ? 0.34 : 0.18),
                size: 280,
              ),
            ),
            Positioned(
              bottom: -100,
              right: -80,
              child: _Blob(
                color: AppColors.pink
                    .withValues(alpha: isDark ? 0.22 : 0.14),
                size: 280,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _Blob extends StatelessWidget {
  const _Blob({required this.color, required this.size});
  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          colors: <Color>[color, color.withValues(alpha: 0)],
        ),
      ),
    );
  }
}
