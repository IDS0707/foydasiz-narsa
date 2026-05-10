import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/task_model.dart';
import '../providers/tasks_provider.dart';
import 'widgets/add_task_sheet.dart';
import 'widgets/segmented_filter.dart';
import 'widgets/task_card.dart';

enum TasksFilter { all, today, upcoming, completed }

class TasksScreen extends ConsumerStatefulWidget {
  const TasksScreen({super.key});

  @override
  ConsumerState<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends ConsumerState<TasksScreen> {
  TasksFilter _filter = TasksFilter.all;

  @override
  Widget build(BuildContext context) {
    final List<TaskItem> all = ref.watch(tasksProvider);
    final List<TaskItem> filtered = _apply(all);

    return Scaffold(
      floatingActionButton: _PremiumFab(onTap: _openAddSheet),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _Header(total: all.length, done: all.where((TaskItem t) => t.done).length),
            const SizedBox(height: 18),
            SegmentedFilter<TasksFilter>(
              value: _filter,
              segments: <SegmentedFilterItem<TasksFilter>>[
                SegmentedFilterItem<TasksFilter>(
                    value: TasksFilter.all, label: context.tr('tasks_tab_all')),
                SegmentedFilterItem<TasksFilter>(
                    value: TasksFilter.today,
                    label: context.tr('tasks_tab_today')),
                SegmentedFilterItem<TasksFilter>(
                    value: TasksFilter.upcoming,
                    label: context.tr('tasks_tab_upcoming')),
                SegmentedFilterItem<TasksFilter>(
                    value: TasksFilter.completed,
                    label: context.tr('tasks_tab_completed')),
              ],
              onChanged: (TasksFilter f) => setState(() => _filter = f),
            ),
            const SizedBox(height: 18),
            if (filtered.isEmpty)
              EmptyState(
                icon: Icons.task_alt_rounded,
                title: context.tr('empty_tasks_title'),
                subtitle: context.tr('empty_tasks_sub'),
                ctaLabel: context.tr('empty_tasks_cta'),
                onCta: _openAddSheet,
              )
            else
              ..._buildSections(filtered),
          ],
        ),
      ),
    );
  }

  List<Widget> _buildSections(List<TaskItem> items) {
    final List<TaskItem> today =
        items.where((TaskItem t) => t.isToday && !t.done).toList();
    final List<TaskItem> upcoming =
        items.where((TaskItem t) => t.isUpcoming && !t.done).toList();
    final List<TaskItem> completed =
        items.where((TaskItem t) => t.done).toList();

    final List<Widget> widgets = <Widget>[];

    void addSection(String key, List<TaskItem> list) {
      if (list.isEmpty) return;
      widgets.add(SectionHeader(title: context.tr(key)));
      for (int i = 0; i < list.length; i++) {
        widgets.add(
          TaskCard(task: list[i])
              .animate(delay: (i * 35).ms)
              .fadeIn(duration: 280.ms)
              .slideY(begin: 0.06, curve: Curves.easeOutCubic),
        );
        widgets.add(const SizedBox(height: 10));
      }
      widgets.add(const SizedBox(height: 10));
    }

    addSection('tasks_today_section', today);
    addSection('tasks_upcoming_section', upcoming);
    addSection('tasks_completed_section', completed);
    return widgets;
  }

  List<TaskItem> _apply(List<TaskItem> items) {
    switch (_filter) {
      case TasksFilter.all:
        return items;
      case TasksFilter.today:
        return items.where((TaskItem t) => t.isToday).toList();
      case TasksFilter.upcoming:
        return items.where((TaskItem t) => t.isUpcoming).toList();
      case TasksFilter.completed:
        return items.where((TaskItem t) => t.done).toList();
    }
  }

  void _openAddSheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const AddTaskSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total, required this.done});
  final int total;
  final int done;

  @override
  Widget build(BuildContext context) {
    final String date =
        DateFormat.yMMMMEEEEd(Localizations.localeOf(context).languageCode)
            .format(DateTime.now());
    return GradientCard(
      gradient: AppColors.primaryGradient,
      glowColor: AppColors.primary,
      child: Row(
        children: <Widget>[
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  date,
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontWeight: FontWeight.w600,
                    fontSize: 12.5,
                    letterSpacing: 0.2,
                  ),
                ),
                const SizedBox(height: 6),
                Text(
                  context.tr('tasks_title'),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '$done / $total ${context.tr('done').toLowerCase()}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.92),
                    fontSize: 13.5,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          Container(
            width: 60,
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.18),
              borderRadius: BorderRadius.circular(18),
            ),
            child:
                const Icon(Icons.task_alt_rounded, color: Colors.white, size: 28),
          ),
        ],
      ),
    );
  }
}

class _PremiumFab extends StatelessWidget {
  const _PremiumFab({required this.onTap});
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
                color: AppColors.primary.withOpacity(0.5),
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
                context.tr('tasks_add'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
