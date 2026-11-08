import 'package:flutter_test/flutter_test.dart';
import 'package:idara_khair_ul_ibad/features/qibla/domain/qibla_calculator.dart';

void main() {
  test('Qibla bearing from Lahore', () {
    expect(QiblaCalculator.bearing(31.5204, 74.3587), closeTo(260.4, 0.5));
  });

  test('Distance Lahore to Kaaba (km)', () {
    expect(QiblaCalculator.distanceKm(31.5204, 74.3587), closeTo(3598, 15));
  });
}
