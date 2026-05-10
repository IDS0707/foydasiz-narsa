import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../core/localization/app_localizations.dart';
import '../../core/theme/app_colors.dart';
import 'premium_bottom_nav.dart';

class AppShell extends StatelessWidget {
  const AppShell({
    super.key,
    required this.location,
    required this.child,
  });

  final String location;
  final Widget child;

  static const List<_NavTab> _tabs = <_NavTab>[
    _NavTab('/home', Icons.home_rounded, 'nav_home'),
    _NavTab('/tasks', Icons.check_circle_outline_rounded, 'nav_tasks'),
    _NavTab('/finance', Icons.show_chart_rounded, 'nav_finance'),
    _NavTab('/habits', Icons.local_fire_department_outlined, 'nav_habits'),
    _NavTab('/profile', Icons.person_outline_rounded, 'nav_profile'),
  ];

  int _selectedIndex() {
    for (int i = 0; i < _tabs.length; i++) {
      if (location.startsWith(_tabs[i].path)) return i;
    }
    return 0;
  }

  @override
  Widget build(BuildContext context) {
    final int idx = _selectedIndex();
    return Scaffold(
      extendBody: true,
      body: child,
      bottomNavigationBar: PremiumBottomNav(
        selectedIndex: idx,
        items: _tabs
            .map((_NavTab t) => PremiumNavItem(
                  icon: t.icon,
                  label: context.tr(t.labelKey),
                ))
            .toList(),
        onTap: (int i) {
          if (i == 2) {
            // Center FAB-like tab opens Finance.
            context.go(_tabs[i].path);
          } else {
            context.go(_tabs[i].path);
          }
        },
        accent: AppColors.primary,
      ),
    );
  }
}

class _NavTab {
  const _NavTab(this.path, this.icon, this.labelKey);
  final String path;
  final IconData icon;
  final String labelKey;
}
