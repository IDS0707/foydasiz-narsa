import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/preferences_provider.dart';
import '../data/user_profile.dart';

class UserProfileController extends StateNotifier<UserProfile?> {
  UserProfileController(this._prefs) : super(_load(_prefs));

  static const String _profileKey = 'lifehub.user_profile';
  static const String _onboardedKey = 'lifehub.onboarded';

  final SharedPreferences _prefs;

  static UserProfile? _load(SharedPreferences prefs) {
    final String? raw = prefs.getString(_profileKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return UserProfile.decode(raw);
    } catch (_) {
      return null;
    }
  }

  bool get isOnboarded => _prefs.getBool(_onboardedKey) ?? false;

  Future<void> save(UserProfile profile) async {
    state = profile;
    await _prefs.setString(_profileKey, profile.encode());
    await _prefs.setBool(_onboardedKey, true);
  }

  Future<void> updateBalance(double newBalance) async {
    final UserProfile? cur = state;
    if (cur == null) return;
    final UserProfile next = cur.copyWith(currentBalance: newBalance);
    state = next;
    await _prefs.setString(_profileKey, next.encode());
  }

  /// Persists arbitrary edits without resetting onboarding.
  Future<void> update(UserProfile next) async {
    state = next;
    await _prefs.setString(_profileKey, next.encode());
  }

  Future<void> reset() async {
    state = null;
    await _prefs.remove(_profileKey);
    await _prefs.setBool(_onboardedKey, false);
  }
}

final StateNotifierProvider<UserProfileController, UserProfile?>
    userProfileProvider =
    StateNotifierProvider<UserProfileController, UserProfile?>(
        (Ref ref) {
  return UserProfileController(ref.watch(sharedPreferencesProvider));
});

final Provider<bool> isOnboardedProvider = Provider<bool>((Ref ref) {
  return ref.watch(userProfileProvider) != null;
});
