class IslamicEvent {
  final int month;
  final int day;
  final String title;
  const IslamicEvent(this.month, this.day, this.title);
}

/// Mashhoor islami tareekhein (hisabi). Chand ki rooyat se 1 din ka farq ho sakta hai.
const List<IslamicEvent> islamicEvents = [
  IslamicEvent(1, 1, 'اسلامی سال کا آغاز (یکم محرم)'),
  IslamicEvent(1, 10, 'یومِ عاشورہ (10 محرم)'),
  IslamicEvent(3, 12, '12 ربیع الاول'),
  IslamicEvent(7, 27, '27 رجب (شبِ معراج)'),
  IslamicEvent(8, 15, '15 شعبان (شبِ برات)'),
  IslamicEvent(9, 1, 'رمضان المبارک کا آغاز'),
  IslamicEvent(9, 27, '27 رمضان المبارک'),
  IslamicEvent(10, 1, 'عید الفطر'),
  IslamicEvent(12, 9, 'یومِ عرفہ'),
  IslamicEvent(12, 10, 'عید الاضحیٰ'),
];
