import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/reminder_model.dart';
import '../../providers/reminders_provider.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  const AddReminderSheet({super.key});

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  final TextEditingController _label = TextEditingController();
  TimeOfDay _time = TimeOfDay.now();
  DateTime _date = DateTime.now();
  ReminderRepeat _repeat = ReminderRepeat.daily;
  ReminderCategory _category = ReminderCategory.general;

  @override
  void dispose() {
    _label.dispose();
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
          child: SingleChildScrollView(
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
                  context.tr('reminders_add'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                _BigTime(
                  time: _time,
                  onTap: _pickTime,
                ),
                const SizedBox(height: 14),
                TextField(
                  controller: _label,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.tr('reminders_label_hint'),
                    prefixIcon: const Icon(Icons.edit_rounded, size: 18),
                  ),
                  style: const TextStyle(
                      fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 18),
                _SectionLabel(text: context.tr('reminders_repeats')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: ReminderRepeat.values.map((ReminderRepeat r) {
                    final bool active = r == _repeat;
                    return _ChoiceChip(
                      label: context.tr(r.labelKey),
                      active: active,
                      onTap: () => setState(() => _repeat = r),
                    );
                  }).toList(),
                ),
                if (_repeat == ReminderRepeat.once) ...<Widget>[
                  const SizedBox(height: 14),
                  _SectionLabel(text: context.tr('reminders_when')),
                  const SizedBox(height: 8),
                  GestureDetector(
                    onTap: _pickDate,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context).cardColor,
                        border:
                            Border.all(color: Theme.of(context).dividerColor),
                        borderRadius: BorderRadius.circular(14),
                      ),
                      child: Row(
                        children: <Widget>[
                          const Icon(Icons.calendar_today_rounded,
                              size: 16, color: AppColors.primary),
                          const SizedBox(width: 10),
                          Text(
                            '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}',
                            style: const TextStyle(
                                fontWeight: FontWeight.w700, fontSize: 14),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
                const SizedBox(height: 18),
                _SectionLabel(text: context.tr('reminders_categories')),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ReminderCategory.values.map((ReminderCategory c) {
                    final bool active = c == _category;
                    return GestureDetector(
                      onTap: () => setState(() => _category = c),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 220),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          gradient: active ? c.gradient : null,
                          color: active ? null : Theme.of(context).cardColor,
                          border: Border.all(
                            color: active
                                ? Colors.transparent
                                : Theme.of(context).dividerColor,
                          ),
                          borderRadius: BorderRadius.circular(14),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(
                              c.icon,
                              size: 16,
                              color: active
                                  ? Colors.white
                                  : Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              context.tr(c.labelKey),
                              style: TextStyle(
                                color: active ? Colors.white : null,
                                fontWeight: FontWeight.w700,
                                fontSize: 12.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }).toList(),
                ),
                const SizedBox(height: 22),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _save,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: AppColors.primaryGradient,
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color:
                                AppColors.primary.withValues(alpha: 0.4),
                            blurRadius: 18,
                            offset: const Offset(0, 10),
                          ),
                        ],
                      ),
                      child: Center(
                        child: Text(
                          context.tr('reminders_save'),
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
          ),
        ),
      ),
    );
  }

  Future<void> _pickTime() async {
    final TimeOfDay? t = await showTimePicker(
      context: context,
      initialTime: _time,
    );
    if (t != null) setState(() => _time = t);
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

  void _save() {
    if (_label.text.trim().isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final ReminderItem r = ReminderItem(
      id: 'r${DateTime.now().microsecondsSinceEpoch}',
      label: _label.text.trim(),
      time: _time,
      repeat: _repeat,
      category: _category,
      date: _date,
      subtitle: _subtitleFor(),
    );
    ref.read(remindersProvider.notifier).add(r);
    Navigator.of(context).pop();
  }

  String _subtitleFor() {
    switch (_repeat) {
      case ReminderRepeat.once:
        return '${_date.day.toString().padLeft(2, '0')}.${_date.month.toString().padLeft(2, '0')}.${_date.year}';
      case ReminderRepeat.daily:
        return context.tr('reminders_daily');
      case ReminderRepeat.weekly:
        return context.tr('reminders_weekly');
    }
  }
}

class _BigTime extends StatelessWidget {
  const _BigTime({required this.time, required this.onTap});
  final TimeOfDay time;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 18),
        decoration: BoxDecoration(
          gradient: AppColors.indigoGradient,
          borderRadius: BorderRadius.circular(22),
          boxShadow: <BoxShadow>[
            BoxShadow(
              color: AppColors.indigo.withValues(alpha: 0.4),
              blurRadius: 20,
              offset: const Offset(0, 12),
            ),
          ],
        ),
        child: Row(
          children: <Widget>[
            const Icon(Icons.alarm_rounded,
                color: Colors.white, size: 28),
            const SizedBox(width: 14),
            Text(
              '${time.hour.toString().padLeft(2, '0')}:${time.minute.toString().padLeft(2, '0')}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 40,
                fontWeight: FontWeight.w800,
                letterSpacing: -1.5,
              ),
            ),
            const Spacer(),
            const Icon(Icons.keyboard_arrow_right_rounded,
                color: Colors.white, size: 26),
          ],
        ),
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  const _SectionLabel({required this.text});
  final String text;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13,
        letterSpacing: 0.3,
      ),
    );
  }
}

class _ChoiceChip extends StatelessWidget {
  const _ChoiceChip({
    required this.label,
    required this.active,
    required this.onTap,
  });
  final String label;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          gradient: active ? AppColors.primaryGradient : null,
          color: active ? null : Theme.of(context).cardColor,
          border: Border.all(
            color: active ? Colors.transparent : Theme.of(context).dividerColor,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: active ? Colors.white : null,
            fontWeight: FontWeight.w700,
            fontSize: 13,
          ),
        ),
      ),
    );
  }
}
