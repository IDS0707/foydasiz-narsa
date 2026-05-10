import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/localization/app_localizations.dart';
import '../../../core/theme/app_colors.dart';
import '../../../shared/widgets/empty_state.dart';
import '../../../shared/widgets/glass_card.dart';
import '../../../shared/widgets/section_header.dart';
import '../data/expense_model.dart';
import '../providers/finance_provider.dart';
import 'widgets/add_expense_sheet.dart';

class FinanceScreen extends ConsumerWidget {
  const FinanceScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final FinanceStats stats = ref.watch(financeStatsProvider);
    final List<ExpenseItem> all = ref.watch(financeProvider);

    return Scaffold(
      floatingActionButton: _AddExpenseFab(onTap: () => _openAdd(context)),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 140),
          physics: const BouncingScrollPhysics(),
          children: <Widget>[
            _Header(stats: stats),
            const SizedBox(height: 22),
            if (all.isEmpty)
              EmptyState(
                icon: Icons.account_balance_wallet_rounded,
                title: context.tr('empty_finance_title'),
                subtitle: context.tr('empty_finance_sub'),
                ctaLabel: context.tr('empty_finance_cta'),
                onCta: () => _openAdd(context),
                gradient: AppColors.indigoGradient,
              )
            else ...<Widget>[
              _WeeklyChartCard(weekly: stats.weekly)
                  .animate()
                  .fadeIn(duration: 320.ms)
                  .slideY(begin: 0.06, curve: Curves.easeOutCubic),
              const SizedBox(height: 22),
              if (stats.byCategory.isNotEmpty) ...<Widget>[
                SectionHeader(title: context.tr('finance_donut_title')),
                _CategoryDonutCard(stats: stats),
                const SizedBox(height: 22),
                SectionHeader(title: context.tr('finance_categories')),
                _CategoryList(stats: stats),
                const SizedBox(height: 22),
              ],
              SectionHeader(title: context.tr('finance_recent')),
              ...all.take(8).map((ExpenseItem e) => Padding(
                    padding: const EdgeInsets.only(bottom: 10),
                    child: _ExpenseTile(item: e, currency: stats.currencySymbol),
                  )),
            ],
          ],
        ),
      ),
    );
  }

  void _openAdd(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => const AddExpenseSheet(),
    );
  }
}

class _Header extends StatelessWidget {
  const _Header({required this.stats});
  final FinanceStats stats;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt =
        NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode);
    return GradientCard(
      gradient: AppColors.primaryGradient,
      glowColor: AppColors.primary,
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Row(
            children: <Widget>[
              Text(
                context.tr('finance_total_spent'),
                style: TextStyle(
                  color: Colors.white.withOpacity(0.85),
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                  letterSpacing: 0.2,
                ),
              ),
              const Spacer(),
              Container(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.18),
                  borderRadius: BorderRadius.circular(30),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: <Widget>[
                    Text(
                      DateFormat.MMMM(Localizations.localeOf(context)
                              .languageCode)
                          .format(DateTime.now()),
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 12,
                      ),
                    ),
                    const SizedBox(width: 4),
                    const Icon(Icons.keyboard_arrow_down_rounded,
                        color: Colors.white, size: 16),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          RichText(
            text: TextSpan(
              children: <TextSpan>[
                TextSpan(
                  text: fmt.format(stats.monthTotal.round()),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 34,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -1,
                  ),
                ),
                TextSpan(
                  text: ' ${stats.currencySymbol}',
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.85),
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          Text(
            '${context.tr('home_balance')}: ${fmt.format(stats.currentBalance.round())} ${stats.currencySymbol}',
            style: TextStyle(
              color: Colors.white.withOpacity(0.85),
              fontWeight: FontWeight.w600,
              fontSize: 12.5,
            ),
          ),
          const SizedBox(height: 10),
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
                widthFactor: stats.balanceUsedRatio,
                child: Container(
                  height: 8,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: <Color>[Colors.white, Color(0xFFE9D5FF)],
                    ),
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: <BoxShadow>[
                      BoxShadow(
                        color: Colors.white.withOpacity(0.4),
                        blurRadius: 8,
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Align(
            alignment: Alignment.centerRight,
            child: Text(
              '${(stats.balanceUsedRatio * 100).round()}%',
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w800,
                fontSize: 13,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _WeeklyChartCard extends StatelessWidget {
  const _WeeklyChartCard({required this.weekly});
  final List<double> weekly;

  @override
  Widget build(BuildContext context) {
    final double maxY =
        (weekly.reduce((double a, double b) => a > b ? a : b)).clamp(1, 1e9);
    final List<String> labels = const <String>[
      'Mon',
      'Tue',
      'Wed',
      'Thu',
      'Fri',
      'Sat',
      'Sun'
    ];

    return SoftCard(
      padding: const EdgeInsets.fromLTRB(18, 18, 18, 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            context.tr('finance_chart_title'),
            style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 15),
          ),
          const SizedBox(height: 16),
          SizedBox(
            height: 170,
            child: BarChart(
              BarChartData(
                alignment: BarChartAlignment.spaceAround,
                maxY: maxY * 1.25,
                gridData: const FlGridData(show: false),
                borderData: FlBorderData(show: false),
                titlesData: FlTitlesData(
                  leftTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  topTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  rightTitles: const AxisTitles(
                      sideTitles: SideTitles(showTitles: false)),
                  bottomTitles: AxisTitles(
                    sideTitles: SideTitles(
                      showTitles: true,
                      reservedSize: 26,
                      getTitlesWidget: (double v, TitleMeta meta) {
                        final int idx = v.toInt();
                        if (idx < 0 || idx >= labels.length) {
                          return const SizedBox.shrink();
                        }
                        return Padding(
                          padding: const EdgeInsets.only(top: 8),
                          child: Text(
                            labels[idx],
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Theme.of(context)
                                  .textTheme
                                  .bodySmall
                                  ?.color,
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ),
                barGroups: List<BarChartGroupData>.generate(weekly.length,
                    (int i) {
                  return BarChartGroupData(
                    x: i,
                    barRods: <BarChartRodData>[
                      BarChartRodData(
                        toY: weekly[i],
                        width: 18,
                        borderRadius: BorderRadius.circular(8),
                        gradient: AppColors.primaryGradient,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryDonutCard extends StatelessWidget {
  const _CategoryDonutCard({required this.stats});
  final FinanceStats stats;

  @override
  Widget build(BuildContext context) {
    final List<MapEntry<ExpenseCategory, double>> items =
        stats.byCategory.entries.toList()
          ..sort((MapEntry<ExpenseCategory, double> a,
                  MapEntry<ExpenseCategory, double> b) =>
              b.value.compareTo(a.value));
    if (items.isEmpty) return const SizedBox.shrink();

    return SoftCard(
      child: Row(
        children: <Widget>[
          SizedBox(
            width: 130,
            height: 130,
            child: PieChart(
              PieChartData(
                sectionsSpace: 4,
                centerSpaceRadius: 38,
                sections: items.map((MapEntry<ExpenseCategory, double> e) {
                  return PieChartSectionData(
                    value: e.value,
                    color: e.key.color,
                    radius: 22,
                    showTitle: false,
                  );
                }).toList(),
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: items.take(4).map((MapEntry<ExpenseCategory, double> e) {
                final double pct =
                    stats.monthTotal == 0 ? 0 : (e.value / stats.monthTotal);
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  child: Row(
                    children: <Widget>[
                      Container(
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(
                          color: e.key.color,
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          context.tr(e.key.labelKey),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(
                            fontWeight: FontWeight.w600,
                            fontSize: 13,
                          ),
                        ),
                      ),
                      Text(
                        '${(pct * 100).round()}%',
                        style: TextStyle(
                          fontWeight: FontWeight.w700,
                          color: Theme.of(context).textTheme.bodySmall?.color,
                          fontSize: 12.5,
                        ),
                      ),
                    ],
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}

class _CategoryList extends StatelessWidget {
  const _CategoryList({required this.stats});
  final FinanceStats stats;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt =
        NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode);
    final List<MapEntry<ExpenseCategory, double>> items =
        stats.byCategory.entries.toList()
          ..sort((MapEntry<ExpenseCategory, double> a,
                  MapEntry<ExpenseCategory, double> b) =>
              b.value.compareTo(a.value));

    return Column(
      children: items.map((MapEntry<ExpenseCategory, double> e) {
        final double pct =
            stats.monthTotal == 0 ? 0 : (e.value / stats.monthTotal);
        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: SoftCard(
            padding: const EdgeInsets.all(14),
            child: Row(
              children: <Widget>[
                Container(
                  width: 44,
                  height: 44,
                  decoration: BoxDecoration(
                    gradient: e.key.gradient,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Icon(e.key.icon, color: Colors.white, size: 20),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        context.tr(e.key.labelKey),
                        style: const TextStyle(
                            fontWeight: FontWeight.w700, fontSize: 14.5),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: LinearProgressIndicator(
                          minHeight: 5,
                          value: pct,
                          backgroundColor: Theme.of(context)
                              .dividerColor
                              .withOpacity(0.5),
                          valueColor: AlwaysStoppedAnimation<Color>(e.key.color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: <Widget>[
                    Text(
                      fmt.format(e.value.round()),
                      style: const TextStyle(
                          fontWeight: FontWeight.w800, fontSize: 14.5),
                    ),
                    Text(
                      '${(pct * 100).round()}%',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                        color: Theme.of(context).textTheme.bodySmall?.color,
                        fontSize: 11.5,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}

class _ExpenseTile extends StatelessWidget {
  const _ExpenseTile({required this.item, required this.currency});
  final ExpenseItem item;
  final String currency;

  @override
  Widget build(BuildContext context) {
    final NumberFormat fmt =
        NumberFormat.decimalPattern(Localizations.localeOf(context).languageCode);
    return SoftCard(
      padding: const EdgeInsets.all(14),
      onTap: () => _openEdit(context),
      onLongPress: () => _openEdit(context),
      child: Row(
        children: <Widget>[
          Container(
            width: 42,
            height: 42,
            decoration: BoxDecoration(
              gradient: item.category.gradient,
              borderRadius: BorderRadius.circular(13),
            ),
            child: Icon(item.category.icon, color: Colors.white, size: 18),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: <Widget>[
                Text(
                  item.note.isEmpty
                      ? context.tr(item.category.labelKey)
                      : item.note,
                  style: const TextStyle(
                      fontWeight: FontWeight.w700, fontSize: 14),
                ),
                const SizedBox(height: 2),
                Text(
                  context.tr(item.category.labelKey),
                  style: Theme.of(context).textTheme.bodySmall,
                ),
              ],
            ),
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: <Widget>[
              Text(
                '-${fmt.format(item.amount.round())} $currency',
                style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 14,
                    color: AppColors.rose),
              ),
              Text(
                DateFormat('d MMM').format(item.date),
                style: Theme.of(context).textTheme.bodySmall,
              ),
            ],
          ),
        ],
      ),
    );
  }

  void _openEdit(BuildContext context) {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (BuildContext _) => AddExpenseSheet(existing: item),
    );
  }
}

class _AddExpenseFab extends StatelessWidget {
  const _AddExpenseFab({required this.onTap});
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 70, right: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
          decoration: BoxDecoration(
            gradient: AppColors.primaryGradient,
            borderRadius: BorderRadius.circular(22),
            boxShadow: <BoxShadow>[
              BoxShadow(
                color: AppColors.primary.withOpacity(0.5),
                blurRadius: 20,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              const Icon(Icons.add_rounded, color: Colors.white, size: 22),
              const SizedBox(width: 8),
              Text(
                context.tr('finance_add_expense'),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
