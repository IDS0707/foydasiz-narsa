import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../core/theme/app_colors.dart';

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    this.gradient = AppColors.primaryGradient,
    this.ctaLabel,
    this.onCta,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final Gradient gradient;
  final String? ctaLabel;
  final VoidCallback? onCta;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
            width: 96,
            height: 96,
            decoration: BoxDecoration(
              gradient: gradient,
              borderRadius: BorderRadius.circular(28),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: (gradient as LinearGradient)
                      .colors
                      .last
                      .withValues(alpha: 0.45),
                  blurRadius: 26,
                  offset: const Offset(0, 14),
                ),
              ],
            ),
            child: Icon(icon, color: Colors.white, size: 44),
          )
              .animate()
              .scale(
                begin: const Offset(0.85, 0.85),
                duration: 360.ms,
                curve: Curves.easeOutBack,
              )
              .fadeIn(),
          const SizedBox(height: 18),
          Text(
            title,
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w800,
                  fontSize: 20,
                  letterSpacing: -0.3,
                ),
          ).animate(delay: 80.ms).fadeIn(duration: 320.ms).slideY(begin: 0.06),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 28),
            child: Text(
              subtitle,
              textAlign: TextAlign.center,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontWeight: FontWeight.w500,
                    height: 1.45,
                  ),
            ),
          )
              .animate(delay: 160.ms)
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.06),
          if (ctaLabel != null && onCta != null) ...<Widget>[
            const SizedBox(height: 22),
            GestureDetector(
              onTap: onCta,
              child: Container(
                padding: const EdgeInsets.symmetric(
                    horizontal: 22, vertical: 14),
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withValues(alpha: 0.42),
                      blurRadius: 18,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    const Icon(Icons.add_rounded,
                        color: Colors.white, size: 20),
                    const SizedBox(width: 8),
                    Text(
                      ctaLabel!,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 14.5,
                      ),
                    ),
                  ],
                ),
              ),
            )
                .animate(delay: 220.ms)
                .fadeIn(duration: 320.ms)
                .slideY(begin: 0.06),
          ],
        ],
      ),
    );
  }
}
