import 'package:flutter_test/flutter_test.dart';
import 'package:idara_khair_ul_ibad/core/utils/hijri_utils.dart';

void main() {
  test('Gregorian to Hijri known dates', () {
    var h = gregorianToHijri(DateTime(2026, 6, 17));
    expect([h.year, h.month, h.day], [1448, 1, 1]);

    h = gregorianToHijri(DateTime(2025, 3, 1));
    expect([h.year, h.month, h.day], [1446, 9, 1]);

    h = gregorianToHijri(DateTime(2024, 4, 10));
    expect([h.year, h.month, h.day], [1445, 10, 1]);
  });

  test('Hijri offset shifts one day', () {
    final h = gregorianToHijri(DateTime(2026, 6, 16), offset: 1);
    expect([h.year, h.month, h.day], [1448, 1, 1]);
  });
}
