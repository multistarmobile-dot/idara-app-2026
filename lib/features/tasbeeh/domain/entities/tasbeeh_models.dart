class TasbeehItem {
  final String id;
  final String text;
  final int target;
  final bool custom;
  const TasbeehItem({
    required this.id,
    required this.text,
    required this.target,
    this.custom = false,
  });

  Map<String, dynamic> toJson() => {'id': id, 'text': text, 'target': target};

  factory TasbeehItem.fromJson(Map<String, dynamic> j) => TasbeehItem(
        id: j['id'] as String,
        text: j['text'] as String,
        target: (j['target'] as num).toInt(),
        custom: true,
      );
}

const List<TasbeehItem> defaultTasbeehItems = [
  TasbeehItem(id: 'subhanallah', text: 'سُبْحَانَ اللّٰهِ', target: 33),
  TasbeehItem(id: 'alhamdulillah', text: 'اَلْحَمْدُ لِلّٰهِ', target: 33),
  TasbeehItem(id: 'allahuakbar', text: 'اَللّٰهُ اَكْبَرُ', target: 34),
  TasbeehItem(id: 'durood', text: 'صَلَّى اللّٰهُ عَلَيْهِ وَسَلَّمَ', target: 100),
];

class TasbeehState {
  final String selectedId;
  final Map<String, int> counts; // current round count per item
  final Map<String, int> rounds; // completed rounds per item
  final Map<String, int> history; // yyyy-MM-dd -> total taps
  final int dailyTarget;
  final bool vibrate;
  final List<TasbeehItem> customs;

  const TasbeehState({
    required this.selectedId,
    required this.counts,
    required this.rounds,
    required this.history,
    required this.dailyTarget,
    required this.vibrate,
    required this.customs,
  });

  List<TasbeehItem> get items => [...defaultTasbeehItems, ...customs];

  TasbeehItem get selected => items.firstWhere(
        (i) => i.id == selectedId,
        orElse: () => defaultTasbeehItems.first,
      );

  static String dateKey(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  int get todayTotal => history[dateKey(DateTime.now())] ?? 0;

  TasbeehState copyWith({
    String? selectedId,
    Map<String, int>? counts,
    Map<String, int>? rounds,
    Map<String, int>? history,
    int? dailyTarget,
    bool? vibrate,
    List<TasbeehItem>? customs,
  }) {
    return TasbeehState(
      selectedId: selectedId ?? this.selectedId,
      counts: counts ?? this.counts,
      rounds: rounds ?? this.rounds,
      history: history ?? this.history,
      dailyTarget: dailyTarget ?? this.dailyTarget,
      vibrate: vibrate ?? this.vibrate,
      customs: customs ?? this.customs,
    );
  }

  static TasbeehState initial() => const TasbeehState(
        selectedId: 'subhanallah',
        counts: <String, int>{},
        rounds: <String, int>{},
        history: <String, int>{},
        dailyTarget: 100,
        vibrate: true,
        customs: <TasbeehItem>[],
      );
}
