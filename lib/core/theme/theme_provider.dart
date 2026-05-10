import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences/preferences_provider.dart';

class ThemeModeController extends StateNotifier<ThemeMode> {
  ThemeModeController(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.theme_mode';
  final SharedPreferences _prefs;

  static ThemeMode _load(SharedPreferences prefs) {
    final String? raw = prefs.getString(_key);
    switch (raw) {
      case 'dark':
        return ThemeMode.dark;
      case 'light':
        return ThemeMode.light;
      default:
        return ThemeMode.system;
    }
  }

  Future<void> set(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }

  Future<void> toggle() async {
    final ThemeMode next =
        state == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    await set(next);
  }
}

final StateNotifierProvider<ThemeModeController, ThemeMode> themeModeProvider =
    StateNotifierProvider<ThemeModeController, ThemeMode>(
        (StateNotifierProviderRef<ThemeModeController, ThemeMode> ref) {
  return ThemeModeController(ref.watch(sharedPreferencesProvider));
});
