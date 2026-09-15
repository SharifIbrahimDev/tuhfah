import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter_tts/flutter_tts.dart';
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

// 11. Last Read Hadith Provider
class LastReadNotifier extends StateNotifier<int?> {
  final SharedPreferences _prefs;
  static const _key = 'last_read_hadith_id';

  LastReadNotifier(this._prefs) : super(null) {
    final saved = _prefs.getInt(_key);
    if (saved != null) {
      state = saved;
    }
  }

  Future<void> setLastRead(int id) async {
    if (state == id) return;
    state = id;
    await _prefs.setInt(_key, id);
  }

  Future<void> clearLastRead() async {
    state = null;
    await _prefs.remove(_key);
  }
}

final lastReadProvider = StateNotifierProvider<LastReadNotifier, int?>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return LastReadNotifier(prefs);
});

// 12. Personal Hadith Notes Provider
class HadithNote {
  final int hadithId;
  final String note;
  final DateTime updatedAt;

  HadithNote({
    required this.hadithId,
    required this.note,
    required this.updatedAt,
  });

  factory HadithNote.fromJson(Map<String, dynamic> json) {
    return HadithNote(
      hadithId: (json['hadithId'] as num?)?.toInt() ?? 0,
      note: json['note'] as String? ?? '',
      updatedAt: json['updatedAt'] != null
          ? DateTime.tryParse(json['updatedAt'] as String) ?? DateTime.now()
          : DateTime.now(),
    );
  }

  Map<String, dynamic> toJson() => {
        'hadithId': hadithId,
        'note': note,
        'updatedAt': updatedAt.toIso8601String(),
      };
}

class HadithNotesNotifier extends StateNotifier<Map<int, HadithNote>> {
  final SharedPreferences _prefs;
  static const _key = 'user_hadith_notes_v1';

  HadithNotesNotifier(this._prefs) : super({}) {
    _loadNotes();
  }

  void _loadNotes() {
    final raw = _prefs.getString(_key);
    if (raw != null && raw.isNotEmpty) {
      try {
        final Map<String, dynamic> decoded = json.decode(raw);
        final result = <int, HadithNote>{};
        decoded.forEach((key, value) {
          final id = int.tryParse(key);
          if (id != null && value is Map<String, dynamic>) {
            result[id] = HadithNote.fromJson(value);
          }
        });
        state = result;
      } catch (_) {}
    }
  }

  Future<void> saveNote(int hadithId, String noteText) async {
    final trimmed = noteText.trim();
    final updated = Map<int, HadithNote>.from(state);
    if (trimmed.isEmpty) {
      updated.remove(hadithId);
    } else {
      updated[hadithId] = HadithNote(
        hadithId: hadithId,
        note: trimmed,
        updatedAt: DateTime.now(),
      );
    }
    state = updated;
    await _persist();
  }

  Future<void> deleteNote(int hadithId) async {
    if (!state.containsKey(hadithId)) return;
    final updated = Map<int, HadithNote>.from(state);
    updated.remove(hadithId);
    state = updated;
    await _persist();
  }

  Future<void> _persist() async {
    final mapToSave = <String, dynamic>{};
    state.forEach((key, value) {
      mapToSave[key.toString()] = value.toJson();
    });
    await _prefs.setString(_key, json.encode(mapToSave));
  }
}

final hadithNotesProvider =
    StateNotifierProvider<HadithNotesNotifier, Map<int, HadithNote>>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return HadithNotesNotifier(prefs);
});

// 13. Hadith of the Day & Randomizer Provider
class HadithOfTheDayState {
  final int? selectedHadithId;
  final bool isRandomized;

  const HadithOfTheDayState({
    this.selectedHadithId,
    this.isRandomized = false,
  });
}

class HadithOfTheDayNotifier extends StateNotifier<HadithOfTheDayState> {
  HadithOfTheDayNotifier() : super(const HadithOfTheDayState());

  void shuffle(List<HadithModel> allHadiths) {
    if (allHadiths.isEmpty) return;
    final randIndex = (DateTime.now().microsecondsSinceEpoch % allHadiths.length);
    state = HadithOfTheDayState(
      selectedHadithId: allHadiths[randIndex].id,
      isRandomized: true,
    );
  }

  void resetToToday() {
    state = const HadithOfTheDayState(selectedHadithId: null, isRandomized: false);
  }
}

final hadithOfTheDayProvider =
    StateNotifierProvider<HadithOfTheDayNotifier, HadithOfTheDayState>((ref) {
  return HadithOfTheDayNotifier();
});

// 14. Arabic Audio TTS Reciter Provider
enum AudioPlaybackStatus { stopped, playing, paused }

class AudioPlayerState {
  final AudioPlaybackStatus status;
  final int? currentHadithId;
  final double playbackRate;

  const AudioPlayerState({
    this.status = AudioPlaybackStatus.stopped,
    this.currentHadithId,
    this.playbackRate = 0.85,
  });

  bool get isPlaying => status == AudioPlaybackStatus.playing;
  bool get isPaused => status == AudioPlaybackStatus.paused;
  bool get isStopped => status == AudioPlaybackStatus.stopped;

  AudioPlayerState copyWith({
    AudioPlaybackStatus? status,
    int? currentHadithId,
    double? playbackRate,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentHadithId: currentHadithId ?? this.currentHadithId,
      playbackRate: playbackRate ?? this.playbackRate,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final FlutterTts _tts = FlutterTts();
  bool _isInitialized = false;

  AudioPlayerNotifier() : super(const AudioPlayerState()) {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(state.playbackRate);
      await _tts.setPitch(1.0);

      _tts.setStartHandler(() {
        state = state.copyWith(status: AudioPlaybackStatus.playing);
      });

      _tts.setCompletionHandler(() {
        state = state.copyWith(
          status: AudioPlaybackStatus.stopped,
          currentHadithId: null,
        );
      });

      _tts.setCancelHandler(() {
        state = state.copyWith(
          status: AudioPlaybackStatus.stopped,
          currentHadithId: null,
        );
      });

      _tts.setPauseHandler(() {
        state = state.copyWith(status: AudioPlaybackStatus.paused);
      });

      _tts.setContinueHandler(() {
        state = state.copyWith(status: AudioPlaybackStatus.playing);
      });

      _tts.setErrorHandler((msg) {
        state = state.copyWith(
          status: AudioPlaybackStatus.stopped,
          currentHadithId: null,
        );
      });

      _isInitialized = true;
    } catch (_) {}
  }

  Future<void> playHadith(HadithModel hadith) async {
    if (!_isInitialized) {
      await _initTts();
    }

    if (state.currentHadithId == hadith.id && state.isPaused) {
      // Resume
      state = state.copyWith(status: AudioPlaybackStatus.playing);
    }

    // Stop previous audio
    await _tts.stop();

    // Prepare clear text without quotation marks or footnotes symbols
    final cleanTitle = hadith.title.trim();
    final cleanNarrator = hadith.narrator.trim();
    final cleanText = hadith.text
        .replaceAll('«', '')
        .replaceAll('»', '')
        .replaceAll('"', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();

    final speechText = '$cleanTitle. $cleanNarrator. $cleanText.';

    state = state.copyWith(
      status: AudioPlaybackStatus.playing,
      currentHadithId: hadith.id,
    );

    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(state.playbackRate);
    await _tts.speak(speechText);
  }

  Future<void> pause() async {
    await _tts.pause();
    state = state.copyWith(status: AudioPlaybackStatus.paused);
  }

  Future<void> stop() async {
    await _tts.stop();
    state = state.copyWith(
      status: AudioPlaybackStatus.stopped,
      currentHadithId: null,
    );
  }

  Future<void> setRate(double rate) async {
    state = state.copyWith(playbackRate: rate);
    await _tts.setSpeechRate(rate);
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  return AudioPlayerNotifier();
});
