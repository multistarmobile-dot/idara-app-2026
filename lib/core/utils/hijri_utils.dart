class HijriDate {
  final int year;
  final int month;
  final int day;
  const HijriDate(this.year, this.month, this.day);
}

const List<String> hijriMonths = [
  'محرم الحرام',
  'صفر المظفر',
  'ربیع الاول',
  'ربیع الثانی',
  'جمادی الاولیٰ',
  'جمادی الثانیہ',
  'رجب المرجب',
  'شعبان المعظم',
  'رمضان المبارک',
  'شوال المکرم',
  'ذوالقعدہ',
  'ذوالحجہ',
];

const List<String> urduWeekdays = [
  'پیر',
  'منگل',
  'بدھ',
  'جمعرات',
  'جمعہ',
  'ہفتہ',
  'اتوار',
];

const List<String> urduMonths = [
  'جنوری',
  'فروری',
  'مارچ',
  'اپریل',
  'مئی',
  'جون',
  'جولائی',
  'اگست',
  'ستمبر',
  'اکتوبر',
  'نومبر',
  'دسمبر',
];

/// Tabular (civil) Hijri conversion. Pakistan mein rooyat-e-hilal se 1 din ka
/// farq ho sakta hai, isliye offset (-1/0/+1) settings mein maujood hai.
HijriDate gregorianToHijri(DateTime date, {int offset = 0}) {
  final d =
      DateTime(date.year, date.month, date.day).add(Duration(days: offset));
  final a = (14 - d.month) ~/ 12;
  final y = d.year + 4800 - a;
  final m = d.month + 12 * a - 3;
  final jd = d.day +
      (153 * m + 2) ~/ 5 +
      365 * y +
      y ~/ 4 -
      y ~/ 100 +
      y ~/ 400 -
      32045;

  int l = jd - 1948440 + 10632;
  final n = (l - 1) ~/ 10631;
  l = l - 10631 * n + 354;
  final j = ((10985 - l) ~/ 5316) * ((50 * l) ~/ 17719) +
      (l ~/ 5670) * ((43 * l) ~/ 15238);
  l = l -
      ((30 - j) ~/ 15) * ((17719 * j) ~/ 50) -
      (j ~/ 16) * ((15238 * j) ~/ 43) +
      29;
  final month = (24 * l) ~/ 709;
  final day = l - (709 * month) ~/ 24;
  final year = 30 * n + j - 30;
  return HijriDate(year, month, day);
}

String hijriText(DateTime date, {int offset = 0}) {
  final h = gregorianToHijri(date, offset: offset);
  final idx = (h.month < 1 ? 1 : (h.month > 12 ? 12 : h.month)) - 1;
  return '${h.day} ${hijriMonths[idx]} ${h.year} ھ';
}

String gregorianText(DateTime d) {
  return '${urduWeekdays[d.weekday - 1]}، ${d.day} ${urduMonths[d.month - 1]} ${d.year}';
}
