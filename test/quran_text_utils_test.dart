import 'package:flutter_test/flutter_test.dart';
import 'package:idara_khair_ul_ibad/features/quran/data/quran_metadata.dart';
import 'package:idara_khair_ul_ibad/features/quran/data/quran_text_utils.dart';

void main() {
  test('stripBismillah removes leading Bismillah (4 words)', () {
    const input = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ الٓمٓ';
    expect(stripBismillah(input), 'الٓمٓ');
  });

  test('stripBismillah leaves other text unchanged', () {
    const input = 'قُلْ هُوَ اللَّهُ أَحَدٌ اللَّهُ الصَّمَدُ';
    expect(stripBismillah(input), input);
  });

  test('Quran metadata: 114 surahs, 6236 ayat, 30 paras', () {
    expect(surahNames.length, 114);
    expect(surahAyahCounts.length, 114);
    expect(surahAyahCounts.reduce((a, b) => a + b), 6236);
    expect(paraNames.length, 30);
  });
}
