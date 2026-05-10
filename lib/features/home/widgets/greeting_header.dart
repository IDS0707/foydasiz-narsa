import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class GreetingHeader extends ConsumerWidget {
  const GreetingHeader({super.key, this.name});
  final String? name;

  static String _greetingKey() {
    final int h = DateTime.now().hour;
    if (h < 12) return 'greeting_morning';
    if (h < 17) return 'greeting_afternoon';
    if (h < 22) return 'greeting_evening';
    return 'greeting_night';
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final String displayName =
        (name == null || name!.trim().isEmpty) ? '' : name!.trim();
    final String headline = displayName.isEmpty
        ? context.tr('motivational_text')
        : '${context.tr('home_hi')}, $displayName';
    return Padding(
      padding: const EdgeInsets.fromLTRB(2, 4, 2, 0),
      child: Row(
        children: <Widget>[
          Container(
            width: 46,
            height: 46,
            decoration: BoxDecoration(
              gradient: AppColors.primaryGradient,
              borderRadius: BorderRadius.circular(14),
              boxShadow: <BoxShadow>[
                BoxShadow(
                  color: AppColors.primary.withValues(alpha: 0.4),
                  blurRadius: 14,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: const Icon(Icons.hub_rounded, color: Colors.white, size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.tr(_greetingKey()),
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  headline,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: Theme.of(context)
                      .textTheme
                      .titleLarge
                      ?.copyWith(
                          fontSize: 22,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5),
                ),
              ],
            ),
          ),
          _CircleIconButton(
            icon: Icons.notifications_none_rounded,
            badge: true,
            isDark: isDark,
            onTap: () => context.push('/reminders'),
          ),
          const SizedBox(width: 8),
          _CircleIconButton(
            icon: Icons.person_outline_rounded,
            isDark: isDark,
            onTap: () => context.go('/profile'),
          ),
        ],
      ),
    );
  }
}

class _CircleIconButton extends StatelessWidget {
  const _CircleIconButton({
    required this.icon,
    required this.isDark,
    required this.onTap,
    this.badge = false,
  });

  final IconData icon;
  final bool isDark;
  final VoidCallback onTap;
  final bool badge;

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: <Widget>[
        Material(
          color: Colors.transparent,
          child: InkWell(
            borderRadius: BorderRadius.circular(14),
            onTap: onTap,
            child: Ink(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: isDark ? AppColors.cardDark : Colors.white,
                borderRadius: BorderRadius.circular(14),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : const Color(0xFFEEF0F5),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color:
                        Colors.black.withOpacity(isDark ? 0.4 : 0.06),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(icon, size: 20),
            ),
          ),
        ),
        if (badge)
          Positioned(
            right: 10,
            top: 10,
            child: Container(
              width: 9,
              height: 9,
              decoration: BoxDecoration(
                color: AppColors.rose,
                shape: BoxShape.circle,
                border: Border.all(
                    color: isDark ? AppColors.cardDark : Colors.white,
                    width: 2),
              ),
            ),
          ),
      ],
    );
  }
}
