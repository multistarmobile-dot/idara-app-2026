import '../domain/entities/prayer_models.dart';

class PakistanCity {
  final String name;
  final double latitude;
  final double longitude;
  const PakistanCity(this.name, this.latitude, this.longitude);
}

/// Shehron ke markaz ke taqreebi coordinates.
class PakistanCities {
  static const List<PakistanCity> all = [
    PakistanCity('لاہور', 31.5204, 74.3587),
    PakistanCity('کراچی', 24.8607, 67.0011),
    PakistanCity('اسلام آباد', 33.6844, 73.0479),
    PakistanCity('راولپنڈی', 33.5651, 73.0169),
    PakistanCity('فیصل آباد', 31.4504, 73.1350),
    PakistanCity('ملتان', 30.1575, 71.5249),
    PakistanCity('پشاور', 34.0151, 71.5249),
    PakistanCity('کوئٹہ', 30.1798, 66.9750),
    PakistanCity('گوجرانوالہ', 32.1877, 74.1945),
    PakistanCity('سیالکوٹ', 32.4945, 74.5229),
    PakistanCity('حیدرآباد', 25.3960, 68.3578),
    PakistanCity('بہاولپور', 29.3956, 71.6836),
    PakistanCity('سرگودھا', 32.0836, 72.6711),
    PakistanCity('مظفرآباد', 34.3700, 73.4711),
    PakistanCity('گلگت', 35.9208, 74.3144),
    PakistanCity('سکھر', 27.7052, 68.8574),
    PakistanCity('مردان', 34.1989, 72.0231),
    PakistanCity('ایبٹ آباد', 34.1688, 73.2215),
    PakistanCity('ساہیوال', 30.6682, 73.1114),
    PakistanCity('جھنگ', 31.2681, 72.3181),
    PakistanCity('رحیم یار خان', 28.4202, 70.2952),
    PakistanCity('قصور', 31.1156, 74.4467),
    PakistanCity('اوکاڑہ', 30.8138, 73.4534),
    PakistanCity('شیخوپورہ', 31.7167, 73.9850),
    PakistanCity('ڈیرہ غازی خان', 30.0561, 70.6348),
    PakistanCity('لاڑکانہ', 27.5570, 68.2028),
    PakistanCity('میرپور خاص', 25.5251, 69.0159),
    PakistanCity('مینگورہ (سوات)', 34.7717, 72.3600),
    PakistanCity('کوہاٹ', 33.5869, 71.4414),
    PakistanCity('بنوں', 32.9889, 70.6056),
    PakistanCity('گوادر', 25.1264, 62.3225),
    PakistanCity('جہلم', 32.9425, 73.7257),
    PakistanCity('گجرات', 32.5731, 74.0789),
    PakistanCity('اسکردو', 35.2971, 75.6333),
  ];

  static const PrayerLocation defaultLocation = PrayerLocation(
    name: 'لاہور',
    latitude: 31.5204,
    longitude: 74.3587,
  );
}
