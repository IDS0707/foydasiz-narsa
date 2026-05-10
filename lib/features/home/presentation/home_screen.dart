import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/progress_ring.dart';
import '../../../shared/widgets/section_header.dart';
import '../../finance/providers/finance_provider.dart';
import '../../habits/data/habit_model.dart';
import '../../habits/providers/habits_provider.dart';
import '../../reminders/data/reminder_model.dart';
import '../../reminders/providers/reminders_provider.dart';
import '../../shopping/providers/shopping_provider.dart';
import '../../tasks/data/task_model.dart';
import '../../tasks/presentation/widgets/add_task_sheet.dart';
import '../../tasks/providers/tasks_provider.dart';
import '../../user/data/user_profile.dart';
import '../../user/providers/user_profile_provider.dart';
import '../widgets/greeting_header.dart';
import '../widgets/quick_action_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final UserProfile? profile = ref.watch(userProfileProvider);
    final TasksStats tasksStats = ref.watch(tasksStatsProvider);
    final FinanceStats financeStats = ref.watch(financeStatsProvider);
    final HabitsStats habitsStats = ref.watch(habitsStatsProvider);

    return Scaffold(
      body: Stack(
        children: <Widget>[
          const _BgGradient(),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.fromLTRB(20, 8, 20, 120),
              physics: const BouncingScrollPhysics(),
              children: <Widget>[
                GreetingHeader(name: profile?.name),
                const SizedBox(height: 18),
                _DailyProgressCard(
                  tasks: tasksStats,
                  habits: habitsStats,
                  finance: financeStats,
                  taskGoal: profile?.dailyTaskGoal ?? 5,
                ).animate().fadeIn(duration: 420.ms).slideY(
                      begin: 0.06,
                      end: 0,
                      curve: Curves.easeOutCubic,
                    ),
                const SizedBox(height: 16),
                _SmartSummary(
                  finance: financeStats,
                  tasks: tasksStats,
                  habits: habitsStats,
                ),
                const SizedBox(height: 22),
                SectionHeader(title: context.tr('home_quick_actions')),
                const QuickActionGrid(),
                const SizedBox(height: 22),
                SectionHeader(
                  title: context.tr('home_today_tasks'),
                  actionText: context.tr('home_view_all'),
                  onAction: () => context.go('/tasks'),
                ),
                _TodayTasksPreview(
                  onCreate: () => _openAddTask(context),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ExpenseSummaryCard(
                        stats: financeStats,
                        onTap: () => context.go('/finance'),
                      ),
                    ),
                    const SizedBox(width: 14),
                    Expanded(child: _StreakCard(habits: habitsStats)),
                  ],
                ),
                const SizedBox(height: 22),
                SectionHeader(
                  title: context.tr('home_habits_today'),
                  actionText: context.tr('home_view_all'),
                  onAction: () => context.go('/habits'),
                ),
                _HabitsPreview(onCreate: () => context.go('/habits')),
                const SizedBox(height: 22),
                SectionHeader(
                  title: context.tr('home_reminders'),
                  actionText: context.tr('home_view_all'),
                  onAction: () => context.push('/reminders'),
                ),
                _RemindersPreview(onCreate: () => context.push('/reminders')),
                const SizedBox(height: 22),
                SectionHeader(
                  title: context.tr('home_shopping'),
                  actionText: context.tr('home_view_all'),
                  onAction: () => context.push('/shopping'),
                ),
                const _ShoppingPreview(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _openAddTask(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const AddTaskSheet(),
    );
  }
}

class _BgGradient extends StatelessWidget {
  const _BgGradient();

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Positioned.fill(
      child: IgnorePointer(
        child: Stack(
          children: <Widget>[
            Positioned(
              top: -120,
              right: -80,
              child: _Blob(
                color: AppColors.primary
                    .withValues(alpha: isDark ? 0.4 : 0.22),
                size: 320,
              ),
            ),
            Positioned(
              top: 80,
              left: -100,
              child: _Blob(
                color:
                    AppColors.indigo.withValues(alpha: isDark ? 0.3 : 0.18),
                size: 260,
              ),
            ),
            Positioned(
              bottom: 200,
              right: -60,
              child: _Blob(
                color:
                    AppColors.pink.withValues(alpha: isDark ? 0.18 : 0.12),
                size: 220,
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

class _DailyProgressCard extends StatelessWidget {
  const _DailyProgressCard({
    required this.tasks,
    required this.habits,
    required this.finance,
    required this.taskGoal,
  });

  final TasksStats tasks;
  final HabitsStats habits;
  final FinanceStats finance;
  final int taskGoal;

  @override
  Widget build(BuildContext context) {
    final double taskProgress =
        taskGoal == 0 ? 0 : (tasks.doneToday / taskGoal).clamp(0, 1);
    final double productivity =
        ((taskProgress * 0.6) + (habits.ratio * 0.4)).clamp(0, 1);
    final int productivityPct = (productivity * 100).round();

    return GradientCard(
      gradient: AppColors.primaryGradient,
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(22),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          ProgressRing(
            progress: productivity,
            size: 110,
            strokeWidth: 12,
            gradient: const LinearGradient(
              colors: <Color>[Colors.white, Color(0xFFE0E7FF)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            trackColor: Colors.white.withValues(alpha: 0.18),
            center: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Text(
                  '$productivityPct%',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 24,
                    letterSpacing: -0.5,
                  ),
                ),
                Text(
                  context.tr('home_productivity'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
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
                  context.tr('home_today_progress'),
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.85),
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.3,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  '${tasks.doneToday}/$taskGoal ${context.tr('nav_tasks').toLowerCase()}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.w800,
                    fontSize: 22,
                    letterSpacing: -0.5,
                    height: 1.1,
                  ),
                ),
                const SizedBox(height: 12),
                _StatChip(
                  icon: Icons.local_fire_department_rounded,
                  text: '${habits.bestStreak} ${context.tr('home_days')}',
                ),
                const SizedBox(height: 8),
                _StatChip(
                  icon: Icons.check_circle_rounded,
                  text:
                      '${habits.doneToday}/${habits.total} ${context.tr('habits_today').toLowerCase()}',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _SmartSummary extends StatelessWidget {
  const _SmartSummary({
    required this.finance,
    required this.tasks,
    required this.habits,
  });

  final FinanceStats finance;
  final TasksStats tasks;
  final HabitsStats habits;

  @override
  Widget build(BuildContext context) {
    final List<_SummaryLine> lines = <_SummaryLine>[];
    if (finance.income > 0 && finance.monthTotal > 0) {
      lines.add(_SummaryLine(
        icon: Icons.payments_rounded,
        gradient: AppColors.indigoGradient,
        text: context
            .tr('home_spent_pct_msg')
            .replaceAll('{pct}', finance.spentPct.toStringAsFixed(0)),
      ));
    }
    if (finance.income > 0 && finance.savingsRatio > 0) {
      lines.add(_SummaryLine(
        icon: Icons.savings_rounded,
        gradient: AppColors.emeraldGradient,
        text: context.tr('home_savings_msg').replaceAll(
            '{pct}', (finance.savingsRatio * 100).toStringAsFixed(0)),
      ));
    }
    if (habits.bestStreak >= 2) {
      lines.add(_SummaryLine(
        icon: Icons.local_fire_department_rounded,
        gradient: AppColors.sunsetGradient,
        text: context.tr('home_streak_growing'),
      ));
    }
    if (lines.isEmpty) return const SizedBox.shrink();

    return SoftCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('home_smart_summary'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 14.5),
          ),
          const SizedBox(height: 10),
          ...lines.map((_SummaryLine l) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 6),
                child: Row(
                  children: <Widget>[
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        gradient: l.gradient,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(l.icon, color: Colors.white, size: 16),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Text(
                        l.text,
                        style: const TextStyle(
                            fontWeight: FontWeight.w600, fontSize: 13.5),
                      ),
                    ),
                  ],
                ),
              )),
        ],
      ),
    );
  }
}

class _SummaryLine {
  const _SummaryLine({
    required this.icon,
    required this.gradient,
    required this.text,
  });
  final IconData icon;
  final Gradient gradient;
  final String text;
}

class _StatChip extends StatelessWidget {
  const _StatChip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: Colors.white.withValues(alpha: 0.18)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: Colors.white, size: 14),
          const SizedBox(width: 6),
          Text(
            text,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}

class _TodayTasksPreview extends ConsumerWidget {
  const _TodayTasksPreview({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<TaskItem> tasks = ref
        .watch(tasksProvider)
        .where((TaskItem t) => t.isToday)
        .take(4)
        .toList();

    if (tasks.isEmpty) {
      return SoftCard(
        padding: const EdgeInsets.all(8),
        child: EmptyState(
          icon: Icons.task_alt_rounded,
          title: context.tr('empty_tasks_title'),
          subtitle: context.tr('empty_tasks_sub'),
          ctaLabel: context.tr('empty_tasks_cta'),
          onCta: onCreate,
        ),
      );
    }

    return SoftCard(
      padding: const EdgeInsets.all(8),
      child: Column(
        children: List<Widget>.generate(tasks.length, (int i) {
          final TaskItem t = tasks[i];
          return _TaskRow(task: t, isLast: i == tasks.length - 1);
        }),
      ),
    );
  }
}

class _TaskRow extends ConsumerWidget {
  const _TaskRow({required this.task, required this.isLast});
  final TaskItem task;
  final bool isLast;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Column(
      children: <Widget>[
        InkWell(
          onTap: () => ref.read(tasksProvider.notifier).toggle(task.id),
          borderRadius: BorderRadius.circular(16),
          child: Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
            child: Row(
              children: <Widget>[
                AnimatedContainer(
                  duration: const Duration(milliseconds: 220),
                  width: 22,
                  height: 22,
                  decoration: BoxDecoration(
                    color: task.done
                        ? task.priority.color
                        : Colors.transparent,
                    border: Border.all(
                      color: task.done
                          ? task.priority.color
                          : task.priority.color.withValues(alpha: 0.5),
                      width: 1.6,
                    ),
                    borderRadius: BorderRadius.circular(7),
                  ),
                  child: task.done
                      ? const Icon(Icons.check_rounded,
                          color: Colors.white, size: 16)
                      : null,
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Text(
                    task.title,
                    style: TextStyle(
                      fontWeight: FontWeight.w600,
                      fontSize: 14.5,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.done
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                ),
                Text(
                  DateFormat('HH:mm').format(task.dueAt),
                  style: TextStyle(
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                  ),
                ),
              ],
            ),
          ),
        ),
        if (!isLast)
          Divider(
              height: 1,
              indent: 14,
              endIndent: 14,
              color: Theme.of(context).dividerColor.withValues(alpha: 0.6)),
      ],
    );
  }
}

class _ExpenseSummaryCard extends StatelessWidget {
  const _ExpenseSummaryCard({required this.stats, required this.onTap});
  final FinanceStats stats;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      padding: const EdgeInsets.all(18),
      onTap: onTap,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  gradient: AppColors.indigoGradient,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.account_balance_wallet_rounded,
                    color: Colors.white, size: 18),
              ),
              const Spacer(),
              const Icon(
                Icons.trending_up_rounded,
                color: AppColors.emerald,
                size: 16,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('home_expenses_today'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: stats.todayTotal.toStringAsFixed(0),
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        fontSize: 22,
                        letterSpacing: -0.5,
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                ),
                TextSpan(
                  text: ' ${stats.currencySymbol}',
                  style: TextStyle(
                    fontWeight: FontWeight.w600,
                    color: Theme.of(context).textTheme.bodySmall?.color,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: LinearProgressIndicator(
              value: stats.budgetRatio,
              minHeight: 6,
              backgroundColor:
                  Theme.of(context).dividerColor.withValues(alpha: 0.5),
              valueColor:
                  const AlwaysStoppedAnimation<Color>(AppColors.primary),
            ),
          ),
          const SizedBox(height: 6),
          Text(
            '${(stats.budgetRatio * 100).round()}% / ${context.tr('finance_budget')}',
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ),
        ],
      ),
    );
  }
}

class _StreakCard extends StatelessWidget {
  const _StreakCard({required this.habits});
  final HabitsStats habits;

  @override
  Widget build(BuildContext context) {
    return GradientCard(
      gradient: AppColors.sunsetGradient,
      glowColor: AppColors.amber,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.22),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(Icons.local_fire_department_rounded,
                    color: Colors.white, size: 20),
              ),
              const Spacer(),
              Text(
                '🔥',
                style: TextStyle(
                    fontSize: 18,
                    color: Colors.white.withValues(alpha: 0.9)),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            context.tr('home_streak'),
            style: TextStyle(
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              color: Colors.white.withValues(alpha: 0.85),
              letterSpacing: 0.2,
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: <Widget>[
              Text(
                '${habits.bestStreak}',
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                  fontSize: 26,
                  letterSpacing: -0.5,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                context.tr('home_days'),
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.85),
                  fontWeight: FontWeight.w600,
                  fontSize: 12,
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: List<Widget>.generate(7, (int i) {
              final bool active = i < habits.bestStreak.clamp(0, 7);
              return Expanded(
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 2),
                  height: 6,
                  decoration: BoxDecoration(
                    color: Colors.white
                        .withValues(alpha: active ? 0.95 : 0.28),
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _HabitsPreview extends ConsumerWidget {
  const _HabitsPreview({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<HabitItem> habits = ref.watch(habitsProvider);
    if (habits.isEmpty) {
      return SoftCard(
        padding: const EdgeInsets.all(8),
        child: EmptyState(
          icon: Icons.local_fire_department_rounded,
          title: context.tr('empty_habits_title'),
          subtitle: context.tr('empty_habits_sub'),
          ctaLabel: context.tr('empty_habits_cta'),
          onCta: onCreate,
          gradient: AppColors.sunsetGradient,
        ),
      );
    }

    return SizedBox(
      height: 130,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        physics: const BouncingScrollPhysics(),
        padding: EdgeInsets.zero,
        itemCount: habits.length,
        separatorBuilder: (_, __) => const SizedBox(width: 12),
        itemBuilder: (BuildContext context, int i) {
          final HabitItem h = habits[i];
          return GestureDetector(
            onTap: () =>
                ref.read(habitsProvider.notifier).toggleToday(h.id),
            child: Container(
              width: 130,
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                gradient: h.gradient,
                borderRadius: BorderRadius.circular(22),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.10),
                    blurRadius: 18,
                    offset: const Offset(0, 10),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Row(
                    children: <Widget>[
                      Container(
                        width: 34,
                        height: 34,
                        decoration: BoxDecoration(
                          color: Colors.white.withValues(alpha: 0.25),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Icon(h.icon, color: Colors.white, size: 18),
                      ),
                      const Spacer(),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        width: 22,
                        height: 22,
                        decoration: BoxDecoration(
                          color: h.isDoneToday
                              ? Colors.white
                              : Colors.white.withValues(alpha: 0.20),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: h.isDoneToday
                            ? Icon(Icons.check_rounded,
                                color:
                                    (h.gradient as LinearGradient).colors.last,
                                size: 16)
                            : null,
                      ),
                    ],
                  ),
                  const Spacer(),
                  Text(
                    h.name,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    '${h.streak} ${context.tr('home_days')}',
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontWeight: FontWeight.w500,
                      fontSize: 11.5,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _RemindersPreview extends ConsumerWidget {
  const _RemindersPreview({required this.onCreate});
  final VoidCallback onCreate;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<ReminderItem> reminders =
        ref.watch(remindersProvider).take(2).toList();
    if (reminders.isEmpty) {
      return SoftCard(
        padding: const EdgeInsets.all(8),
        child: EmptyState(
          icon: Icons.alarm_rounded,
          title: context.tr('empty_reminders_title'),
          subtitle: context.tr('empty_reminders_sub'),
          ctaLabel: context.tr('empty_reminders_cta'),
          onCta: onCreate,
          gradient: AppColors.indigoGradient,
        ),
      );
    }
    return Column(
      children: reminders.map((ReminderItem r) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: r.category.gradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(r.category.icon,
                      color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        '${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')}',
                        style: Theme.of(context)
                            .textTheme
                            .titleMedium
                            ?.copyWith(
                                fontWeight: FontWeight.w800, fontSize: 17),
                      ),
                      Text(
                        r.label,
                        style: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      if (r.subtitle.isNotEmpty)
                        Text(
                          r.subtitle,
                          style: Theme.of(context).textTheme.bodySmall,
                        ),
                    ],
                  ),
                ),
                Switch(
                  value: r.enabled,
                  onChanged: (_) => ref
                      .read(remindersProvider.notifier)
                      .toggle(r.id),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ShoppingPreview extends ConsumerWidget {
  const _ShoppingPreview();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final List<dynamic> items = ref.watch(shoppingProvider);
    final int total = items.length;
    final int bought =
        items.where((dynamic i) => i.bought as bool).length;

    if (total == 0) {
      return SoftCard(
        padding: const EdgeInsets.all(8),
        onTap: () => context.push('/shopping'),
        child: EmptyState(
          icon: Icons.shopping_basket_rounded,
          title: context.tr('empty_shopping_title'),
          subtitle: context.tr('empty_shopping_sub'),
          gradient: AppColors.emeraldGradient,
        ),
      );
    }

    return SoftCard(
      padding: const EdgeInsets.all(18),
      onTap: () => context.push('/shopping'),
      child: Row(
        children: <Widget>[
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              gradient: AppColors.emeraldGradient,
              borderRadius: BorderRadius.circular(16),
            ),
            child: const Icon(Icons.shopping_basket_rounded,
                color: Colors.white, size: 24),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  context.tr('shopping_title'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 16),
                ),
                const SizedBox(height: 4),
                Text(
                  '$bought / $total ${context.tr('shopping_tab_bought').toLowerCase()}',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const SizedBox(height: 8),
                ClipRRect(
                  borderRadius: BorderRadius.circular(8),
                  child: LinearProgressIndicator(
                    minHeight: 5,
                    value: total == 0 ? 0 : bought / total,
                    backgroundColor: Theme.of(context)
                        .dividerColor
                        .withValues(alpha: 0.5),
                    valueColor: const AlwaysStoppedAnimation<Color>(
                        AppColors.emerald),
                  ),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right_rounded, size: 22),
        ],
      ),
    );
  }
}
