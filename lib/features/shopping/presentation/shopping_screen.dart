import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../tasks/presentation/widgets/segmented_filter.dart';
import '../data/shopping_model.dart';
import '../providers/shopping_provider.dart';

enum _ShopFilter { all, remaining, bought }

class ShoppingScreen extends ConsumerStatefulWidget {
  const ShoppingScreen({super.key});

  @override
  ConsumerState<ShoppingScreen> createState() => _ShoppingScreenState();
}

class _ShoppingScreenState extends ConsumerState<ShoppingScreen> {
  _ShopFilter _filter = _ShopFilter.all;
  final TextEditingController _quickAdd = TextEditingController();

  @override
  void dispose() {
    _quickAdd.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<ShoppingItem> all = ref.watch(shoppingProvider);
    final List<ShoppingItem> filtered = _apply(all);
    final int total = all.length;
    final int bought = all.where((ShoppingItem i) => i.bought).length;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded),
          onPressed: () => context.pop(),
        ),
        title: Text(context.tr('shopping_title')),
      ),
      body: SafeArea(
        child: Column(
          children: <Widget>[
            Expanded(
              child: ListView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                physics: const BouncingScrollPhysics(),
                children: <Widget>[
                  _Header(total: total, bought: bought),
                  const SizedBox(height: 18),
                  SegmentedFilter<_ShopFilter>(
                    value: _filter,
                    segments: <SegmentedFilterItem<_ShopFilter>>[
                      SegmentedFilterItem<_ShopFilter>(
                          value: _ShopFilter.all,
                          label: context.tr('shopping_tab_all')),
                      SegmentedFilterItem<_ShopFilter>(
                          value: _ShopFilter.remaining,
                          label: context.tr('shopping_tab_remaining')),
                      SegmentedFilterItem<_ShopFilter>(
                          value: _ShopFilter.bought,
                          label: context.tr('shopping_tab_bought')),
                    ],
                    onChanged: (_ShopFilter f) => setState(() => _filter = f),
                  ),
                  const SizedBox(height: 18),
                  if (filtered.isEmpty)
                    EmptyState(
                      icon: Icons.shopping_basket_rounded,
                      title: context.tr('empty_shopping_title'),
                      subtitle: context.tr('empty_shopping_sub'),
                      gradient: AppColors.emeraldGradient,
                    )
                  else
                    ...List<Widget>.generate(filtered.length, (int i) {
                      final ShoppingItem it = filtered[i];
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _ShoppingTile(item: it)
                            .animate(delay: (i * 30).ms)
                            .fadeIn(duration: 240.ms)
                            .slideY(begin: 0.04, curve: Curves.easeOutCubic),
                      );
                    }),
                ],
              ),
            ),
            _QuickAdd(
              controller: _quickAdd,
              onSubmit: _quickAddItem,
            ),
          ],
        ),
      ),
    );
  }

  List<ShoppingItem> _apply(List<ShoppingItem> all) {
    switch (_filter) {
      case _ShopFilter.all:
        return all;
      case _ShopFilter.remaining:
        return all.where((ShoppingItem i) => !i.bought).toList();
      case _ShopFilter.bought:
        return all.where((ShoppingItem i) => i.bought).toList();
    }
  }

  void _quickAddItem() {
    final String name = _quickAdd.text.trim();
    if (name.isEmpty) return;
    ref.read(shoppingProvider.notifier).add(
          ShoppingItem(
            id: 's${DateTime.now().microsecondsSinceEpoch}',
            name: name,
          ),
        );
    _quickAdd.clear();
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.total, required this.bought});
  final int total;
  final int bought;

  @override
  Widget build(BuildContext context) {
    final double ratio = total == 0 ? 0 : bought / total;
    return GradientCard(
      gradient: AppColors.emeraldGradient,
      glowColor: AppColors.emerald,
      padding: const EdgeInsets.all(22),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('shopping_title'),
            style: const TextStyle(
              color: Colors.white,
              fontSize: 26,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.5,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            '$bought / $total ${context.tr('shopping_tab_bought').toLowerCase()}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 14),
          Stack(
            children: <Widget>[
              Container(
                height: 8,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.22),
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              FractionallySizedBox(
                widthFactor: ratio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _ShoppingTile extends ConsumerWidget {
  const _ShoppingTile({required this.item});
  final ShoppingItem item;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Dismissible(
      key: ValueKey<String>(item.id),
      direction: DismissDirection.endToStart,
      onDismissed: (_) =>
          ref.read(shoppingProvider.notifier).remove(item.id),
      background: Container(
        alignment: Alignment.centerRight,
        padding: const EdgeInsets.symmetric(horizontal: 24),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: <Color>[Color(0xFFFCA5A5), Color(0xFFEF4444)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: const Icon(Icons.delete_rounded, color: Colors.white),
      ),
      child: SoftCard(
        padding: const EdgeInsets.all(14),
        onTap: () => ref.read(shoppingProvider.notifier).toggle(item.id),
        child: Row(
          children: <Widget>[
            AnimatedContainer(
              duration: const Duration(milliseconds: 240),
              width: 26,
              height: 26,
              decoration: BoxDecoration(
                gradient: item.bought ? item.category.gradient : null,
                color: item.bought ? null : Colors.transparent,
                border: Border.all(
                  color: item.bought
                      ? Colors.transparent
                      : Theme.of(context).dividerColor,
                  width: 1.6,
                ),
                borderRadius: BorderRadius.circular(8),
              ),
              child: item.bought
                  ? const Icon(Icons.check_rounded,
                      color: Colors.white, size: 16)
                  : null,
            ),
            const SizedBox(width: 14),
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                gradient: item.category.gradient,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(item.category.icon,
                  color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(
                    item.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 15,
                      decoration: item.bought
                          ? TextDecoration.lineThrough
                          : TextDecoration.none,
                      color: item.bought
                          ? Theme.of(context).textTheme.bodySmall?.color
                          : Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    item.qty,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _QuickAdd extends StatelessWidget {
  const _QuickAdd({required this.controller, required this.onSubmit});
  final TextEditingController controller;
  final VoidCallback onSubmit;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.fromLTRB(
        20,
        8,
        20,
        16 + MediaQuery.of(context).viewInsets.bottom * 0.0,
      ),
      child: SoftCard(
        padding: const EdgeInsets.fromLTRB(8, 6, 6, 6),
        child: Row(
          children: <Widget>[
            Expanded(
              child: TextField(
                controller: controller,
                onSubmitted: (_) => onSubmit(),
                decoration: InputDecoration(
                  hintText: context.tr('shopping_add'),
                  border: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  filled: false,
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                ),
              ),
            ),
            GestureDetector(
              onTap: onSubmit,
              child: Container(
                width: 44,
                height: 44,
                decoration: BoxDecoration(
                  gradient: AppColors.primaryGradient,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: <BoxShadow>[
                    BoxShadow(
                      color: AppColors.primary.withOpacity(0.4),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: const Icon(Icons.add_rounded,
                    color: Colors.white, size: 22),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
