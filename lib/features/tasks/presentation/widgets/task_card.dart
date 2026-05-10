import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/glass_card.dart';
import '../../data/task_model.dart';
import '../../providers/tasks_provider.dart';
import 'add_task_sheet.dart';

class TaskCard extends ConsumerWidget {
  const TaskCard({super.key, required this.task});
  final TaskItem task;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey<String>(task.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) => ref.read(tasksProvider.notifier).remove(task.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        margin: const EdgeInsets.symmetric(vertical: 4),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFCA5A5), Color(0xFFEF4444)],
            begin: Alignment.centerLeft,
            end: Alignment.centerRight,
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: GestureDetector(
        onLongPress: () => _openEdit(context),
        child: SoftCard(
          padding: const EdgeInsets.all(14),
          onTap: () => ref.read(tasksProvider.notifier).toggle(task.id),
          child: Row(
          children: <Widget>[
            _PriorityCheckbox(
              done: task.done,
              color: task.priority.color,
              onTap: () => ref.read(tasksProvider.notifier).toggle(task.id),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 240),
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decoration: task.done
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: task.done
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    child: Text(
                      task.title,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  if (task.notes.isNotEmpty) ...<Widget>[
                    const SizedBox(height: 2),
                    Text(
                      task.notes,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: Theme.of(context).textTheme.bodySmall,
                    ),
                  ],
                  const SizedBox(height: 8),
                  Row(
                    children: <Widget>[
                      _Chip(
                        icon: Icons.access_time_rounded,
                        label: DateFormat('HH:mm').format(task.dueAt),
                      ),
                      const SizedBox(width: 8),
                      _Chip(
                        icon: Icons.flag_rounded,
                        label: context.tr(task.priority.labelKey),
                        color: task.priority.color,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              color: Theme.of(context).textTheme.bodySmall?.color,
            ),
          ],
        ),
        ),
      ),
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => AddTaskSheet(existing: task),
    );
  }
}

class _PriorityCheckbox extends StatelessWidget {
  const _PriorityCheckbox({
    required this.done,
    required this.color,
    required this.onTap,
  });

  final bool done;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 240),
        curve: Curves.easeOutCubic,
        width: 26,
        height: 26,
        decoration: BoxDecoration(
          color: done ? color : Colors.transparent,
          border: Border.all(
            color: done ? color : color.withOpacity(0.55),
            width: 1.8,
          ),
          borderRadius: BorderRadius.circular(9),
          boxShadow: done
              ? <BoxShadow>[
                  BoxShadow(
                    color: color.withOpacity(0.35),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ]
              : null,
        ),
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 220),
          child: done
              ? const Icon(Icons.check_rounded,
                  color: Colors.white, size: 18, key: ValueKey<bool>(true))
              : const SizedBox.shrink(key: ValueKey<bool>(false)),
        ),
      ),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({
    required this.icon,
    required this.label,
    this.color,
  });

  final IconData icon;
  final String label;
  final Color? color;

  @override
  Widget build(BuildContext context) {
    final Color c = color ?? AppColors.primary;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 5),
      decoration: BoxDecoration(
        color: c.withOpacity(0.10),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Icon(icon, color: c, size: 12),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontSize: 11.5,
              color: c,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
