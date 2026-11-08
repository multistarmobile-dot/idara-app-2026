import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:idara_khair_ul_ibad/core/services/file_cache.dart';
import 'package:idara_khair_ul_ibad/features/hadith/data/hadith_repository.dart';
import 'package:idara_khair_ul_ibad/features/hadith/domain/hadith_models.dart';

// Asli hadith-api JSON jaisa structure (metadata + hadiths + grades + reference).
Map<String, dynamic> _sample(String text) => {
      'metadata': {
        'name': 'Sunan Abu Dawud',
        'section': {'1': 'Purification (Kitab Al-Taharah)'},
      },
      'hadiths': [
        {
          'hadithnumber': 10,
          'arabicnumber': 10,
          'text': text,
          'grades': [
            {'name': 'Al-Albani', 'grade': 'Daif'},
            {'name': 'Shuaib Al Arnaut', 'grade': 'Daif'},
          ],
          'reference': {'book': 1, 'hadith': 10},
        },
      ],
    };

void main() {
  test('HadithRepository parses section JSON (Arabic + translation + grades)', () async {
    final client = MockClient((http.Request req) async {
      final isArabic = req.url.path.contains('ara-abudawud');
      final body = jsonEncode(_sample(isArabic ? 'نص عربي' : 'Narrated Maqil: sample'));
      return http.Response(body, 200, headers: {'content-type': 'application/json; charset=utf-8'});
    });

    final repo = HadithRepository(FileCache(), client: client);
    final section = await repo.getSection('abudawud', 1, HadithLang.english);

    expect(section.items.length, 1);
    final h = section.items.first;
    expect(h.number, 10);
    expect(h.arabic, 'نص عربي');
    expect(h.translation, 'Narrated Maqil: sample');
    expect(h.grades.length, 2);
    expect(h.grades.first.gradeUrdu, 'ضعیف');
    expect(h.book, 1);
    expect(section.title, 'Purification (Kitab Al-Taharah)');
  });

  test('HadithRepository falls back to Arabic only if translation fails', () async {
    final client = MockClient((http.Request req) async {
      if (req.url.path.contains('ara-')) {
        return http.Response(jsonEncode(_sample('نص عربي')), 200);
      }
      return http.Response('not found', 404);
    });
    final repo = HadithRepository(FileCache(), client: client);
    final section = await repo.getSection('abudawud', 1, HadithLang.urdu);
    expect(section.items.first.translation, isNull);
    expect(section.items.first.arabic, 'نص عربي');
  });
}
