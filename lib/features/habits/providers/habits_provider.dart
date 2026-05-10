import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/preferences_provider.dart';
import '../data/habit_model.dart';

class HabitsNotifier extends StateNotifier<List<HabitItem>> {
  HabitsNotifier(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.habits';
  final SharedPreferences _prefs;

  static List<HabitItem> _load(SharedPreferences prefs) {
    final List<String>? raw = prefs.getStringList(_key);
    if (raw == null) return <HabitItem>[];
    return raw.map(HabitItem.decode).toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
        _key, state.map((HabitItem h) => h.encode()).toList());
  }

  Future<void> add(HabitItem h) async {
    state = <HabitItem>[h, ...state];
    await _persist();
  }

  Future<void> update(HabitItem next) async {
    state = state.map((HabitItem h) => h.id == next.id ? next : h).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((HabitItem h) => h.id != id).toList();
    await _persist();
  }

  Future<void> replaceAll(List<HabitItem> next) async {
    state = next;
    await _persist();
  }

  Future<void> toggleToday(String id) async {
    final DateTime key = _todayKey();
    state = state.map((HabitItem h) {
      if (h.id != id) return h;
      final Set<DateTime> next = <DateTime>{...h.completedDays};
      if (next.contains(key)) {
        next.remove(key);
      } else {
        next.add(key);
      }
      return h.copyWith(
        completedDays: next,
        streak: _computeStreak(next),
      );
    }).toList();
    await _persist();
  }

  int _computeStreak(Set<DateTime> days) {
    int streak = 0;
    DateTime cursor = _todayKey();
    while (days.contains(cursor)) {
      streak += 1;
      cursor = cursor.subtract(const Duration(days: 1));
    }
    return streak;
  }

  static DateTime _todayKey() {
    final DateTime n = DateTime.now();
    return DateTime(n.year, n.month, n.day);
  }
}

final StateNotifierProvider<HabitsNotifier, List<HabitItem>> habitsProvider =
    StateNotifierProvider<HabitsNotifier, List<HabitItem>>((Ref ref) {
  return HabitsNotifier(ref.watch(sharedPreferencesProvider));
});

final Provider<HabitsStats> habitsStatsProvider =
    Provider<HabitsStats>((Ref ref) {
  final List<HabitItem> all = ref.watch(habitsProvider);
  final int doneToday = all.where((HabitItem h) => h.isDoneToday).length;
  final int bestStreak = all.fold<int>(
      0, (int m, HabitItem h) => h.streak > m ? h.streak : m);
  return HabitsStats(
    total: all.length,
    doneToday: doneToday,
    bestStreak: bestStreak,
  );
});

class HabitsStats {
  const HabitsStats({
    required this.total,
    required this.doneToday,
    required this.bestStreak,
  });

  final int total;
  final int doneToday;
  final int bestStreak;

  double get ratio => total == 0 ? 0 : doneToday / total;
}
