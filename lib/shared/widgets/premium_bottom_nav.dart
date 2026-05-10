import 'dart:ui';

import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

class PremiumNavItem {
  const PremiumNavItem({required this.icon, required this.label});
  final IconData icon;
  final String label;
}

class PremiumBottomNav extends StatelessWidget {
  const PremiumBottomNav({
    super.key,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
    this.accent = AppColors.primary,
  });

  final List<PremiumNavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;
  final Color accent;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final Color barColor = (isDark ? AppColors.cardDark : Colors.white)
        .withOpacity(isDark ? 0.78 : 0.78);

    return SafeArea(
      top: false,
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 22, sigmaY: 22),
            child: Container(
              height: 74,
              decoration: BoxDecoration(
                color: barColor,
                borderRadius: BorderRadius.circular(28),
                border: Border.all(
                  color: isDark
                      ? Colors.white.withOpacity(0.06)
                      : Colors.white.withOpacity(0.6),
                ),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withOpacity(isDark ? 0.5 : 0.10),
                    blurRadius: 30,
                    offset: const Offset(0, 18),
                  ),
                ],
              ),
              child: Row(
                children: List<Widget>.generate(items.length, (int i) {
                  final bool active = i == selectedIndex;
                  return Expanded(
                    child: _NavButton(
                      item: items[i],
                      active: active,
                      accent: accent,
                      onTap: () => onTap(i),
                    ),
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavButton extends StatelessWidget {
  const _NavButton({
    required this.item,
    required this.active,
    required this.accent,
    required this.onTap,
  });

  final PremiumNavItem item;
  final bool active;
  final Color accent;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final Color inactive = Theme.of(context).brightness == Brightness.dark
        ? Colors.white.withOpacity(0.55)
        : const Color(0xFF6B7280);

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(22),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 280),
        curve: Curves.easeOutCubic,
        margin: const EdgeInsets.all(8),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          borderRadius: BorderRadius.circular(20),
          boxShadow: active
              ? <BoxShadow>[
                  BoxShadow(
                    color: accent.withOpacity(0.35),
                    blurRadius: 18,
                    offset: const Offset(0, 8),
                  ),
                ]
              : null,
        ),
        child: FittedBox(
          fit: BoxFit.scaleDown,
          child: Row(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              Icon(
                item.icon,
                color: active ? Colors.white : inactive,
                size: 22,
              ),
              AnimatedSize(
                duration: const Duration(milliseconds: 260),
                curve: Curves.easeOutCubic,
                child: active
                    ? Padding(
                        padding: const EdgeInsets.only(left: 8),
                        child: Text(
                          item.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                            letterSpacing: 0.2,
                          ),
                        ),
                      )
                    : const SizedBox.shrink(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
