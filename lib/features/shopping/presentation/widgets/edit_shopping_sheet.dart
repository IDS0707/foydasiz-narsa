import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/localization/app_localizations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../data/shopping_model.dart';
import '../../providers/shopping_provider.dart';

class EditShoppingSheet extends ConsumerStatefulWidget {
  const EditShoppingSheet({super.key, required this.existing});
  final ShoppingItem existing;

  @override
  ConsumerState<EditShoppingSheet> createState() =>
      _EditShoppingSheetState();
}

class _EditShoppingSheetState extends ConsumerState<EditShoppingSheet> {
  late final TextEditingController _name =
      TextEditingController(text: widget.existing.name);
  late final TextEditingController _qty =
      TextEditingController(text: widget.existing.qty);
  late ShoppingCategory _category = widget.existing.category;

  @override
  void dispose() {
    _name.dispose();
    _qty.dispose();
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
                  context.tr('shopping_edit'),
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                      fontSize: 22, fontWeight: FontWeight.w800),
                ),
                const SizedBox(height: 16),
                TextField(
                  controller: _name,
                  autofocus: true,
                  textCapitalization: TextCapitalization.sentences,
                  decoration: InputDecoration(
                    hintText: context.tr('shopping_name'),
                    prefixIcon: const Icon(Icons.edit_rounded, size: 18),
                  ),
                  style: const TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: _qty,
                  decoration: InputDecoration(
                    hintText: context.tr('shopping_qty'),
                    prefixIcon: const Icon(Icons.scale_rounded, size: 18),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.tr('finance_category'),
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 13),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children:
                      ShoppingCategory.values.map((ShoppingCategory c) {
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
                                  : Theme.of(context)
                                      .textTheme
                                      .bodyLarge
                                      ?.color,
                            ),
                            const SizedBox(width: 6),
                            Text(
                              c.name,
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
                Row(
                  children: <Widget>[
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
                    Expanded(
                      flex: 2,
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
      ),
    );
  }

  void _save() {
    final String name = _name.text.trim();
    if (name.isEmpty) {
      Navigator.of(context).pop();
      return;
    }
    final String qty = _qty.text.trim();
    ref.read(shoppingProvider.notifier).update(
          widget.existing.copyWith(
            name: name,
            qty: qty.isEmpty ? '1' : qty,
            category: _category,
          ),
        );
    Navigator.of(context).pop();
  }

  void _delete() {
    ref.read(shoppingProvider.notifier).remove(widget.existing.id);
    Navigator.of(context).pop();
  }
}
