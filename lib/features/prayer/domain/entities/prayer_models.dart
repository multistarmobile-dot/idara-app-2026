enum PrayerKind { fajr, sunrise, dhuhr, asr, maghrib, isha }

extension PrayerKindX on PrayerKind {
  String get urdu {
    switch (this) {
      case PrayerKind.fajr:
        return 'فجر';
      case PrayerKind.sunrise:
        return 'طلوعِ آفتاب';
      case PrayerKind.dhuhr:
        return 'ظہر';
      case PrayerKind.asr:
        return 'عصر';
      case PrayerKind.maghrib:
        return 'مغرب';
      case PrayerKind.isha:
        return 'عشاء';
    }
  }

  /// Sunrise ek namaz nahi, sirf waqt ki nishani hai.
  bool get isPrayer => this != PrayerKind.sunrise;
}

class PrayerEntry {
  final PrayerKind kind;
  final DateTime time;
  const PrayerEntry(this.kind, this.time);
}

class PrayerDay {
  final DateTime date;
  final List<PrayerEntry> entries;
  const PrayerDay(this.date, this.entries);

  List<PrayerEntry> get prayers =>
      entries.where((e) => e.kind.isPrayer).toList();

  DateTime get sunrise =>
      entries.firstWhere((e) => e.kind == PrayerKind.sunrise).time;

  /// Maghrib ka waqt ghuroob-e-aftab hi hota hai.
  DateTime get sunset =>
      entries.firstWhere((e) => e.kind == PrayerKind.maghrib).time;
}

class NextPrayer {
  final PrayerEntry entry;
  final Duration remaining;
  const NextPrayer(this.entry, this.remaining);
}

class PrayerLocation {
  final String name;
  final double latitude;
  final double longitude;
  final bool isGps;
  const PrayerLocation({
    required this.name,
    required this.latitude,
    required this.longitude,
    this.isGps = false,
  });
}
