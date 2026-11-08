/// Quran ke edition identifiers (AlQuran Cloud).
class QuranEdition {
  static const String arabic = 'quran-uthmani';

  /// کنز الایمان — امام احمد رضا خان بریلوی (اہلِ سنت)
  static const String urdu = 'ur.kanzuliman';

  /// Ahmed Raza Khan — English rendering of Kanzul Iman.
  static const String english = 'en.ahmedraza';

  /// Qari: Mishary Rashid Alafasy
  static const String audioReciter = 'ar.alafasy';
}

class Ayah {
  final int surah;
  final int number;
  final String arabic;

  /// edition identifier -> translation text
  final Map<String, String> translations;

  const Ayah({
    required this.surah,
    required this.number,
    required this.arabic,
    this.translations = const <String, String>{},
  });
}

class DailyAyah {
  final int surah;
  final int number;
  final String arabic;
  final String urdu;
  const DailyAyah({
    required this.surah,
    required this.number,
    required this.arabic,
    required this.urdu,
  });
}

class AyahAudio {
  final int number;
  final String url;
  const AyahAudio(this.number, this.url);
}
