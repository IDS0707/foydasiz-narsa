import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../core/preferences/preferences_provider.dart';
import '../data/shopping_model.dart';

class ShoppingNotifier extends StateNotifier<List<ShoppingItem>> {
  ShoppingNotifier(this._prefs) : super(_load(_prefs));

  static const String _key = 'lifehub.shopping';
  final SharedPreferences _prefs;

  static List<ShoppingItem> _load(SharedPreferences prefs) {
    final List<String>? raw = prefs.getStringList(_key);
    if (raw == null) return <ShoppingItem>[];
    return raw.map(ShoppingItem.decode).toList();
  }

  Future<void> _persist() async {
    await _prefs.setStringList(
        _key, state.map((ShoppingItem i) => i.encode()).toList());
  }

  Future<void> add(ShoppingItem i) async {
    state = <ShoppingItem>[i, ...state];
    await _persist();
  }

  Future<void> update(ShoppingItem next) async {
    state =
        state.map((ShoppingItem i) => i.id == next.id ? next : i).toList();
    await _persist();
  }

  Future<void> remove(String id) async {
    state = state.where((ShoppingItem i) => i.id != id).toList();
    await _persist();
  }

  Future<void> toggle(String id) async {
    state = state
        .map((ShoppingItem i) =>
            i.id == id ? i.copyWith(bought: !i.bought) : i)
        .toList();
    await _persist();
  }

  Future<void> replaceAll(List<ShoppingItem> next) async {
    state = next;
    await _persist();
  }
}

final StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>
    shoppingProvider =
    StateNotifierProvider<ShoppingNotifier, List<ShoppingItem>>((Ref ref) {
  return ShoppingNotifier(ref.watch(sharedPreferencesProvider));
});
