import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/user_profile.dart';
import '../../providers/user_profile_provider.dart';

class EditProfileSheet extends ConsumerStatefulWidget {
  const EditProfileSheet({super.key});

  @override
  ConsumerState<EditProfileSheet> createState() => _EditProfileSheetState();
}

class _EditProfileSheetState extends ConsumerState<EditProfileSheet> {
  late final TextEditingController _name;
  late final TextEditingController _age;
  late String _currencyCode;

  @override
  void initState() {
    super.initState();
    final UserProfile? p = ref.read(userProfileProvider);
    _name = TextEditingController(text: p?.name ?? '');
    _age = TextEditingController(
        text: (p?.age ?? 0) > 0 ? p!.age.toString() : '');
    _currencyCode = p?.currencyCode ?? 'USD';
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
                  context.tr('edit_profile'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 18),
                TextField(
                  controller: _name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    hintText: context.tr('profile_name_hint'),
                    prefixIcon: const Icon(Icons.person_rounded, size: 18),
                  ),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  inputFormatters: <TextInputFormatter>[
                    FilteringTextInputFormatter.digitsOnly,
                    LengthLimitingTextInputFormatter(3),
                  ],
                  decoration: InputDecoration(
                    hintText: context.tr('profile_age_hint'),
                    prefixIcon: const Icon(Icons.cake_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 16),
                Text(
                  context.tr('profile_currency'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: CurrencyOption.all.map((CurrencyOption c) {
                    final bool active = c.code == _currencyCode;
                    return GestureDetector(
                      onTap: () => setState(() => _currencyCode = c.code),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 10),
                        decoration: BoxDecoration(
                          gradient:
                              active ? AppColors.primaryGradient : null,
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
                            Text(c.flag,
                                style: const TextStyle(fontSize: 16)),
                            const SizedBox(width: 6),
                            Text(
                              '${c.code} ${c.symbol}',
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
                            color: AppColors.primary.withValues(alpha: 0.4),
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

  void _save() {
    final UserProfile? cur = ref.read(userProfileProvider);
    if (cur == null) {
      Navigator.of(context).pop();
      return;
    }
    final UserProfile next = cur.copyWith(
      name: _name.text.trim().isEmpty ? cur.name : _name.text.trim(),
      age: int.tryParse(_age.text.trim()) ?? cur.age,
      currencyCode: _currencyCode,
    );
    ref.read(userProfileProvider.notifier).update(next);
    Navigator.of(context).pop();
  }
}
