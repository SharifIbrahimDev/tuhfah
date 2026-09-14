import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/hadith_model.dart';

// 1. SharedPreferences Provider (to be overridden in main.dart)
final sharedPrefsProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferences must be initialized and overridden in main()');
});

// 2. Load Hadith list from JSON asset
final hadithListProvider = FutureProvider<List<HadithModel>>((ref) async {
  final jsonString = await rootBundle.loadString('assets/data/hadiths.json');
  final List<dynamic> jsonList = json.decode(jsonString);
  return jsonList.map((json) => HadithModel.fromJson(json)).toList();
});

// 3. Search query provider
final searchQueryProvider = StateProvider<String>((ref) => '');

// 4. Filtered Hadith list provider
final filteredHadithListProvider = Provider<AsyncValue<List<HadithModel>>>((ref) {
  final hadithsAsync = ref.watch(hadithListProvider);
  final query = ref.watch(searchQueryProvider).trim();

  if (query.isEmpty) return hadithsAsync;

  return hadithsAsync.whenData((hadiths) {
    return hadiths.where((h) {
      final textLower = h.text.toLowerCase();
      final titleLower = h.title.toLowerCase();
      final narratorLower = h.narrator.toLowerCase();
      final sourceLower = h.source.toLowerCase();
      final queryLower = query.toLowerCase();

      return textLower.contains(queryLower) ||
          titleLower.contains(queryLower) ||
          narratorLower.contains(queryLower) ||
          sourceLower.contains(queryLower);
    }).toList();
  });
});

// 5. Favorites state manager
class FavoritesNotifier extends StateNotifier<Set<int>> {
  final SharedPreferences _prefs;
  static const _key = 'favorite_hadith_ids';

  FavoritesNotifier(this._prefs) : super({}) {
    _loadFavorites();
  }

  void _loadFavorites() {
    final list = _prefs.getStringList(_key);
    if (list != null) {
      state = list.map(int.parse).toSet();
    }
  }

  Future<void> toggleFavorite(int id) async {
    final newState = Set<int>.from(state);
    if (newState.contains(id)) {
      newState.remove(id);
    } else {
      newState.add(id);
    }
    state = newState;
    await _prefs.setStringList(_key, state.map((e) => e.toString()).toList());
  }

  bool isFavorite(int id) => state.contains(id);
}

final favoritesProvider = StateNotifierProvider<FavoritesNotifier, Set<int>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return FavoritesNotifier(prefs);
});

// 6. ThemeMode state manager
class ThemeModeNotifier extends StateNotifier<ThemeMode> {
  final SharedPreferences _prefs;
  static const _key = 'theme_mode';

  ThemeModeNotifier(this._prefs) : super(ThemeMode.system) {
    _loadThemeMode();
  }

  void _loadThemeMode() {
    final modeStr = _prefs.getString(_key);
    if (modeStr != null) {
      state = ThemeMode.values.firstWhere(
        (e) => e.name == modeStr,
        orElse: () => ThemeMode.system,
      );
    }
  }

  Future<void> setThemeMode(ThemeMode mode) async {
    state = mode;
    await _prefs.setString(_key, mode.name);
  }
}

final themeModeProvider = StateNotifierProvider<ThemeModeNotifier, ThemeMode>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return ThemeModeNotifier(prefs);
});

// 7. FontSize state manager
class FontSizeNotifier extends StateNotifier<double> {
  final SharedPreferences _prefs;
  static const _key = 'hadith_font_size';

  FontSizeNotifier(this._prefs) : super(24.0) {
    _loadFontSize();
  }

  void _loadFontSize() {
    final size = _prefs.getDouble(_key);
    if (size != null) {
      state = size;
    }
  }

  Future<void> setFontSize(double size) async {
    state = size;
    await _prefs.setDouble(_key, size);
  }
}

final fontSizeProvider = StateNotifierProvider<FontSizeNotifier, double>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return FontSizeNotifier(prefs);
});

// 8. BookSelection state manager
enum BookSelection { part1, part2, all }

final bookSelectionProvider = StateProvider<BookSelection>((ref) => BookSelection.part1);

// 9. FontFamily state manager
class FontFamilyNotifier extends StateNotifier<String> {
  final SharedPreferences _prefs;
  static const _key = 'hadith_font_family';

  FontFamilyNotifier(this._prefs) : super('Amiri') {
    final saved = _prefs.getString(_key);
    if (saved != null) state = saved;
  }

  Future<void> setFontFamily(String family) async {
    state = family;
    await _prefs.setString(_key, family);
  }
}

final fontFamilyProvider = StateNotifierProvider<FontFamilyNotifier, String>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return FontFamilyNotifier(prefs);
});

// 10. Notifications enabled provider
class NotificationsNotifier extends StateNotifier<bool> {
  final SharedPreferences _prefs;
  static const _key = 'notifications_enabled';

  NotificationsNotifier(this._prefs) : super(false) {
    state = _prefs.getBool(_key) ?? false;
  }

  Future<void> setEnabled(bool enabled) async {
    state = enabled;
    await _prefs.setBool(_key, enabled);
  }
}

final notificationsEnabledProvider =
    StateNotifierProvider<NotificationsNotifier, bool>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return NotificationsNotifier(prefs);
});
