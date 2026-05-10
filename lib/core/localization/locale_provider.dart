import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../preferences/preferences_provider.dart';

class LocaleController extends StateNotifier<Locale> {
  LocaleController(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.locale';
  static const String _chosenKey = 'lifehub.locale_chosen';

  final SharedPreferences _prefs;

  static Locale _load(SharedPreferences prefs) {
    final String? raw = prefs.getString(_key);
    switch (raw) {
      case 'ru':
        return const Locale('ru');
      case 'uz':
        return const Locale('uz');
      case 'en':
        return const Locale('en');
      default:
        return const Locale('en');
    }
  }

  /// True only after the user has explicitly picked a language at least once.
  /// The router uses this to force the language picker on first launch.
  bool get isExplicitlyChosen => _prefs.getBool(_chosenKey) ?? false;

  Future<void> set(Locale locale, {bool markChosen = true}) async {
    state = locale;
    await _prefs.setString(_key, locale.languageCode);
    if (markChosen) {
      await _prefs.setBool(_chosenKey, true);
    }
  }

  /// Test-only: forget the explicit pick (used by the profile reset flow).
  Future<void> clearChoice() async {
    await _prefs.setBool(_chosenKey, false);
  }
}

final StateNotifierProvider<LocaleController, Locale> localeProvider =
    StateNotifierProvider<LocaleController, Locale>(
        (Ref ref) {
  return LocaleController(ref.watch(sharedPreferencesProvider));
});

final Provider<bool> isLocaleChosenProvider = Provider<bool>((Ref ref) {
  // Watch the locale so the router re-evaluates when it changes.
  ref.watch(localeProvider);
  return ref.read(localeProvider.notifier).isExplicitlyChosen;
});
