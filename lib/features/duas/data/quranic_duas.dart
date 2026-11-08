class QuranicDua {
  final String title;

  /// "surah:ayah" hawale. Matn aur tarjuma AlQuran Cloud se aata hai.
  final List<String> refs;
  const QuranicDua(this.title, this.refs);
}

/// Sirf hawalon ki fehrist hai; matn khud nahi likha gaya.
const List<QuranicDua> quranicDuas = [
  QuranicDua('دنیا اور آخرت کی بھلائی', ['2:201']),
  QuranicDua('دل کی ثابت قدمی', ['3:8']),
  QuranicDua('گناہوں کی معافی (حضرت آدم و حوا علیہما السلام)', ['7:23']),
  QuranicDua('والدین کے لیے دعا', ['17:24']),
  QuranicDua('علم میں اضافہ', ['20:114']),
  QuranicDua('سینے کی کشادگی (حضرت موسیٰ علیہ السلام)', ['20:25', '20:26', '20:27', '20:28']),
  QuranicDua('نماز قائم رکھنے کی دعا (حضرت ابراہیم علیہ السلام)', ['14:40']),
  QuranicDua('نیک بیوی اور اولاد کے لیے', ['25:74']),
  QuranicDua('اصحابِ کہف کی دعا', ['18:10']),
  QuranicDua('مغفرت اور رحمت', ['23:118']),
  QuranicDua('ایمان والے بھائیوں کے لیے دعا', ['59:10']),
  QuranicDua('حضرت یونس علیہ السلام کی دعا', ['21:87']),
  QuranicDua('حضرت موسیٰ علیہ السلام کی دعا', ['28:24']),
  QuranicDua('بھول چوک پر معافی کی دعا', ['2:286']),
];
