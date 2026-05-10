import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences/preferences_provider.dart';

class NotificationSettings {
  const NotificationSettings({
    this.masterEnabled = true,
    this.remindersEnabled = true,
    this.dailyDigestEnabled = false,
    this.habitNudgesEnabled = false,
    this.soundEnabled = true,
    this.vibrationEnabled = true,
  });

  final bool masterEnabled;
  final bool remindersEnabled;
  final bool dailyDigestEnabled;
  final bool habitNudgesEnabled;
  final bool soundEnabled;
  final bool vibrationEnabled;

  /// True only when both the master switch *and* the per-channel switch
  /// are on — the notification service uses this gate.
  bool get reminderActive => masterEnabled && remindersEnabled;

  NotificationSettings copyWith({
    bool? masterEnabled,
    bool? remindersEnabled,
    bool? dailyDigestEnabled,
    bool? habitNudgesEnabled,
    bool? soundEnabled,
    bool? vibrationEnabled,
  }) {
    return NotificationSettings(
      masterEnabled: masterEnabled ?? this.masterEnabled,
      remindersEnabled: remindersEnabled ?? this.remindersEnabled,
      dailyDigestEnabled: dailyDigestEnabled ?? this.dailyDigestEnabled,
      habitNudgesEnabled: habitNudgesEnabled ?? this.habitNudgesEnabled,
      soundEnabled: soundEnabled ?? this.soundEnabled,
      vibrationEnabled: vibrationEnabled ?? this.vibrationEnabled,
    );
  }

  Map<String, dynamic> toJson() => <String, dynamic>{
        'masterEnabled': masterEnabled,
        'remindersEnabled': remindersEnabled,
        'dailyDigestEnabled': dailyDigestEnabled,
        'habitNudgesEnabled': habitNudgesEnabled,
        'soundEnabled': soundEnabled,
        'vibrationEnabled': vibrationEnabled,
      };

  static NotificationSettings fromJson(Map<String, dynamic> json) =>
      NotificationSettings(
        masterEnabled: json['masterEnabled'] as bool? ?? true,
        remindersEnabled: json['remindersEnabled'] as bool? ?? true,
        dailyDigestEnabled: json['dailyDigestEnabled'] as bool? ?? false,
        habitNudgesEnabled: json['habitNudgesEnabled'] as bool? ?? false,
        soundEnabled: json['soundEnabled'] as bool? ?? true,
        vibrationEnabled: json['vibrationEnabled'] as bool? ?? true,
      );
}

class NotificationSettingsController
    extends StateNotifier<NotificationSettings> {
  NotificationSettingsController(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.notif_settings';
  final SharedPreferences _prefs;

  static NotificationSettings _load(SharedPreferences prefs) {
    final String? raw = prefs.getString(_key);
    if (raw == null) return const NotificationSettings();
    try {
      return NotificationSettings.fromJson(
          jsonDecode(raw) as Map<String, dynamic>);
    } catch (_) {
      return const NotificationSettings();
    }
  }

  Future<void> _persist() =>
      _prefs.setString(_key, jsonEncode(state.toJson()));

  Future<void> setMaster(bool v) async {
    state = state.copyWith(masterEnabled: v);
    await _persist();
  }

  Future<void> setReminders(bool v) async {
    state = state.copyWith(remindersEnabled: v);
    await _persist();
  }

  Future<void> setDailyDigest(bool v) async {
    state = state.copyWith(dailyDigestEnabled: v);
    await _persist();
  }

  Future<void> setHabitNudges(bool v) async {
    state = state.copyWith(habitNudgesEnabled: v);
    await _persist();
  }

  Future<void> setSound(bool v) async {
    state = state.copyWith(soundEnabled: v);
    await _persist();
  }

  Future<void> setVibration(bool v) async {
    state = state.copyWith(vibrationEnabled: v);
    await _persist();
  }

  Future<void> replace(NotificationSettings s) async {
    state = s;
    await _persist();
  }
}

final StateNotifierProvider<NotificationSettingsController,
        NotificationSettings> notificationSettingsProvider =
    StateNotifierProvider<NotificationSettingsController, NotificationSettings>(
        (Ref ref) {
  return NotificationSettingsController(
      ref.watch(sharedPreferencesProvider));
});
