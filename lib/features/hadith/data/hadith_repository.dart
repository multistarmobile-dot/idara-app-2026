import 'dart:convert';

import 'package:http/http.dart' as http;

import '../../../core/services/file_cache.dart';
import '../domain/hadith_models.dart';

/// Hadith data: fawazahmed0/hadith-api (jsDelivr CDN). Matn aur tarjuma ap mein hath se nahi likha gaya.
class HadithRepository {
  static const String _base = 'https://cdn.jsdelivr.net/gh/fawazahmed0/hadith-api@1';
  final FileCache _cache;
  final http.Client _client;

  HadithRepository(this._cache, {http.Client? client}) : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _fetchJson(String cacheKey, String path) async {
    final cached = await _cache.read(cacheKey);
    if (cached != null) {
      try {
        final j = jsonDecode(cached);
        if (j is Map<String, dynamic>) return j;
      } catch (_) {}
    }
    Object? lastError;
    for (final suffix in const ['.min.json', '.json']) {
      try {
        final res = await _client
            .get(Uri.parse('$_base$path$suffix'))
            .timeout(const Duration(seconds: 30));
        if (res.statusCode == 200) {
          final body = utf8.decode(res.bodyBytes);
          final j = jsonDecode(body);
          if (j is Map<String, dynamic>) {
            await _cache.write(cacheKey, body);
            return j;
          }
        } else {
          lastError = 'HTTP ${res.statusCode}';
        }
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Hadith fetch failed: $lastError');
  }

  List<Map<String, dynamic>> _hadithMaps(Map<String, dynamic> json) {
    final list = json['hadiths'];
    if (list is List) {
      return list.whereType<Map>().map((m) => Map<String, dynamic>.from(m)).toList();
    }
    if (json['text'] != null) return [json];
    return const <Map<String, dynamic>>[];
  }

  int? _int(dynamic v) => v is num ? v.toInt() : int.tryParse('${v ?? ''}');

  String? _sectionTitle(Map<String, dynamic> json) {
    final meta = json['metadata'];
    if (meta is Map) {
      final sec = meta['section'];
      if (sec is Map && sec.isNotEmpty) {
        final v = sec.values.first;
        if (v is String && v.trim().isNotEmpty) return v.trim();
      }
    }
    return null;
  }

  List<HadithGrade> _grades(Map<String, dynamic> m) {
    final g = m['grades'];
    if (g is! List) return const <HadithGrade>[];
    return g
        .whereType<Map>()
        .map((e) => HadithGrade('${e['name'] ?? ''}'.trim(), '${e['grade'] ?? ''}'.trim()))
        .where((e) => e.grade.isNotEmpty)
        .toList();
  }

  HadithItem _item(Map<String, dynamic> arabic, Map<String, dynamic>? translation) {
    final ref = arabic['reference'];
    var grades = _grades(arabic);
    if (grades.isEmpty && translation != null) grades = _grades(translation);
    final t = translation == null ? null : '${translation['text'] ?? ''}'.trim();
    return HadithItem(
      number: _int(arabic['hadithnumber']) ?? 0,
      arabic: '${arabic['text'] ?? ''}'.trim(),
      translation: (t == null || t.isEmpty) ? null : t,
      grades: grades,
      book: ref is Map ? _int(ref['book']) : null,
      inBook: ref is Map ? _int(ref['hadith']) : null,
    );
  }

  /// Kitab (section) ki saari ahadees: Arabic + chuna hua tarjuma.
  Future<HadithSection> getSection(String collection, int section, HadithLang lang) async {
    final ara = await _fetchJson(
      'h_ara_${collection}_s$section',
      '/editions/ara-$collection/sections/$section',
    );
    final araItems = _hadithMaps(ara);
    if (araItems.isEmpty) throw Exception('Empty section');

    final trans = <int, Map<String, dynamic>>{};
    String? tTitle;
    try {
      final t = await _fetchJson(
        'h_${lang.code}_${collection}_s$section',
        '/editions/${lang.code}-$collection/sections/$section',
      );
      for (final m in _hadithMaps(t)) {
        final n = _int(m['hadithnumber']);
        if (n != null) trans[n] = m;
      }
      tTitle = _sectionTitle(t);
    } catch (_) {
      // Tarjuma na mile to sirf Arabic dikhaya jayega.
    }

    final items = araItems.map((m) => _item(m, trans[_int(m['hadithnumber'])])).toList();
    return HadithSection(tTitle ?? _sectionTitle(ara) ?? 'باب $section', items);
  }

  Future<HadithItem> getSingle(String collection, int number, HadithLang lang) async {
    final ara = await _fetchJson('h_ara_${collection}_$number', '/editions/ara-$collection/$number');
    final araList = _hadithMaps(ara);
    if (araList.isEmpty) throw Exception('Empty hadith');
    Map<String, dynamic>? t;
    try {
      final tj = await _fetchJson(
        'h_${lang.code}_${collection}_$number',
        '/editions/${lang.code}-$collection/$number',
      );
      final l = _hadithMaps(tj);
      if (l.isNotEmpty) t = l.first;
    } catch (_) {}
    return _item(araList.first, t);
  }

  /// Aaj ki hadith (Sahih Bukhari se). Koi number maujood na ho to agla try hota hai.
  Future<DailyHadith> getDaily(DateTime date) async {
    const collection = 'bukhari';
    final dayOfYear = date.difference(DateTime(date.year)).inDays + 1;
    final start = ((dayOfYear * 37 + date.year) % 6900) + 1;

    Object? lastError;
    for (int i = 0; i < 6; i++) {
      try {
        final item = await getSingle(collection, start + i, HadithLang.urdu);
        return DailyHadith(item, 'صحیح بخاری');
      } catch (e) {
        lastError = e;
      }
    }
    throw Exception('Daily hadith failed: $lastError');
  }
}
