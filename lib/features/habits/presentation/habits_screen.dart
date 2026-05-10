import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/habit_model.dart';
import '../providers/habits_provider.dart';
import 'widgets/add_habit_sheet.dart';

class HabitsScreen extends ConsumerWidget {
  const HabitsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HabitItem> habits = ref.watch(habitsProvider);
    final HabitsStats stats = ref.watch(habitsStatsProvider);

    return Scaffold(
      floatingActionButton: _AddHabitFab(onTap: () => _openAdd(context)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _Header(stats: stats),
            const SizedBox(height: 22),
            SectionHeader(title: context.tr('habits_week')),
            _WeekStrip(),
            const SizedBox(height: 18),
            SectionHeader(title: context.tr('habits_today')),
            if (habits.isEmpty)
              EmptyState(
                icon: Icons.local_fire_department_rounded,
                title: context.tr('empty_habits_title'),
                subtitle: context.tr('empty_habits_sub'),
                ctaLabel: context.tr('empty_habits_cta'),
                onCta: () => _openAdd(context),
                gradient: AppColors.sunsetGradient,
              )
            else
              ...List<Widget>.generate(habits.length, (int i) {
                final HabitItem h = habits[i];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: _HabitCard(habit: h)
                      .animate(delay: (i * 50).ms)
                      .fadeIn(duration: 320.ms)
                      .slideY(begin: 0.06, curve: Curves.easeOutCubic),
                );
              }),
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const AddHabitSheet(),
    );
  }
}

class _AddHabitFab extends StatelessWidget {
  const _AddHabitFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70, right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withValues(alpha: 0.5),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                context.tr('habits_add'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.stats});
  final HabitsStats stats;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppColors.sunsetGradient,
      glowColor: AppColors.amber,
      padding: const EdgeInsets.all(22),
      child: Row(
        children: <Widget>[
          ProgressRing(
            progress: stats.ratio,
            size: 100,
            strokeWidth: 10,
            gradient: const LinearGradient(
              colors: <Color>[Colors.white, Color(0xFFFFEDD5)],
            ),
            trackColor: Colors.white.withOpacity(0.22),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '${stats.doneToday}/${stats.total}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                  ),
                ),
                Text(
                  context.tr('habits_today'),
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 11,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.tr('habits_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 6),
                Row(
                  children: <Widget>[
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 5),
                      decoration: BoxDecoration(
                        color: Colors.white.withOpacity(0.22),
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          const Icon(Icons.local_fire_department_rounded,
                              color: Colors.white, size: 14),
                          const SizedBox(width: 4),
                          Text(
                            '${stats.bestStreak} ${context.tr('home_days')}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w700,
                              fontSize: 12,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _WeekStrip extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final DateTime now = DateTime.now();
    final List<DateTime> days = List<DateTime>.generate(
        7, (int i) => now.subtract(Duration(days: 6 - i)));
    const List<String> wd = <String>['M', 'T', 'W', 'T', 'F', 'S', 'S'];

    return SoftCard(
      padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 12),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: List<Widget>.generate(7, (int i) {
          final DateTime d = days[i];
          final bool isToday = d.year == now.year &&
              d.month == now.month &&
              d.day == now.day;
          return Column(
            children: <Widget>[
              Text(
                wd[i],
                style: TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 11,
                  color: Theme.of(context).textTheme.bodySmall?.color,
                ),
              ),
              const SizedBox(height: 6),
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: isToday ? AppColors.primaryGradient : null,
                  shape: BoxShape.circle,
                  boxShadow: isToday
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.4),
                            blurRadius: 12,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Text(
                  '${d.day}',
                  style: TextStyle(
                    color: isToday
                        ? Colors.white
                        : Theme.of(context).textTheme.bodyLarge?.color,
                    fontWeight: FontWeight.w700,
                    fontSize: 13.5,
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }
}

class _HabitCard extends ConsumerWidget {
  const _HabitCard({required this.habit});
  final HabitItem habit;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final DateTime now = DateTime.now();
    final List<DateTime> last7 = List<DateTime>.generate(
        7, (int i) => DateTime(now.year, now.month, now.day)
            .subtract(Duration(days: 6 - i)));

    return SoftCard(
      padding: const EdgeInsets.all(16),
      onTap: () => ref.read(habitsProvider.notifier).toggleToday(habit.id),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  gradient: habit.gradient,
                  borderRadius: BorderRadius.circular(15),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: (habit.gradient as LinearGradient)
                          .colors
                          .last
                          .withOpacity(0.35),
                      blurRadius: 14,
                      offset: const Offset(0, 8),
                    ),
                  ],
                ),
                child: Icon(habit.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: <Widget>[
                    Text(
                      habit.name,
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 15.5),
                    ),
                    const SizedBox(height: 2),
                    Row(
                      children: <Widget>[
                        const Icon(Icons.local_fire_department_rounded,
                            color: AppColors.amber, size: 14),
                        const SizedBox(width: 4),
                        Text(
                          '${habit.streak} ${context.tr('habits_streak')}',
                          style: TextStyle(
                            color: Theme.of(context).textTheme.bodySmall?.color,
                            fontWeight: FontWeight.w600,
                            fontSize: 12,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              GestureDetector(
                onTap: () =>
                    ref.read(habitsProvider.notifier).toggleToday(habit.id),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 240),
                  curve: Curves.easeOutCubic,
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: habit.isDoneToday ? habit.gradient : null,
                    color: habit.isDoneToday
                        ? null
                        : Theme.of(context).cardColor,
                    border: habit.isDoneToday
                        ? null
                        : Border.all(
                            color: Theme.of(context).dividerColor,
                            width: 1.6,
                          ),
                    borderRadius: BorderRadius.circular(13),
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    child: habit.isDoneToday
                        ? const Icon(Icons.check_rounded,
                            color: Colors.white,
                            size: 20,
                            key: ValueKey<bool>(true))
                        : const SizedBox.shrink(key: ValueKey<bool>(false)),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: List<Widget>.generate(7, (int i) {
              final bool done = habit.isDoneOn(last7[i]);
              return Container(
                width: 28,
                height: 28,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  gradient: done ? habit.gradient : null,
                  color:
                      done ? null : Theme.of(context).dividerColor.withOpacity(0.5),
                  shape: BoxShape.circle,
                ),
                child: done
                    ? const Icon(Icons.check_rounded,
                        size: 14, color: Colors.white)
                    : null,
              );
            }),
          ),
        ],
      ),
    );
  }
}
