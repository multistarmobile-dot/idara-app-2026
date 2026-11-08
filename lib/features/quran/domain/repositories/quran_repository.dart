import '../entities/ayah.dart';

abstract class QuranRepository {
  /// [translations]: QuranEdition identifiers jo Arabic ke saath chahiye.
  Future<List<Ayah>> getSurah(int number, List<String> translations);
  Future<List<Ayah>> getPara(int number, List<String> translations);
  Future<DailyAyah> getDailyAyah(DateTime date);

  /// [reference]: "surah:ayah" (masalan "2:201"). Arabic + Urdu (Kanzul Iman).
  Future<DailyAyah> getAyahByReference(String reference);

  /// Ayat ke mp3 links (surah ki tilawat).
  Future<List<AyahAudio>> getSurahAudio(int surah);
}
