import 'dart:math' as math;

class QiblaCalculator {
  static const double kaabaLat = 21.4225;
  static const double kaabaLng = 39.8262;

  /// Shumal se gharri ki simt mein darjay (0-360).
  static double bearing(double lat, double lng) {
    final p1 = lat * math.pi / 180;
    final p2 = kaabaLat * math.pi / 180;
    final dl = (kaabaLng - lng) * math.pi / 180;
    final y = math.sin(dl) * math.cos(p2);
    final x = math.cos(p1) * math.sin(p2) -
        math.sin(p1) * math.cos(p2) * math.cos(dl);
    return (math.atan2(y, x) * 180 / math.pi + 360) % 360;
  }

  /// Kaaba tak fasla (km).
  static double distanceKm(double lat, double lng) {
    const r = 6371.0;
    final p1 = lat * math.pi / 180;
    final p2 = kaabaLat * math.pi / 180;
    final dphi = p2 - p1;
    final dl = (kaabaLng - lng) * math.pi / 180;
    final a = math.pow(math.sin(dphi / 2), 2) +
        math.cos(p1) * math.cos(p2) * math.pow(math.sin(dl / 2), 2);
    return 2 * r * math.asin(math.sqrt(a));
  }
}
