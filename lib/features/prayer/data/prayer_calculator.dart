import 'package:adhan/adhan.dart';

import '../domain/entities/prayer_models.dart';

/// Karachi calculation method + Hanafi Asr.
class PrayerCalculator {
  static PrayerDay forDate(
    PrayerLocation location,
    DateTime date,
    Map<String, int> adjustments,
  ) {
    final params = CalculationMethod.karachi.getParameters();
    params.madhab = Madhab.hanafi;

    final times = PrayerTimes(
      Coordinates(location.latitude, location.longitude),
      DateComponents.from(date),
      params,
    );

    DateTime adj(PrayerKind kind, DateTime raw) =>
        raw.toLocal().add(Duration(minutes: adjustments[kind.name] ?? 0));

    return PrayerDay(
      DateTime(date.year, date.month, date.day),
      [
        PrayerEntry(PrayerKind.fajr, adj(PrayerKind.fajr, times.fajr)),
        PrayerEntry(PrayerKind.sunrise, adj(PrayerKind.sunrise, times.sunrise)),
        PrayerEntry(PrayerKind.dhuhr, adj(PrayerKind.dhuhr, times.dhuhr)),
        PrayerEntry(PrayerKind.asr, adj(PrayerKind.asr, times.asr)),
        PrayerEntry(PrayerKind.maghrib, adj(PrayerKind.maghrib, times.maghrib)),
        PrayerEntry(PrayerKind.isha, adj(PrayerKind.isha, times.isha)),
      ],
    );
  }

  static NextPrayer next(
    PrayerLocation location,
    DateTime now,
    Map<String, int> adjustments,
  ) {
    final today = forDate(location, now, adjustments).prayers;
    for (final e in today) {
      if (e.time.isAfter(now)) return NextPrayer(e, e.time.difference(now));
    }
    final tomorrow = forDate(
      location,
      DateTime(now.year, now.month, now.day + 1),
      adjustments,
    ).prayers;
    final e = tomorrow.first;
    return NextPrayer(e, e.time.difference(now));
  }

  static String formatTime(DateTime t) {
    final hour = t.hour % 12 == 0 ? 12 : t.hour % 12;
    final minute = t.minute.toString().padLeft(2, '0');
    final period = t.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  static String formatDuration(Duration d) {
    final safe = d.isNegative ? Duration.zero : d;
    final h = safe.inHours.toString().padLeft(2, '0');
    final m = safe.inMinutes.remainder(60).toString().padLeft(2, '0');
    final s = safe.inSeconds.remainder(60).toString().padLeft(2, '0');
    return '$h:$m:$s';
  }
}
