final RegExp _diacritics =
    RegExp(r'[\u064B-\u065F\u0670\u06D6-\u06ED\u0640]');

/// Kuch editions mein har surah ki pehli ayat ke saath Bismillah judi hoti hai.
/// Usay alag sarkhi ke taur par dikhate hain, is liye ayat se hata dete hain.
String stripBismillah(String text) {
  final words = text.trim().split(RegExp(r'\s+'));
  if (words.length < 5) return text.trim();
  final first = words.first.replaceAll(_diacritics, '');
  if (first != 'بسم') return text.trim();
  return words.sublist(4).join(' ');
}
