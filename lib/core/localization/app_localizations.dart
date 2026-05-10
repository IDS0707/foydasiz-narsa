import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'translations.dart';

class AppLocalizations {
  AppLocalizations(this.locale);

  final Locale locale;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('uz'),
    Locale('ru'),
  ];

  String t(String key) {
    final Map<String, String> table = kTranslations[locale.languageCode] ??
        kTranslations['en']!;
    return table[key] ?? kTranslations['en']![key] ?? key;
  }
}

extension AppLocalizationsExt on BuildContext {
  String tr(String key) => AppLocalizations.of(this).t(key);
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'uz', 'ru'].contains(locale.languageCode);

  @override
  Future<AppLocalizations> load(Locale locale) =>
      SynchronousFuture<AppLocalizations>(AppLocalizations(locale));

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}
