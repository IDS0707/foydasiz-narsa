import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/preferences_provider.dart';
import '../../user/data/user_profile.dart';
import '../../user/providers/user_profile_provider.dart';
import '../data/expense_model.dart';

class FinanceNotifier extends StateNotifier<List<ExpenseItem>> {
  FinanceNotifier(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.expenses';
  final SharedPreferences _prefs;

  static List<ExpenseItem> _load(SharedPreferences prefs) {
    final List<String>? raw = prefs.getStringList(_key);
    if (raw == null) return <ExpenseItem>[];
    return raw.map(ExpenseItem.decode).toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
        _key, state.map((ExpenseItem e) => e.encode()).toList());
  }

  Future<void> add(ExpenseItem item) async {
    state = <ExpenseItem>[item, ...state];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((ExpenseItem e) => e.id != id).toList();
    await _persist();
  }
}

final StateNotifierProvider<FinanceNotifier, List<ExpenseItem>>
    financeProvider =
    StateNotifierProvider<FinanceNotifier, List<ExpenseItem>>((Ref ref) {
  return FinanceNotifier(ref.watch(sharedPreferencesProvider));
});

final Provider<FinanceStats> financeStatsProvider =
    Provider<FinanceStats>((Ref ref) {
  final List<ExpenseItem> all = ref.watch(financeProvider);
  final UserProfile? profile = ref.watch(userProfileProvider);

  final DateTime now = DateTime.now();
  final DateTime startOfMonth = DateTime(now.year, now.month);
  final DateTime today = DateTime(now.year, now.month, now.day);

  final List<ExpenseItem> month = all
      .where((ExpenseItem e) => !e.isIncome && e.date.isAfter(startOfMonth))
      .toList();

  final double monthTotal =
      month.fold<double>(0, (double sum, ExpenseItem e) => sum + e.amount);

  final double todayTotal = all
      .where((ExpenseItem e) =>
          !e.isIncome &&
          e.date.year == today.year &&
          e.date.month == today.month &&
          e.date.day == today.day)
      .fold<double>(0, (double sum, ExpenseItem e) => sum + e.amount);

  final Map<ExpenseCategory, double> byCategory =
      <ExpenseCategory, double>{};
  for (final ExpenseItem e in month) {
    byCategory[e.category] = (byCategory[e.category] ?? 0) + e.amount;
  }

  final List<double> weekly = List<double>.generate(7, (int i) {
    final DateTime day = today.subtract(Duration(days: 6 - i));
    return all
        .where((ExpenseItem e) =>
            !e.isIncome &&
            e.date.year == day.year &&
            e.date.month == day.month &&
            e.date.day == day.day)
        .fold<double>(0, (double sum, ExpenseItem e) => sum + e.amount);
  });

  final double income = profile?.monthlyIncome ?? 0;
  final double balance = profile?.currentBalance ?? 0;
  // Budget = monthly income (sensible default). Falls back to spent so the
  // bar always renders for first-time users without an income set.
  final double budget = income > 0 ? income : (monthTotal > 0 ? monthTotal : 1000);

  return FinanceStats(
    monthTotal: monthTotal,
    todayTotal: todayTotal,
    budget: budget,
    income: income,
    balance: balance,
    currencyCode: profile?.currencyCode ?? 'USD',
    currencySymbol: CurrencyOption.byCode(profile?.currencyCode ?? 'USD').symbol,
    byCategory: byCategory,
    weekly: weekly,
  );
});

class FinanceStats {
  const FinanceStats({
    required this.monthTotal,
    required this.todayTotal,
    required this.budget,
    required this.income,
    required this.balance,
    required this.currencyCode,
    required this.currencySymbol,
    required this.byCategory,
    required this.weekly,
  });

  final double monthTotal;
  final double todayTotal;
  final double budget;
  final double income;
  final double balance;
  final String currencyCode;
  final String currencySymbol;
  final Map<ExpenseCategory, double> byCategory;
  final List<double> weekly;

  double get budgetRatio =>
      budget == 0 ? 0 : (monthTotal / budget).clamp(0, 1.0);
  double get budgetLeft => (budget - monthTotal).clamp(0, double.infinity);
  double get savingsRatio =>
      income == 0 ? 0 : ((income - monthTotal) / income).clamp(0, 1.0);
  double get spentPct =>
      income == 0 ? 0 : (monthTotal / income * 100).clamp(0, 999);
}
