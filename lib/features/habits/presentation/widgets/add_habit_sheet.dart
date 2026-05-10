import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/habit_model.dart';
import '../../providers/habits_provider.dart';

class AddHabitSheet extends ConsumerStatefulWidget {
  const AddHabitSheet({super.key, this.existing});
  final HabitItem? existing;

  @override
  ConsumerState<AddHabitSheet> createState() => _AddHabitSheetState();
}

class _AddHabitSheetState extends ConsumerState<AddHabitSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing?.name ?? '');
  late HabitStyle _style = widget.existing?.style ?? HabitStyle.workout;
  late int _target = widget.existing?.target ?? 1;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: EdgeInsets.only(
          bottom: MediaQuery.of(context).viewInsets.bottom),
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
                    ? context.tr('edit_habit')
                    : context.tr('habits_new_title'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _name,
                autofocus: true,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  hintText: context.tr('habits_name'),
                  prefixIcon: const Icon(Icons.edit_rounded, size: 18),
                ),
                style: const TextStyle(
                    fontSize: 17, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('habits_pick_icon'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: HabitStyle.values.map((HabitStyle s) {
                  final bool active = s == _style;
                  return GestureDetector(
                    onTap: () => setState(() => _style = s),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 220),
                      width: 56,
                      height: 56,
                      decoration: BoxDecoration(
                        gradient: active ? s.gradient : null,
                        color: active ? null : Theme.of(context).cardColor,
                        border: Border.all(
                          color: active
                              ? Colors.transparent
                              : Theme.of(context).dividerColor,
                        ),
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: active
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: (s.gradient as LinearGradient)
                                      .colors
                                      .last
                                      .withValues(alpha: 0.35),
                                  blurRadius: 12,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Icon(
                        s.icon,
                        size: 22,
                        color: active
                            ? Colors.white
                            : Theme.of(context).textTheme.bodyLarge?.color,
                      ),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 18),
              Text(
                '${context.tr('habits_target')} (${context.tr('habits_per_day')})',
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 8),
              Row(
                children: <Widget>[
                  IconButton(
                    onPressed: _target > 1
                        ? () => setState(() => _target -= 1)
                        : null,
                    icon: const Icon(Icons.remove_circle_outline_rounded),
                  ),
                  Expanded(
                    child: Text(
                      '$_target',
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        fontSize: 26,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                  ),
                  IconButton(
                    onPressed: _target < 12
                        ? () => setState(() => _target += 1)
                        : null,
                    icon: const Icon(Icons.add_circle_outline_rounded),
                  ),
                ],
              ),
              const SizedBox(height: 18),
              Row(
                children: <Widget>[
                  if (_isEdit) ...<Widget>[
                    Expanded(
                      child: GestureDetector(
                        onTap: _delete,
                        child: Container(
                          padding: const EdgeInsets.symmetric(vertical: 16),
                          decoration: BoxDecoration(
                            color: AppColors.rose.withValues(alpha: 0.12),
                            borderRadius: BorderRadius.circular(18),
                            border: Border.all(
                                color: AppColors.rose
                                    .withValues(alpha: 0.35)),
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
                              color: AppColors.primary
                                  .withValues(alpha: 0.4),
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
    ref.read(habitsProvider.notifier).remove(widget.existing!.id);
    Navigator.of(context).pop();
  }

  void _save() {
    if (_name.text.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    if (_isEdit) {
      final HabitItem next = widget.existing!.copyWith(
        name: _name.text.trim(),
        style: _style,
        target: _target,
      );
      ref.read(habitsProvider.notifier).update(next);
    } else {
      ref.read(habitsProvider.notifier).add(
            HabitItem(
              id: 'h${DateTime.now().microsecondsSinceEpoch}',
              name: _name.text.trim(),
              style: _style,
              target: _target,
            ),
          );
    }
    Navigator.of(context).pop();
  }
}
