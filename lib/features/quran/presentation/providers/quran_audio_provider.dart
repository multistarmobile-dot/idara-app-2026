import 'dart:async';

import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../domain/entities/ayah.dart';
import 'quran_providers.dart';

enum AudioRepeat { off, ayah, surah }

class QuranAudioState {
  final int? surah;
  final List<AyahAudio> tracks;
  final List<Ayah> ayat; // display text (khali ho sakta hai)
  final int index;
  final bool loading;
  final bool playing;
  final AudioRepeat repeat;
  final String? error;

  const QuranAudioState({
    this.surah,
    this.tracks = const <AyahAudio>[],
    this.ayat = const <Ayah>[],
    this.index = 0,
    this.loading = false,
    this.playing = false,
    this.repeat = AudioRepeat.off,
    this.error,
  });

  QuranAudioState copyWith({
    int? surah,
    List<AyahAudio>? tracks,
    List<Ayah>? ayat,
    int? index,
    bool? loading,
    bool? playing,
    AudioRepeat? repeat,
    String? error,
    bool clearError = false,
  }) {
    return QuranAudioState(
      surah: surah ?? this.surah,
      tracks: tracks ?? this.tracks,
      ayat: ayat ?? this.ayat,
      index: index ?? this.index,
      loading: loading ?? this.loading,
      playing: playing ?? this.playing,
      repeat: repeat ?? this.repeat,
      error: clearError ? null : (error ?? this.error),
    );
  }
}

class QuranAudioNotifier extends Notifier<QuranAudioState> {
  late AudioPlayer _player;
  final List<StreamSubscription<dynamic>> _subs = <StreamSubscription<dynamic>>[];

  @override
  QuranAudioState build() {
    _player = AudioPlayer();
    _subs.add(_player.onPlayerComplete.listen((_) => _onComplete()));
    _subs.add(
      _player.onPlayerStateChanged.listen((s) {
        state = state.copyWith(playing: s == PlayerState.playing);
      }),
    );
    ref.onDispose(() {
      for (final s in _subs) {
        s.cancel();
      }
      _player.dispose();
    });
    return const QuranAudioState();
  }

  Future<void> openSurah(int surah, {int startIndex = 0, bool autoplay = true}) async {
    await _player.stop();
    state = QuranAudioState(surah: surah, loading: true, repeat: state.repeat);
    try {
      final repo = ref.read(quranRepositoryProvider);
      final results = await Future.wait<Object>([
        repo.getSurahAudio(surah),
        repo
            .getSurah(surah, const [QuranEdition.urdu])
            .catchError((Object _) => <Ayah>[]),
      ]);
      final tracks = results[0] as List<AyahAudio>;
      final ayat = results[1] as List<Ayah>;
      final idx = startIndex < 0
          ? 0
          : (startIndex >= tracks.length ? tracks.length - 1 : startIndex);
      state = state.copyWith(tracks: tracks, ayat: ayat, index: idx, loading: false);
      if (autoplay) await _playIndex(idx);
    } catch (_) {
      state = state.copyWith(
        loading: false,
        error: 'آڈیو لوڈ نہیں ہو سکی۔ انٹرنیٹ چیک کر کے دوبارہ کوشش کریں۔',
      );
    }
  }

  Future<void> _playIndex(int i) async {
    if (i < 0 || i >= state.tracks.length) return;
    state = state.copyWith(index: i, clearError: true);
    try {
      await _player.play(UrlSource(state.tracks[i].url));
    } catch (_) {
      state = state.copyWith(
        playing: false,
        error: 'آڈیو نہیں چل سکی۔ انٹرنیٹ چیک کریں۔',
      );
    }
  }

  Future<void> togglePlay() async {
    if (state.tracks.isEmpty) return;
    if (state.playing) {
      await _player.pause();
    } else if (_player.state == PlayerState.paused) {
      await _player.resume();
    } else {
      await _playIndex(state.index);
    }
  }

  Future<void> playAt(int i) => _playIndex(i);

  Future<void> next() => _playIndex(state.index + 1);

  Future<void> previous() => _playIndex(state.index - 1);

  Future<void> stop() async {
    await _player.stop();
    state = state.copyWith(playing: false);
  }

  void cycleRepeat() {
    final next = AudioRepeat.values[(state.repeat.index + 1) % AudioRepeat.values.length];
    state = state.copyWith(repeat: next);
  }

  void _onComplete() {
    final last = state.tracks.length - 1;
    switch (state.repeat) {
      case AudioRepeat.ayah:
        _playIndex(state.index);
        break;
      case AudioRepeat.surah:
        _playIndex(state.index < last ? state.index + 1 : 0);
        break;
      case AudioRepeat.off:
        if (state.index < last) {
          _playIndex(state.index + 1);
        } else {
          state = state.copyWith(playing: false);
        }
        break;
    }
  }
}

final quranAudioProvider =
    NotifierProvider<QuranAudioNotifier, QuranAudioState>(QuranAudioNotifier.new);
