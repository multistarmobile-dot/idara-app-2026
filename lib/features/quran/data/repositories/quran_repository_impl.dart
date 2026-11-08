import 'dart:convert';

import '../../domain/entities/ayah.dart';
import '../../domain/repositories/quran_repository.dart';
import '../datasources/quran_cache.dart';
import '../datasources/quran_remote_datasource.dart';
import '../quran_text_utils.dart';

class _Raw {
  final int surah;
  final int number;
  final String text;
  const _Raw(this.surah, this.number, this.text);
}

class QuranRepositoryImpl implements QuranRepository {
  final QuranRemoteDataSource _remote;
  final QuranCache _cache;

  QuranRepositoryImpl(this._remote, this._cache);

  @override
  Future<List<Ayah>> getSurah(int number, List<String> translations) async {
    final arabic = await _edition(
      'surah_${number}_${QuranEdition.arabic}',
      () => _remote.surahAyahs(number, QuranEdition.arabic),
      number,
      isArabic: true,
    );
    final trans = <String, List<_Raw>>{};
    for (final e in translations) {
      try {
        trans[e] = await _edition(
          'surah_${number}_$e',
          () => _remote.surahAyahs(number, e),
          number,
        );
      } catch (_) {
        // Tarjuma na mile to Arabic phir bhi dikhaya jayega.
      }
    }
    return _merge(arabic, trans);
  }

  @override
  Future<List<Ayah>> getPara(int number, List<String> translations) async {
    final arabic = await _edition(
      'para_${number}_${QuranEdition.arabic}',
      () => _remote.paraAyahs(number, QuranEdition.arabic),
      0,
      isArabic: true,
    );
    final trans = <String, List<_Raw>>{};
    for (final e in translations) {
      try {
        trans[e] = await _edition(
          'para_${number}_$e',
          () => _remote.paraAyahs(number, e),
          0,
        );
      } catch (_) {}
    }
    return _merge(arabic, trans);
  }

  @override
  Future<DailyAyah> getDailyAyah(DateTime date) async {
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    final n = ((dayOfYear * 97 + date.year) % 6236) + 1;
    final key = 'daily_${date.year}_$dayOfYear';

    final cached = await _cache.read(key);
    if (cached != null) {
      try {
        final m = jsonDecode(cached) as Map<String, dynamic>;
        return DailyAyah(
          surah: (m['s'] as num).toInt(),
          number: (m['n'] as num).toInt(),
          arabic: m['a'] as String,
          urdu: m['u'] as String,
        );
      } catch (_) {}
    }

    final a = await _remote.ayah(n, QuranEdition.arabic);
    final u = await _remote.ayah(n, QuranEdition.urdu);
    final info = a['surah'];
    final surahNo = info is Map ? (info['number'] as num).toInt() : 1;
    final inSurah = (a['numberInSurah'] as num).toInt();
    var arabic = (a['text'] as String).trim();
    if (inSurah == 1 && surahNo != 1 && surahNo != 9) {
      arabic = stripBismillah(arabic);
    }
    final urdu = (u['text'] as String).trim();

    await _cache.write(
      key,
      jsonEncode({'s': surahNo, 'n': inSurah, 'a': arabic, 'u': urdu}),
    );
    return DailyAyah(surah: surahNo, number: inSurah, arabic: arabic, urdu: urdu);
  }

  @override
  Future<DailyAyah> getAyahByReference(String reference) async {
    final key = 'ref_${reference.replaceAll(':', '_')}';
    final cached = await _cache.read(key);
    if (cached != null) {
      try {
        final m = jsonDecode(cached) as Map<String, dynamic>;
        return DailyAyah(
          surah: (m['s'] as num).toInt(),
          number: (m['n'] as num).toInt(),
          arabic: m['a'] as String,
          urdu: m['u'] as String,
        );
      } catch (_) {}
    }
    final a = await _remote.ayahByReference(reference, QuranEdition.arabic);
    final u = await _remote.ayahByReference(reference, QuranEdition.urdu);
    final info = a['surah'];
    final surahNo = info is Map ? (info['number'] as num).toInt() : 1;
    final inSurah = (a['numberInSurah'] as num).toInt();
    var arabic = (a['text'] as String).trim();
    if (inSurah == 1 && surahNo != 1 && surahNo != 9) {
      arabic = stripBismillah(arabic);
    }
    final urdu = (u['text'] as String).trim();
    await _cache.write(
      key,
      jsonEncode({'s': surahNo, 'n': inSurah, 'a': arabic, 'u': urdu}),
    );
    return DailyAyah(surah: surahNo, number: inSurah, arabic: arabic, urdu: urdu);
  }

  @override
  Future<List<AyahAudio>> getSurahAudio(int surah) async {
    final key = 'audio_${surah}_${QuranEdition.audioReciter}';
    final cached = await _cache.read(key);
    if (cached != null) {
      try {
        final list = jsonDecode(cached) as List<dynamic>;
        final out = list
            .map((e) => AyahAudio((e['n'] as num).toInt(), e['u'] as String))
            .toList();
        if (out.isNotEmpty) return out;
      } catch (_) {}
    }
    final raw = await _remote.surahAudio(surah, QuranEdition.audioReciter);
    final rows = <Map<String, dynamic>>[];
    for (final a in raw) {
      final url = a['audio'];
      if (url is String && url.isNotEmpty) {
        rows.add({'n': (a['numberInSurah'] as num).toInt(), 'u': url});
      }
    }
    if (rows.isEmpty) throw Exception('No audio for surah $surah');
    await _cache.write(key, jsonEncode(rows));
    return rows.map((e) => AyahAudio(e['n'] as int, e['u'] as String)).toList();
  }

  Future<List<_Raw>> _edition(
    String cacheKey,
    Future<List<Map<String, dynamic>>> Function() fetch,
    int fallbackSurah, {
    bool isArabic = false,
  }) async {
    final cached = await _cache.read(cacheKey);
    if (cached != null) {
      try {
        final rows = _decode(cached);
        if (rows.isNotEmpty) return rows;
      } catch (_) {}
    }

    final raw = await fetch();
    final out = <Map<String, dynamic>>[];
    for (final a in raw) {
      final info = a['surah'];
      final surahNo =
          info is Map ? (info['number'] as num).toInt() : fallbackSurah;
      final no = (a['numberInSurah'] as num).toInt();
      var text = (a['text'] as String).trim();
      if (isArabic && no == 1 && surahNo != 1 && surahNo != 9) {
        text = stripBismillah(text);
      }
      out.add({'s': surahNo, 'n': no, 't': text});
    }
    final encoded = jsonEncode(out);
    await _cache.write(cacheKey, encoded);
    return _decode(encoded);
  }

  List<_Raw> _decode(String source) {
    final list = jsonDecode(source) as List<dynamic>;
    return list.map((e) {
      final m = e as Map<String, dynamic>;
      return _Raw((m['s'] as num).toInt(), (m['n'] as num).toInt(), m['t'] as String);
    }).toList();
  }

  List<Ayah> _merge(List<_Raw> arabic, Map<String, List<_Raw>> trans) {
    final result = <Ayah>[];
    for (int i = 0; i < arabic.length; i++) {
      final a = arabic[i];
      final t = <String, String>{};
      trans.forEach((edition, rows) {
        if (rows.length == arabic.length) t[edition] = rows[i].text;
      });
      result.add(
        Ayah(surah: a.surah, number: a.number, arabic: a.text, translations: t),
      );
    }
    return result;
  }
}
