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

  Future<void> update(ExpenseItem next) async {
    state = state
        .map((ExpenseItem e) => e.id == next.id ? next : e)
        .toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((ExpenseItem e) => e.id != id).toList();
    await _persist();
  }

  Future<void> replaceAll(List<ExpenseItem> next) async {
    state = next;
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

  final double startingBalance = profile?.currentBalance ?? 0;
  // Live balance = starting balance minus everything spent so far
  // (includes prior months — keeps the dashboard honest as the user logs).
  final double totalSpentEver = all
      .where((ExpenseItem e) => !e.isIncome)
      .fold<double>(0, (double sum, ExpenseItem e) => sum + e.amount);
  final double currentBalance = startingBalance - totalSpentEver;

  return FinanceStats(
    monthTotal: monthTotal,
    todayTotal: todayTotal,
    startingBalance: startingBalance,
    currentBalance: currentBalance,
    currencyCode: profile?.currencyCode ?? 'USD',
    currencySymbol:
        CurrencyOption.byCode(profile?.currencyCode ?? 'USD').symbol,
    byCategory: byCategory,
    weekly: weekly,
  );
});

class FinanceStats {
  const FinanceStats({
    required this.monthTotal,
    required this.todayTotal,
    required this.startingBalance,
    required this.currentBalance,
    required this.currencyCode,
    required this.currencySymbol,
    required this.byCategory,
    required this.weekly,
  });

  final double monthTotal;
  final double todayTotal;
  // The balance the user entered during onboarding (anchor).
  final double startingBalance;
  // Anchor minus everything they've spent since.
  final double currentBalance;
  final String currencyCode;
  final String currencySymbol;
  final Map<ExpenseCategory, double> byCategory;
  final List<double> weekly;

  /// Fraction of the user's starting balance that has been spent this month.
  double get balanceUsedRatio => startingBalance == 0
      ? 0
      : (monthTotal / startingBalance).clamp(0, 1.0);

  double get balanceLeftPct => startingBalance == 0
      ? 0
      : ((currentBalance / startingBalance) * 100).clamp(0, 100);
}
