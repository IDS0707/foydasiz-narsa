import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/user_profile.dart';
import '../../providers/user_profile_provider.dart';

class EditBalanceSheet extends ConsumerStatefulWidget {
  const EditBalanceSheet({super.key});

  @override
  ConsumerState<EditBalanceSheet> createState() => _EditBalanceSheetState();
}

enum _Mode { add, subtract, set }

class _EditBalanceSheetState extends ConsumerState<EditBalanceSheet> {
  final TextEditingController _amount = TextEditingController();
  _Mode _mode = _Mode.add;

  @override
  void dispose() {
    _amount.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final UserProfile? profile = ref.watch(userProfileProvider);
    final CurrencyOption currency =
        CurrencyOption.byCode(profile?.currencyCode ?? 'USD');
    final double current = profile?.currentBalance ?? 0;
    final bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Padding(
      padding:
          EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
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
                  context.tr('balance_edit_title'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 14),
                Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                      horizontal: 18, vertical: 18),
                  decoration: BoxDecoration(
                    gradient: AppColors.emeraldGradient,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: AppColors.emerald.withValues(alpha: 0.35),
                        blurRadius: 18,
                        offset: const Offset(0, 10),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.tr('balance_current'),
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.85),
                          fontWeight: FontWeight.w600,
                          fontSize: 12,
                          letterSpacing: 0.5,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${_fmt(current)} ${currency.symbol}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 32,
                          fontWeight: FontWeight.w800,
                          letterSpacing: -0.5,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 18),
                Row(
                  children: <Widget>[
                    Expanded(
                      child: _ModeChip(
                        label: context.tr('balance_add'),
                        icon: Icons.add_rounded,
                        color: AppColors.emerald,
                        active: _mode == _Mode.add,
                        onTap: () => setState(() => _mode = _Mode.add),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(
                        label: context.tr('balance_subtract'),
                        icon: Icons.remove_rounded,
                        color: AppColors.rose,
                        active: _mode == _Mode.subtract,
                        onTap: () => setState(() => _mode = _Mode.subtract),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: _ModeChip(
                        label: context.tr('balance_set'),
                        icon: Icons.edit_rounded,
                        color: AppColors.primary,
                        active: _mode == _Mode.set,
                        onTap: () => setState(() => _mode = _Mode.set),
                      ),
                    ),
                  ],
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
                    hintText: context.tr('balance_amount_hint'),
                    prefixIcon: Icon(
                      _mode == _Mode.add
                          ? Icons.add_circle_rounded
                          : _mode == _Mode.subtract
                              ? Icons.remove_circle_rounded
                              : Icons.payments_rounded,
                      size: 20,
                      color: _modeColor(),
                    ),
                  ),
                  style: const TextStyle(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 20),
                SizedBox(
                  width: double.infinity,
                  child: GestureDetector(
                    onTap: _apply,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      decoration: BoxDecoration(
                        gradient: _modeGradient(),
                        borderRadius: BorderRadius.circular(18),
                        boxShadow: <BoxShadow>[
                          BoxShadow(
                            color: _modeColor().withValues(alpha: 0.4),
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
          ),
        ),
      ),
    );
  }

  Color _modeColor() {
    switch (_mode) {
      case _Mode.add:
        return AppColors.emerald;
      case _Mode.subtract:
        return AppColors.rose;
      case _Mode.set:
        return AppColors.primary;
    }
  }

  Gradient _modeGradient() {
    switch (_mode) {
      case _Mode.add:
        return AppColors.emeraldGradient;
      case _Mode.subtract:
        return const LinearGradient(
          colors: <Color>[Color(0xFFFB7185), AppColors.rose],
        );
      case _Mode.set:
        return AppColors.primaryGradient;
    }
  }

  String _fmt(double v) {
    final bool isWhole = v == v.roundToDouble();
    return isWhole ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
  }

  void _apply() {
    final double? amount =
        double.tryParse(_amount.text.replaceAll(',', '.'));
    if (amount == null) {
      Navigator.of(context).pop();
      return;
    }
    final UserProfile? profile = ref.read(userProfileProvider);
    if (profile == null) {
      Navigator.of(context).pop();
      return;
    }
    final double current = profile.currentBalance;
    final double next;
    switch (_mode) {
      case _Mode.add:
        next = current + amount;
        break;
      case _Mode.subtract:
        next = current - amount;
        break;
      case _Mode.set:
        next = amount;
        break;
    }
    ref.read(userProfileProvider.notifier).updateBalance(next);
    Navigator.of(context).pop();
  }
}

class _ModeChip extends StatelessWidget {
  const _ModeChip({
    required this.label,
    required this.icon,
    required this.color,
    required this.active,
    required this.onTap,
  });

  final String label;
  final IconData icon;
  final Color color;
  final bool active;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 220),
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 8),
        decoration: BoxDecoration(
          color: active
              ? color.withValues(alpha: 0.16)
              : Theme.of(context).cardColor,
          border: Border.all(
            color: active ? color : Theme.of(context).dividerColor,
            width: 1.4,
          ),
          borderRadius: BorderRadius.circular(14),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(icon, color: active ? color : null, size: 18),
            const SizedBox(height: 4),
            Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: active ? color : null,
                fontWeight: FontWeight.w700,
                fontSize: 12,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
