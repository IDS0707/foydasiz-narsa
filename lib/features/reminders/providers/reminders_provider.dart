import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/preferences/preferences_provider.dart';
import '../data/reminder_model.dart';

class RemindersNotifier extends StateNotifier<List<ReminderItem>> {
  RemindersNotifier(this._prefs) : super(_load(_prefs)) {
    // Re-arm OS notifications for every persisted reminder on startup.
    _bootstrap();
  }

  static const String _key = 'lifehub.reminders';
  final SharedPreferences _prefs;

  static List<ReminderItem> _load(SharedPreferences prefs) {
    final List<String>? raw = prefs.getStringList(_key);
    if (raw == null) return <ReminderItem>[];
    return raw.map(ReminderItem.decode).toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
        _key, state.map((ReminderItem r) => r.encode()).toList());
  }

  Future<void> _bootstrap() async {
    if (state.isEmpty) return;
    await NotificationService.instance.init();
    await NotificationService.instance.rescheduleAll(state);
  }

  Future<void> add(ReminderItem r) async {
    state = <ReminderItem>[r, ...state];
    await _persist();
    if (r.enabled) {
      await NotificationService.instance.scheduleReminder(r);
    }
  }

  Future<void> update(ReminderItem r) async {
    state = state.map((ReminderItem x) => x.id == r.id ? r : x).toList();
    await _persist();
    await NotificationService.instance.scheduleReminder(r);
  }

  Future<void> toggle(String id) async {
    ReminderItem? changed;
    state = state.map((ReminderItem r) {
      if (r.id != id) return r;
      changed = r.copyWith(enabled: !r.enabled);
      return changed!;
    }).toList();
    await _persist();
    if (changed != null) {
      if (changed!.enabled) {
        await NotificationService.instance.scheduleReminder(changed!);
      } else {
        await NotificationService.instance
            .cancelReminder(changed!.notificationId);
      }
    }
  }

  Future<void> remove(String id) async {
    final ReminderItem? going =
        state.where((ReminderItem r) => r.id == id).cast<ReminderItem?>().firstWhere(
              (ReminderItem? _) => true,
              orElse: () => null,
            );
    state = state.where((ReminderItem r) => r.id != id).toList();
    await _persist();
    if (going != null) {
      await NotificationService.instance
          .cancelReminder(going.notificationId);
    }
  }
}

final StateNotifierProvider<RemindersNotifier, List<ReminderItem>>
    remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<ReminderItem>>((Ref ref) {
  return RemindersNotifier(ref.watch(sharedPreferencesProvider));
});
