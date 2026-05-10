import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/notifications/notification_service.dart';
import '../../../core/notifications/notification_settings.dart';
import '../../../core/preferences/preferences_provider.dart';
import '../data/reminder_model.dart';

class RemindersNotifier extends StateNotifier<List<ReminderItem>> {
  RemindersNotifier(this._prefs, this._readSettings) : super(_load(_prefs)) {
    _bootstrap();
  }

  static const String _key = 'lifehub.reminders';
  final SharedPreferences _prefs;
  final NotificationSettings Function() _readSettings;

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
    await NotificationService.instance
        .rescheduleAll(state, settings: _readSettings());
  }

  /// Cancel everything, then re-arm based on the current state. Called by
  /// the settings page when the master switch flips.
  Future<void> applySettings(NotificationSettings settings) async {
    await NotificationService.instance
        .rescheduleAll(state, settings: settings);
  }

  Future<void> add(ReminderItem r) async {
    state = <ReminderItem>[r, ...state];
    await _persist();
    if (r.enabled) {
      await NotificationService.instance
          .scheduleReminder(r, settings: _readSettings());
    }
  }

  Future<void> update(ReminderItem r) async {
    state = state.map((ReminderItem x) => x.id == r.id ? r : x).toList();
    await _persist();
    await NotificationService.instance
        .scheduleReminder(r, settings: _readSettings());
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
        await NotificationService.instance
            .scheduleReminder(changed!, settings: _readSettings());
      } else {
        await NotificationService.instance
            .cancelReminder(changed!.notificationId);
      }
    }
  }

  Future<void> remove(String id) async {
    ReminderItem? going;
    for (final ReminderItem r in state) {
      if (r.id == id) {
        going = r;
        break;
      }
    }
    state = state.where((ReminderItem r) => r.id != id).toList();
    await _persist();
    if (going != null) {
      await NotificationService.instance
          .cancelReminder(going.notificationId);
    }
  }

  /// Used by the restore flow — overwrite the in-memory list and persist.
  Future<void> replaceAll(List<ReminderItem> next) async {
    state = next;
    await _persist();
    await NotificationService.instance
        .rescheduleAll(state, settings: _readSettings());
  }
}

final StateNotifierProvider<RemindersNotifier, List<ReminderItem>>
    remindersProvider =
    StateNotifierProvider<RemindersNotifier, List<ReminderItem>>((Ref ref) {
  return RemindersNotifier(
    ref.watch(sharedPreferencesProvider),
    () => ref.read(notificationSettingsProvider),
  );
});
