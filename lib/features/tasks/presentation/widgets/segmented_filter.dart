import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';

class SegmentedFilterItem<T> {
  const SegmentedFilterItem({required this.value, required this.label});
  final T value;
  final String label;
}

class SegmentedFilter<T> extends StatelessWidget {
  const SegmentedFilter({
    super.key,
    required this.value,
    required this.segments,
    required this.onChanged,
  });

  final T value;
  final List<SegmentedFilterItem<T>> segments;
  final ValueChanged<T> onChanged;

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    return Container(
      padding: const EdgeInsets.all(5),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Theme.of(context).dividerColor.withOpacity(0.6),
        ),
        boxShadow: <BoxShadow>[
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.04),
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: segments.map((SegmentedFilterItem<T> s) {
          final bool active = s.value == value;
          return Expanded(
            child: GestureDetector(
              onTap: () => onChanged(s.value),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 240),
                curve: Curves.easeOutCubic,
                padding: const EdgeInsets.symmetric(vertical: 11),
                decoration: BoxDecoration(
                  gradient: active ? AppColors.primaryGradient : null,
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: active
                      ? <BoxShadow>[
                          BoxShadow(
                            color: AppColors.primary.withOpacity(0.35),
                            blurRadius: 14,
                            offset: const Offset(0, 6),
                          ),
                        ]
                      : null,
                ),
                child: Center(
                  child: AnimatedDefaultTextStyle(
                    duration: const Duration(milliseconds: 220),
                    style: TextStyle(
                      color: active
                          ? Colors.white
                          : Theme.of(context).textTheme.bodySmall?.color,
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      letterSpacing: 0.2,
                    ),
                    child: Text(s.label, maxLines: 1, overflow: TextOverflow.ellipsis),
                  ),
                ),
              ),
            ),
          );
        }).toList(),
      ),
    );
  }
}
