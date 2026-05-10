import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/reminder_model.dart';
import '../../providers/reminders_provider.dart';

class AddReminderSheet extends ConsumerStatefulWidget {
  const AddReminderSheet({super.key, this.existing});
  final ReminderItem? existing;

  @override
  ConsumerState<AddReminderSheet> createState() => _AddReminderSheetState();
}

class _AddReminderSheetState extends ConsumerState<AddReminderSheet> {
  late final TextEditingController _label =
      TextEditingController(text: widget.existing?.label ?? '');
  late TimeOfDay _time = widget.existing?.time ?? TimeOfDay.now();
  late DateTime _date = widget.existing?.date ?? DateTime.now();
  late ReminderRepeat _repeat =
      widget.existing?.repeat ?? ReminderRepeat.daily;
  late ReminderCategory _category =
      widget.existing?.category ?? ReminderCategory.general;
  bool _saving = false;
  String? _error;

  bool get _isEdit => widget.existing != null;

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
                  _isEdit
                      ? context.tr('edit_reminder')
                      : context.tr('reminders_add'),
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
                if (_error != null) ...<Widget>[
                  const SizedBox(height: 14),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                        horizontal: 14, vertical: 12),
                    decoration: BoxDecoration(
                      color: AppColors.rose.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(14),
                      border: Border.all(
                          color: AppColors.rose.withValues(alpha: 0.3)),
                    ),
                    child: Row(
                      children: <Widget>[
                        const Icon(Icons.error_outline_rounded,
                            color: AppColors.rose, size: 18),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            _error!,
                            style: const TextStyle(
                              color: AppColors.rose,
                              fontWeight: FontWeight.w600,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
                const SizedBox(height: 22),
                Row(
                  children: <Widget>[
                    if (_isEdit) ...<Widget>[
                      Expanded(
                        child: GestureDetector(
                          onTap: _saving ? null : _delete,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
                            decoration: BoxDecoration(
                              color:
                                  AppColors.rose.withValues(alpha: 0.12),
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
                        onTap: _saving ? null : _save,
                        child: AnimatedOpacity(
                          duration: const Duration(milliseconds: 180),
                          opacity: _saving ? 0.6 : 1,
                          child: Container(
                            padding:
                                const EdgeInsets.symmetric(vertical: 16),
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
                              child: _saving
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2.4,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                                Colors.white),
                                      ),
                                    )
                                  : Text(
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
                    ),
                  ],
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

  Future<void> _save() async {
    if (_saving) return;

    final String label = _label.text.trim();
    if (label.isEmpty) {
      setState(() => _error = context.tr('reminders_label_hint'));
      return;
    }

    setState(() {
      _error = null;
      _saving = true;
    });

    final ReminderItem r = _isEdit
        ? widget.existing!.copyWith(
            label: label,
            time: _time,
            repeat: _repeat,
            category: _category,
            date: _date,
            subtitle: _subtitleFor(),
          )
        : ReminderItem(
            id: 'r${DateTime.now().microsecondsSinceEpoch}',
            label: label,
            time: _time,
            repeat: _repeat,
            category: _category,
            date: _date,
            subtitle: _subtitleFor(),
          );

    try {
      if (_isEdit) {
        await ref.read(remindersProvider.notifier).update(r);
      } else {
        await ref.read(remindersProvider.notifier).add(r);
      }
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _saving = false;
        _error = e.toString();
      });
      return;
    }

    if (!mounted) return;
    Navigator.of(context).pop();
    final ScaffoldMessengerState messenger = ScaffoldMessenger.of(context);
    messenger.hideCurrentSnackBar();
    messenger.showSnackBar(
      SnackBar(
        behavior: SnackBarBehavior.floating,
        backgroundColor: AppColors.emerald,
        content: Row(
          children: <Widget>[
            const Icon(Icons.check_circle_rounded,
                color: Colors.white, size: 20),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                '${r.label} · ${r.time.hour.toString().padLeft(2, '0')}:${r.time.minute.toString().padLeft(2, '0')}',
                style: const TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  Future<void> _delete() async {
    if (!_isEdit) return;
    await ref
        .read(remindersProvider.notifier)
        .remove(widget.existing!.id);
    if (!mounted) return;
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
