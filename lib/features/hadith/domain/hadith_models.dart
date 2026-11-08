class HadithGrade {
  final String scholar;
  final String grade;
  const HadithGrade(this.scholar, this.grade);

  /// Aam darjon ka Urdu naam; baqi jaisa hai waisa.
  String get gradeUrdu {
    final g = grade.toLowerCase();
    if (g.contains('sahih')) return 'صحیح';
    if (g.contains('hasan')) return 'حسن';
    if (g.contains('daif') || g.contains('weak')) return 'ضعیف';
    return grade;
  }
}

class HadithItem {
  final int number;
  final String arabic;
  final String? translation;
  final List<HadithGrade> grades;
  final int? book;
  final int? inBook;
  const HadithItem({
    required this.number,
    required this.arabic,
    this.translation,
    this.grades = const <HadithGrade>[],
    this.book,
    this.inBook,
  });
}

class HadithSection {
  final String title;
  final List<HadithItem> items;
  const HadithSection(this.title, this.items);
}

class HadithCollection {
  final String id; // API ke mutabiq: bukhari, muslim ...
  final String nameUrdu;
  const HadithCollection(this.id, this.nameUrdu);
}

const List<HadithCollection> hadithCollections = [
  HadithCollection('bukhari', 'صحیح بخاری'),
  HadithCollection('muslim', 'صحیح مسلم'),
  HadithCollection('abudawud', 'سنن ابی داود'),
  HadithCollection('tirmidhi', 'جامع ترمذی'),
  HadithCollection('nasai', 'سنن نسائی'),
  HadithCollection('ibnmajah', 'سنن ابن ماجہ'),
];

enum HadithLang {
  urdu('urd', 'اردو'),
  english('eng', 'English');

  final String code;
  final String label;
  const HadithLang(this.code, this.label);
}

class DailyHadith {
  final HadithItem item;
  final String collectionName;
  const DailyHadith(this.item, this.collectionName);
}
