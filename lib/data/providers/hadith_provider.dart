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

  String exportNotesAsFormattedText(List<HadithModel> allHadiths) {
    if (state.isEmpty) return '';
    final buffer = StringBuffer();
    final now = DateTime.now();
    final dateFormatted =
        '${now.year}/${now.month.toString().padLeft(2, '0')}/${now.day.toString().padLeft(2, '0')}';

    buffer.writeln('════════════════════════════════════');
    buffer.writeln('📖 ملاحظات وتأملات من كتاب: تُحْفَةُ الوِلْدَانِ فِي الأَحَادِيثِ النَّبَوِيَّةِ');
    buffer.writeln('✍️ تأليف: الأستاذ إبراهيم شريف أبوبكر');
    buffer.writeln('📅 تاريخ التصدير: $dateFormatted');
    buffer.writeln('🔢 إجمالي الملاحظات: ${state.length}');
    buffer.writeln('════════════════════════════════════\n');

    final sortedEntries = state.entries.toList()
      ..sort((a, b) => a.key.compareTo(b.key));

    for (final entry in sortedEntries) {
      final hadith = allHadiths.firstWhere(
        (h) => h.id == entry.key,
        orElse: () => HadithModel(
          id: entry.key,
          title: 'الحديث ${entry.key}',
          narrator: '',
          text: '',
          source: '',
          hadithNumber: '',
          footnotes: [],
        ),
      );

      final noteDate =
          '${entry.value.updatedAt.year}/${entry.value.updatedAt.month.toString().padLeft(2, '0')}/${entry.value.updatedAt.day.toString().padLeft(2, '0')}';

      buffer.writeln('🔹 [الحديث ${entry.key}]: ${hadith.title}');
      if (hadith.narrator.isNotEmpty) {
        buffer.writeln('👤 الراوي: ${hadith.narrator}');
      }
      if (hadith.text.isNotEmpty) {
        buffer.writeln('📜 نص الحديث:\n«${hadith.text}»');
      }
      if (hadith.source.isNotEmpty) {
        buffer.writeln('📚 التخريج: ${hadith.source}${hadith.hadithNumber.isNotEmpty ? " (${hadith.hadithNumber})" : ""}');
      }
      buffer.writeln('💡 الملاحظة والفوائد:');
      buffer.writeln(entry.value.note);
      buffer.writeln('🕒 آخر تعديل: $noteDate');
      buffer.writeln('────────────────────────────────────\n');
    }

    buffer.writeln('✨ تم التصدير عبر تطبيق «تحفة الولدان» • تأليف: الأستاذ إبراهيم شريف أبوبكر');
    return buffer.toString();
  }

  String exportNotesAsJson() {
    final list = state.values.map((n) => n.toJson()).toList();
    final backupData = {
      'app': 'Tuhfat Al-Wildan',
      'author': 'الأستاذ إبراهيم شريف أبوبكر',
      'version': 1,
      'exportedAt': DateTime.now().toIso8601String(),
      'notesCount': list.length,
      'notes': list,
    };
    return const JsonEncoder.withIndent('  ').convert(backupData);
  }

  int importNotesFromJson(String jsonStr) {
    try {
      final dynamic decoded = json.decode(jsonStr);
      final updated = Map<int, HadithNote>.from(state);
      int importedCount = 0;

      if (decoded is Map<String, dynamic>) {
        if (decoded.containsKey('notes') && decoded['notes'] is List) {
          final notesList = decoded['notes'] as List;
          for (final item in notesList) {
            if (item is Map<String, dynamic>) {
              final note = HadithNote.fromJson(item);
              if (note.hadithId > 0 && note.note.trim().isNotEmpty) {
                updated[note.hadithId] = note;
                importedCount++;
              }
            }
          }
        } else {
          decoded.forEach((key, value) {
            final id = int.tryParse(key);
            if (id != null && value is Map<String, dynamic>) {
              final note = HadithNote.fromJson(value);
              if (note.note.trim().isNotEmpty) {
                updated[id] = note;
                importedCount++;
              }
            }
          });
        }
      } else if (decoded is List) {
        for (final item in decoded) {
          if (item is Map<String, dynamic>) {
            final note = HadithNote.fromJson(item);
            if (note.hadithId > 0 && note.note.trim().isNotEmpty) {
              updated[note.hadithId] = note;
              importedCount++;
            }
          }
        }
      }

      if (importedCount > 0) {
        state = updated;
        _persist();
      }
      return importedCount;
    } catch (_) {
      return 0;
    }
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
  final int repeatCount; // 1 = once, 3 = 3 times, 5 = 5 times, 10 = 10 times, -1 = infinite loop
  final int currentRepeatIndex;
  final int currentWordStart;
  final int currentWordEnd;
  final String currentSpokenWord;

  const AudioPlayerState({
    this.status = AudioPlaybackStatus.stopped,
    this.currentHadithId,
    this.playbackRate = 0.45,
    this.repeatCount = 1,
    this.currentRepeatIndex = 1,
    this.currentWordStart = 0,
    this.currentWordEnd = 0,
    this.currentSpokenWord = '',
  });

  bool get isPlaying => status == AudioPlaybackStatus.playing;
  bool get isPaused => status == AudioPlaybackStatus.paused;
  bool get isStopped => status == AudioPlaybackStatus.stopped;

  AudioPlayerState copyWith({
    AudioPlaybackStatus? status,
    int? currentHadithId,
    double? playbackRate,
    int? repeatCount,
    int? currentRepeatIndex,
    int? currentWordStart,
    int? currentWordEnd,
    String? currentSpokenWord,
  }) {
    return AudioPlayerState(
      status: status ?? this.status,
      currentHadithId: currentHadithId ?? this.currentHadithId,
      playbackRate: playbackRate ?? this.playbackRate,
      repeatCount: repeatCount ?? this.repeatCount,
      currentRepeatIndex: currentRepeatIndex ?? this.currentRepeatIndex,
      currentWordStart: currentWordStart ?? this.currentWordStart,
      currentWordEnd: currentWordEnd ?? this.currentWordEnd,
      currentSpokenWord: currentSpokenWord ?? this.currentSpokenWord,
    );
  }
}

class AudioPlayerNotifier extends StateNotifier<AudioPlayerState> {
  final FlutterTts _tts = FlutterTts();
  final SharedPreferences? _prefs;
  static const _rateKey = 'audio_playback_rate';
  static const _repeatKey = 'audio_repeat_count';
  bool _isInitialized = false;
  HadithModel? _currentHadith;
  bool _isDisposed = false;

  AudioPlayerNotifier([this._prefs])
      : super(AudioPlayerState(
          playbackRate: _prefs?.getDouble(_rateKey) ?? 0.45,
          repeatCount: _prefs?.getInt(_repeatKey) ?? 1,
        )) {
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('ar');
      await _tts.setSpeechRate(state.playbackRate);
      await _tts.setPitch(1.0);

      try {
        await _tts.setIosAudioCategory(
          IosTextToSpeechAudioCategory.playback,
          [
            IosTextToSpeechAudioCategoryOptions.mixWithOthers,
            IosTextToSpeechAudioCategoryOptions.defaultToSpeaker,
          ],
          IosTextToSpeechAudioMode.defaultMode,
        );
      } catch (_) {}

      _tts.setStartHandler(() {
        if (!_isDisposed) {
          state = state.copyWith(status: AudioPlaybackStatus.playing);
        }
      });

      _tts.setProgressHandler((String text, int start, int end, String word) {
        if (!_isDisposed && state.isPlaying) {
          state = state.copyWith(
            currentWordStart: start,
            currentWordEnd: end,
            currentSpokenWord: word,
          );
        }
      });

      _tts.setCompletionHandler(() async {
        if (_isDisposed) return;

        final canRepeatInfinite = state.repeatCount == -1;
        final hasMoreRepeats =
            state.repeatCount > 1 && state.currentRepeatIndex < state.repeatCount;

        if ((canRepeatInfinite || hasMoreRepeats) &&
            state.status == AudioPlaybackStatus.playing &&
            _currentHadith != null) {
          state = state.copyWith(
            currentRepeatIndex: state.currentRepeatIndex + 1,
            currentWordStart: 0,
            currentWordEnd: 0,
            currentSpokenWord: '',
          );
          // Brief 1.2s pause between repetitions for breathing & reflection
          await Future.delayed(const Duration(milliseconds: 1200));
          if (!_isDisposed && state.isPlaying && _currentHadith != null) {
            await _speakHadithText(_currentHadith!);
          }
        } else {
          state = state.copyWith(
            status: AudioPlaybackStatus.stopped,
            currentHadithId: null,
            currentRepeatIndex: 1,
            currentWordStart: 0,
            currentWordEnd: 0,
            currentSpokenWord: '',
          );
        }
      });

      _tts.setCancelHandler(() {
        if (!_isDisposed) {
          state = state.copyWith(
            status: AudioPlaybackStatus.stopped,
            currentHadithId: null,
            currentRepeatIndex: 1,
            currentWordStart: 0,
            currentWordEnd: 0,
            currentSpokenWord: '',
          );
        }
      });

      _tts.setPauseHandler(() {
        if (!_isDisposed) {
          state = state.copyWith(status: AudioPlaybackStatus.paused);
        }
      });

      _tts.setContinueHandler(() {
        if (!_isDisposed) {
          state = state.copyWith(status: AudioPlaybackStatus.playing);
        }
      });

      _tts.setErrorHandler((msg) {
        if (!_isDisposed) {
          state = state.copyWith(
            status: AudioPlaybackStatus.stopped,
            currentHadithId: null,
            currentRepeatIndex: 1,
            currentWordStart: 0,
            currentWordEnd: 0,
            currentSpokenWord: '',
          );
        }
      });

      _isInitialized = true;
    } catch (_) {}
  }

  String _buildSourceSpeech(String source, String hadithNumber) {
    final cleanSource = source.trim();
    final cleanNum = hadithNumber.trim();

    if (cleanSource.isEmpty && cleanNum.isEmpty) {
      return '';
    }

    if (cleanNum.isEmpty) {
      return cleanSource.endsWith('.') ? cleanSource : '$cleanSource.';
    }

    // Format number segments with Arabic preposition "برقم"
    // e.g. "البخاري: 1، مسلم: 1907" -> "البخاري برقم 1، ومسلم برقم 1907"
    String formattedNum = cleanNum
        .replaceAllMapped(RegExp(r'(\S+):\s*(\d+)'), (match) {
          return '${match.group(1)} برقم ${match.group(2)}';
        })
        .replaceAll('، ', '، و')
        .replaceAll('،', '، و');

    // If source is "متفق عليه"
    if (cleanSource == 'متفق عليه') {
      return 'متفق عليه. $formattedNum.';
    }

    // If source starts with "رواه" and formattedNum starts with that same book
    if (cleanSource.startsWith('رواه ')) {
      final bookName = cleanSource.substring(5).trim();
      if (formattedNum.startsWith(bookName)) {
        return 'رواه $formattedNum.';
      }
      return '$cleanSource. $formattedNum.';
    }

    return '$cleanSource. $formattedNum.';
  }

  Future<void> _speakHadithText(HadithModel hadith) async {
    final cleanTitle = hadith.title.trim();
    final cleanNarrator = hadith.narrator.trim();
    final cleanText = hadith.text
        .replaceAll('«', '')
        .replaceAll('»', '')
        .replaceAll('"', '')
        .replaceAll('(', '')
        .replaceAll(')', '')
        .trim();

    final sourceSpeech = _buildSourceSpeech(hadith.source, hadith.hadithNumber);

    final speechText = sourceSpeech.isNotEmpty
        ? '$cleanTitle. $cleanNarrator. $cleanText. $sourceSpeech'
        : '$cleanTitle. $cleanNarrator. $cleanText.';

    await _tts.setLanguage('ar');
    await _tts.setSpeechRate(state.playbackRate);
    await _tts.speak(speechText);
  }

  Future<void> playHadith(HadithModel hadith) async {
    if (!_isInitialized) {
      await _initTts();
    }

    _currentHadith = hadith;

    if (state.currentHadithId == hadith.id && state.isPaused) {
      state = state.copyWith(status: AudioPlaybackStatus.playing);
    }

    // Stop previous audio
    await _tts.stop();

    state = state.copyWith(
      status: AudioPlaybackStatus.playing,
      currentHadithId: hadith.id,
      currentRepeatIndex: 1,
      currentWordStart: 0,
      currentWordEnd: 0,
      currentSpokenWord: '',
    );

    await _speakHadithText(hadith);
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
      currentRepeatIndex: 1,
      currentWordStart: 0,
      currentWordEnd: 0,
      currentSpokenWord: '',
    );
  }

  Future<void> setRate(double rate) async {
    state = state.copyWith(playbackRate: rate);
    await _tts.setSpeechRate(rate);
    if (_prefs != null) {
      await _prefs.setDouble(_rateKey, rate);
    }
  }

  Future<void> setRepeatCount(int count) async {
    state = state.copyWith(repeatCount: count, currentRepeatIndex: 1);
    if (_prefs != null) {
      await _prefs.setInt(_repeatKey, count);
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _tts.stop();
    super.dispose();
  }
}

final audioPlayerProvider =
    StateNotifierProvider<AudioPlayerNotifier, AudioPlayerState>((ref) {
  final prefs = ref.watch(sharedPrefsProvider);
  return AudioPlayerNotifier(prefs);
});
