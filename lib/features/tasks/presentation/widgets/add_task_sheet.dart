import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/task_model.dart';
import '../../providers/tasks_provider.dart';

class AddTaskSheet extends ConsumerStatefulWidget {
  const AddTaskSheet({super.key, this.existing});
  final TaskItem? existing;

  @override
  ConsumerState<AddTaskSheet> createState() => _AddTaskSheetState();
}

class _AddTaskSheetState extends ConsumerState<AddTaskSheet> {
  late final TextEditingController _title =
      TextEditingController(text: widget.existing?.title ?? '');
  late final TextEditingController _notes =
      TextEditingController(text: widget.existing?.notes ?? '');
  late TaskPriority _priority =
      widget.existing?.priority ?? TaskPriority.medium;
  late TimeOfDay _time = widget.existing == null
      ? TimeOfDay.now()
      : TimeOfDay(
          hour: widget.existing!.dueAt.hour,
          minute: widget.existing!.dueAt.minute);
  late DateTime _date = widget.existing?.dueAt ?? DateTime.now();

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _title.dispose();
    _notes.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.bgDark : Colors.white,
          borderRadius:
              const BorderRadius.vertical(top: Radius.circular(28)),
        ),
        padding: const EdgeInsets.fromLTRB(22, 14, 22, 28),
        child: SafeArea(
          top: false,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              Center(
                child: Container(
                  width: 44,
                  height: 5,
                  decoration: BoxDecoration(
                    color: Theme.of(context).dividerColor,
                    borderRadius: BorderRadius.circular(3),
                  ),
                ),
              ),
              const SizedBox(height: 18),
              Text(
                _isEdit
                    ? context.tr('edit_task')
                    : context.tr('tasks_new_task'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 18),
              TextField(
                controller: _title,
                autofocus: true,
                decoration: InputDecoration(
                  hintText: context.tr('tasks_title_field'),
                  prefixIcon: const Icon(Icons.edit_rounded, size: 18),
                ),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _notes,
                maxLines: 2,
                decoration: InputDecoration(
                  hintText: context.tr('tasks_notes_field'),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: _MetaButton(
                      icon: Icons.calendar_today_rounded,
                      label:
                          '${_date.day}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                      onTap: _pickDate,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: _MetaButton(
                      icon: Icons.access_time_rounded,
                      label:
                          '${_time.hour.toString().padLeft(2, '0')}:${_time.minute.toString().padLeft(2, '0')}',
                      onTap: _pickTime,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                children: TaskPriority.values.map((TaskPriority p) {
                  final bool active = p == _priority;
                  return Expanded(
                    child: GestureDetector(
                      onTap: () => setState(() => _priority = p),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        padding: const EdgeInsets.symmetric(vertical: 12),
                        decoration: BoxDecoration(
                          color: active
                              ? p.color.withOpacity(0.12)
                              : Theme.of(context).cardColor,
                          border: Border.all(
                            color: active
                                ? p.color
                                : Theme.of(context).dividerColor,
                            width: 1.4,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Center(
                          child: Text(
                            context.tr(p.labelKey),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              color: active
                                  ? p.color
                                  : Theme.of(context)
                                      .textTheme
                                      .bodySmall
                                      ?.color,
                              fontSize: 12.5,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 22),
              Row(
                children: <Widget>[
                  if (_isEdit) ...<Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: _delete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.rose.withOpacity(0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.rose.withOpacity(0.35)),
                          ),
                          child: Center(
                            child: Text(
                              context.tr('delete'),
                              style: const TextStyle(
                                color: AppColors.rose,
                                fontWeight: FontWeight.w800,
                                fontSize: 15,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 10),
                  ],
                  Expanded(
                    flex: _isEdit ? 2 : 1,
                    child: GestureDetector(
                      onTap: _save,
                      child: Container(
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        decoration: BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          borderRadius: BorderRadius.circular(18),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                              color: AppColors.primary.withOpacity(0.4),
                              blurRadius: 18,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Center(
                          child: Text(
                            context.tr('save'),
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                              letterSpacing: 0.4,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _delete() {
    if (!_isEdit) return;
    ref.read(tasksProvider.notifier).remove(widget.existing!.id);
    Navigator.of(context).pop();
  }

  Future<void> _pickDate() async {
    final DateTime? d = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now().subtract(const Duration(days: 1)),
      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
    );
    if (d != null) setState(() => _date = d);
  }

  Future<void> _pickTime() async {
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) setState(() => _time = t);
  }

  void _save() {
    if (_title.text.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final DateTime due = DateTime(
        _date.year, _date.month, _date.day, _time.hour, _time.minute);
    if (_isEdit) {
      final TaskItem next = widget.existing!.copyWith(
        title: _title.text.trim(),
        notes: _notes.text.trim(),
        priority: _priority,
        dueAt: due,
      );
      ref.read(tasksProvider.notifier).update(next);
    } else {
      ref.read(tasksProvider.notifier).add(
            TaskItem(
              id: 'u${DateTime.now().microsecondsSinceEpoch}',
              title: _title.text.trim(),
              notes: _notes.text.trim(),
              priority: _priority,
              dueAt: due,
            ),
          );
    }
    Navigator.of(context).pop();
  }
}

class _MetaButton extends StatelessWidget {
  const _MetaButton({
    required this.icon,
    required this.label,
    required this.onTap,
  });
  final IconData icon;
  final String label;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          border: Border.all(color: Theme.of(context).dividerColor),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: <Widget>[
            Icon(icon, size: 16, color: AppColors.primary),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
