import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/expense_model.dart';
import '../../providers/finance_provider.dart';

class AddExpenseSheet extends ConsumerStatefulWidget {
  const AddExpenseSheet({super.key, this.existing});
  final ExpenseItem? existing;

  @override
  ConsumerState<AddExpenseSheet> createState() => _AddExpenseSheetState();
}

class _AddExpenseSheetState extends ConsumerState<AddExpenseSheet> {
  late final TextEditingController _amount = TextEditingController(
      text: widget.existing == null
          ? ''
          : widget.existing!.amount.toStringAsFixed(
              widget.existing!.amount == widget.existing!.amount.roundToDouble()
                  ? 0
                  : 2));
  late final TextEditingController _note =
      TextEditingController(text: widget.existing?.note ?? '');
  late ExpenseCategory _category =
      widget.existing?.category ?? ExpenseCategory.food;
  late bool _isIncome = widget.existing?.isIncome ?? false;

  bool get _isEdit => widget.existing != null;

  @override
  void dispose() {
    _amount.dispose();
    _note.dispose();
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
                    ? context.tr('edit_expense')
                    : context.tr('finance_add_expense'),
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 16),
              _IncomeExpenseToggle(
                isIncome: _isIncome,
                onChanged: (bool v) => setState(() => _isIncome = v),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: _amount,
                autofocus: true,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.allow(RegExp(r'[0-9.,]')),
                ],
                decoration: InputDecoration(
                  hintText: context.tr('finance_amount'),
                  prefixIcon: const Icon(Icons.payments_rounded, size: 18),
                ),
                style: const TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: _note,
                decoration: InputDecoration(
                  hintText: context.tr('finance_note'),
                ),
              ),
              const SizedBox(height: 16),
              Text(
                context.tr('finance_category'),
                style: const TextStyle(
                    fontWeight: FontWeight.w700, fontSize: 13),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: ExpenseCategory.values.map((ExpenseCategory c) {
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
                        boxShadow: active
                            ? <BoxShadow>[
                                BoxShadow(
                                  color: c.color.withOpacity(0.3),
                                  blurRadius: 10,
                                  offset: const Offset(0, 6),
                                ),
                              ]
                            : null,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: <Widget>[
                          Icon(c.icon,
                              color: active ? Colors.white : c.color,
                              size: 16),
                          const SizedBox(width: 6),
                          Text(
                            context.tr(c.labelKey),
                            style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 12.5,
                              color: active ? Colors.white : null,
                            ),
                          ),
                        ],
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

  void _save() {
    final double? amount =
        double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null || amount <= 0) {
      Navigator.of(context).pop();
      return;
    }
    if (_isEdit) {
      ref.read(financeProvider.notifier).update(
            ExpenseItem(
              id: widget.existing!.id,
              amount: amount,
              category: _category,
              note: _note.text.trim(),
              isIncome: _isIncome,
              date: widget.existing!.date,
            ),
          );
    } else {
      ref.read(financeProvider.notifier).add(
            ExpenseItem(
              id: 'u${DateTime.now().microsecondsSinceEpoch}',
              amount: amount,
              category: _category,
              note: _note.text.trim(),
              isIncome: _isIncome,
            ),
          );
    }
    Navigator.of(context).pop();
  }

  void _delete() {
    if (!_isEdit) return;
    ref.read(financeProvider.notifier).remove(widget.existing!.id);
    Navigator.of(context).pop();
  }
}

class _IncomeExpenseToggle extends StatelessWidget {
  const _IncomeExpenseToggle({
    required this.isIncome,
    required this.onChanged,
  });

  final bool isIncome;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Theme.of(context).dividerColor),
      ),
      child: Row(
        children: <Widget>[
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(false),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: !isIncome ? AppColors.sunsetGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    context.tr('finance_expense'),
                    style: TextStyle(
                      color: !isIncome
                          ? Colors.white
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => onChanged(true),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 220),
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: isIncome ? AppColors.emeraldGradient : null,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Center(
                  child: Text(
                    context.tr('finance_income'),
                    style: TextStyle(
                      color: isIncome
                          ? Colors.white
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
