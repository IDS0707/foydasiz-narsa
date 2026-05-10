import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/preferences_provider.dart';
import '../data/task_model.dart';

class TasksNotifier extends StateNotifier<List<TaskItem>> {
  TasksNotifier(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.tasks';
  final SharedPreferences _prefs;

  static List<TaskItem> _load(SharedPreferences prefs) {
    final List<String>? raw = prefs.getStringList(_key);
    if (raw == null) return <TaskItem>[];
    return raw.map(TaskItem.decode).toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
      _key,
      state.map((TaskItem t) => t.encode()).toList(),
    );
  }

  Future<void> toggle(String id) async {
    state = state
        .map((TaskItem t) => t.id == id ? t.copyWith(done: !t.done) : t)
        .toList();
    await _persist();
  }

  Future<void> add(TaskItem t) async {
    state = <TaskItem>[t, ...state];
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((TaskItem t) => t.id != id).toList();
    await _persist();
  }
}

final StateNotifierProvider<TasksNotifier, List<TaskItem>> tasksProvider =
    StateNotifierProvider<TasksNotifier, List<TaskItem>>((Ref ref) {
  return TasksNotifier(ref.watch(sharedPreferencesProvider));
});

final Provider<TasksStats> tasksStatsProvider = Provider<TasksStats>((Ref ref) {
  final List<TaskItem> all = ref.watch(tasksProvider);
  final List<TaskItem> today =
      all.where((TaskItem t) => t.isToday).toList();
  final int doneToday = today.where((TaskItem t) => t.done).length;
  return TasksStats(
    totalToday: today.length,
    doneToday: doneToday,
    totalAll: all.length,
    doneAll: all.where((TaskItem t) => t.done).length,
  );
});

class TasksStats {
  const TasksStats({
    required this.totalToday,
    required this.doneToday,
    required this.totalAll,
    required this.doneAll,
  });

  final int totalToday;
  final int doneToday;
  final int totalAll;
  final int doneAll;

  double get todayRatio => totalToday == 0 ? 0 : doneToday / totalToday;
}
