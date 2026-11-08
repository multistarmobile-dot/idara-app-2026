import 'dart:convert';

import 'package:http/http.dart' as http;

/// AlQuran Cloud API (https://alquran.cloud) — verified Quran text source.
class QuranRemoteDataSource {
  static const String _base = 'https://api.alquran.cloud/v1';
  final http.Client _client;

  QuranRemoteDataSource({http.Client? client})
      : _client = client ?? http.Client();

  Future<Map<String, dynamic>> _getData(String path) async {
    final res = await _client
        .get(Uri.parse('$_base$path'))
        .timeout(const Duration(seconds: 30));
    if (res.statusCode != 200) {
      throw Exception('Quran server error ${res.statusCode} for $path');
    }
    final json = jsonDecode(utf8.decode(res.bodyBytes));
    if (json is! Map<String, dynamic>) throw Exception('Bad response');
    final data = json['data'];
    if (data is! Map<String, dynamic>) throw Exception('Bad data');
    return data;
  }

  List<Map<String, dynamic>> _ayahs(Map<String, dynamic> data) {
    final ayahs = data['ayahs'];
    if (ayahs is! List) throw Exception('Bad ayahs');
    return ayahs.map((e) => e as Map<String, dynamic>).toList();
  }

  Future<List<Map<String, dynamic>>> surahAyahs(int surah, String edition) async =>
      _ayahs(await _getData('/surah/$surah/$edition'));

  Future<List<Map<String, dynamic>>> paraAyahs(int para, String edition) async =>
      _ayahs(await _getData('/juz/$para/$edition'));

  /// Surah ki ayat ki audio (har ayat ka mp3 link). Reciter: ar.alafasy.
  Future<List<Map<String, dynamic>>> surahAudio(int surah, String edition) async =>
      _ayahs(await _getData('/surah/$surah/$edition'));

  /// [reference]: "surah:ayah", masalan "2:201".
  Future<Map<String, dynamic>> ayahByReference(String reference, String edition) =>
      _getData('/ayah/$reference/$edition');

  /// [globalNumber]: 1 se 6236 tak.
  Future<Map<String, dynamic>> ayah(int globalNumber, String edition) =>
      _getData('/ayah/$globalNumber/$edition');
}
