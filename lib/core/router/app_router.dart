import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/finance/presentation/finance_screen.dart';
import '../../features/habits/presentation/habits_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/onboarding/presentation/language_selection_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/profile/presentation/profile_screen.dart';
import '../../features/reminders/presentation/reminders_screen.dart';
import '../../features/shopping/presentation/shopping_screen.dart';
import '../../features/tasks/presentation/tasks_screen.dart';
import '../../features/user/providers/user_profile_provider.dart';
import '../../shared/widgets/app_shell.dart';
import '../localization/locale_provider.dart';

final Provider<GoRouter> appRouterProvider = Provider<GoRouter>((Ref ref) {
  return GoRouter(
    initialLocation: '/home',
    redirect: (BuildContext context, GoRouterState state) {
      final bool localeChosen = ref.read(isLocaleChosenProvider);
      final bool onboarded = ref.read(isOnboardedProvider);
      final String loc = state.matchedLocation;
      final bool atLanguage = loc == '/language';
      final bool atOnboarding = loc == '/onboarding';

      // 1. Force language picker until the user picks one explicitly.
      if (!localeChosen && !atLanguage) return '/language';
      if (localeChosen && atLanguage) {
        return onboarded ? '/home' : '/onboarding';
      }
      // 2. Once a language is chosen, force onboarding until profile saved.
      if (localeChosen && !onboarded && !atOnboarding) return '/onboarding';
      if (onboarded && atOnboarding) return '/home';
      return null;
    },
    routes: <RouteBase>[
      GoRoute(
        path: '/language',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const LanguageSelectionScreen()),
      ),
      GoRoute(
        path: '/onboarding',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _fade(state, const OnboardingScreen()),
      ),
      ShellRoute(
        builder: (BuildContext context, GoRouterState state, Widget child) {
          return AppShell(location: state.uri.path, child: child);
        },
        routes: <RouteBase>[
          GoRoute(
            path: '/home',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _fade(state, const HomeScreen()),
          ),
          GoRoute(
            path: '/tasks',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _fade(state, const TasksScreen()),
          ),
          GoRoute(
            path: '/finance',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _fade(state, const FinanceScreen()),
          ),
          GoRoute(
            path: '/habits',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _fade(state, const HabitsScreen()),
          ),
          GoRoute(
            path: '/profile',
            pageBuilder: (BuildContext context, GoRouterState state) =>
                _fade(state, const ProfileScreen()),
          ),
        ],
      ),
      GoRoute(
        path: '/reminders',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slide(state, const RemindersScreen()),
      ),
      GoRoute(
        path: '/shopping',
        pageBuilder: (BuildContext context, GoRouterState state) =>
            _slide(state, const ShoppingScreen()),
      ),
    ],
  );
});

CustomTransitionPage<void> _fade(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    reverseTransitionDuration: const Duration(milliseconds: 240),
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      final CurvedAnimation curved =
          CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
      return FadeTransition(
        opacity: curved,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.025),
            end: Offset.zero,
          ).animate(curved),
          child: ScaleTransition(
            scale: Tween<double>(begin: 0.98, end: 1).animate(curved),
            child: child,
          ),
        ),
      );
    },
  );
}

CustomTransitionPage<void> _slide(GoRouterState state, Widget child) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: const Duration(milliseconds: 360),
    transitionsBuilder: (
      BuildContext context,
      Animation<double> animation,
      Animation<double> secondaryAnimation,
      Widget child,
    ) {
      return SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.08),
          end: Offset.zero,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
        )),
        child: FadeTransition(opacity: animation, child: child),
      );
    },
  );
}
