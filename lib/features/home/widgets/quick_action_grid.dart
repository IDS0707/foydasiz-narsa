import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';

class QuickActionGrid extends StatelessWidget {
  const QuickActionGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final List<_QuickAction> actions = <_QuickAction>[
      _QuickAction(
        icon: Icons.check_circle_outline_rounded,
        labelKey: 'tasks_title',
        gradient: AppColors.primaryGradient,
        glow: AppColors.primary,
        onTap: () => context.go('/tasks'),
      ),
      _QuickAction(
        icon: Icons.account_balance_wallet_rounded,
        labelKey: 'finance_title',
        gradient: AppColors.indigoGradient,
        glow: AppColors.indigo,
        onTap: () => context.go('/finance'),
      ),
      _QuickAction(
        icon: Icons.local_fire_department_rounded,
        labelKey: 'habits_title',
        gradient: AppColors.sunsetGradient,
        glow: AppColors.amber,
        onTap: () => context.go('/habits'),
      ),
      _QuickAction(
        icon: Icons.alarm_rounded,
        labelKey: 'reminders_title',
        gradient: AppColors.pinkGradient,
        glow: AppColors.pink,
        onTap: () => context.push('/reminders'),
      ),
      _QuickAction(
        icon: Icons.shopping_cart_rounded,
        labelKey: 'shopping_title',
        gradient: AppColors.emeraldGradient,
        glow: AppColors.emerald,
        onTap: () => context.push('/shopping'),
      ),
    ];

    return SizedBox(
      height: 110,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        itemCount: actions.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int i) {
          final _QuickAction a = actions[i];
          return _ActionTile(action: a)
              .animate(delay: (i * 60).ms)
              .fadeIn(duration: 320.ms)
              .slideY(begin: 0.2, curve: Curves.easeOutCubic);
        },
      ),
    );
  }
}

class _QuickAction {
  const _QuickAction({
    required this.icon,
    required this.labelKey,
    required this.gradient,
    required this.glow,
    required this.onTap,
  });

  final IconData icon;
  final String labelKey;
  final Gradient gradient;
  final Color glow;
  final VoidCallback onTap;
}

class _ActionTile extends StatelessWidget {
  const _ActionTile({required this.action});
  final _QuickAction action;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: action.onTap,
      child: Container(
        width: 92,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(22),
          border: Border.all(
            color: Theme.of(context).dividerColor.withOpacity(0.6),
          ),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: action.glow.withOpacity(0.10),
              blurRadius: 18,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                gradient: action.gradient,
                borderRadius: BorderRadius.circular(14),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: action.glow.withOpacity(0.45),
                    blurRadius: 14,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Icon(action.icon, color: Colors.white, size: 22),
            ),
            const SizedBox(height: 8),
            Text(
              context.tr(action.labelKey),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 12,
                letterSpacing: 0.1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
