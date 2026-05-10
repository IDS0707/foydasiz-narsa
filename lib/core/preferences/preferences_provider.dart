import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

final Provider<SharedPreferences> sharedPreferencesProvider =
    Provider<SharedPreferences>((ProviderRef<SharedPreferences> ref) {
  throw UnimplementedError('sharedPreferencesProvider must be overridden');
});
