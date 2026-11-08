import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/datasources/quran_cache.dart';
import '../../data/datasources/quran_remote_datasource.dart';
import '../../data/repositories/quran_repository_impl.dart';
import '../../domain/entities/ayah.dart';
import '../../domain/repositories/quran_repository.dart';

final quranRepositoryProvider = Provider<QuranRepository>((ref) {
  return QuranRepositoryImpl(QuranRemoteDataSource(), QuranCache());
});

typedef ReaderRequest = ({bool isPara, int number, bool urdu, bool english});

final readerAyatProvider =
    FutureProvider.autoDispose.family<List<Ayah>, ReaderRequest>((ref, req) {
  final repo = ref.watch(quranRepositoryProvider);
  final editions = <String>[
    if (req.urdu) QuranEdition.urdu,
    if (req.english) QuranEdition.english,
  ];
  return req.isPara
      ? repo.getPara(req.number, editions)
      : repo.getSurah(req.number, editions);
});

final dailyAyahProvider = FutureProvider.autoDispose<DailyAyah>((ref) {
  return ref.watch(quranRepositoryProvider).getDailyAyah(DateTime.now());
});

class LastRead {
  final int surah;
  final int ayah;
  const LastRead(this.surah, this.ayah);
}

class QuranProgress {
  final LastRead? lastRead;
  final Set<String> bookmarks; // "surah:ayah"
  const QuranProgress({this.lastRead, this.bookmarks = const <String>{}});
}

class QuranProgressNotifier extends Notifier<QuranProgress> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  QuranProgress build() {
    final p = ref.watch(sharedPrefsProvider);
    LastRead? last;
    final raw = p.getString(AppConstants.kLastRead);
    if (raw != null) {
      final parts = raw.split(':');
      if (parts.length == 2) {
        final s = int.tryParse(parts[0]);
        final a = int.tryParse(parts[1]);
        if (s != null && a != null) last = LastRead(s, a);
      }
    }
    final marks = p.getStringList(AppConstants.kBookmarks) ?? const <String>[];
    return QuranProgress(lastRead: last, bookmarks: marks.toSet());
  }

  void setLastRead(int surah, int ayah) {
    state = QuranProgress(lastRead: LastRead(surah, ayah), bookmarks: state.bookmarks);
    _prefs.setString(AppConstants.kLastRead, '$surah:$ayah');
  }

  bool isBookmarked(int surah, int ayah) =>
      state.bookmarks.contains('$surah:$ayah');

  void toggleBookmark(int surah, int ayah) {
    final key = '$surah:$ayah';
    final next = {...state.bookmarks};
    if (!next.add(key)) next.remove(key);
    _saveBookmarks(next);
  }

  void removeBookmark(String key) {
    final next = {...state.bookmarks}..remove(key);
    _saveBookmarks(next);
  }

  void _saveBookmarks(Set<String> next) {
    state = QuranProgress(lastRead: state.lastRead, bookmarks: next);
    _prefs.setStringList(AppConstants.kBookmarks, next.toList());
  }
}

final quranProgressProvider =
    NotifierProvider<QuranProgressNotifier, QuranProgress>(
  QuranProgressNotifier.new,
);
