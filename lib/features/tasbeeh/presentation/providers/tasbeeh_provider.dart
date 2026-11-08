import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../domain/entities/tasbeeh_models.dart';

Map<String, int> _intMap(dynamic raw) {
  if (raw is! Map) return <String, int>{};
  return raw.map((k, v) => MapEntry('$k', (v as num).toInt()));
}

class TasbeehNotifier extends Notifier<TasbeehState> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  TasbeehState build() {
    final raw = ref.watch(sharedPrefsProvider).getString(AppConstants.kTasbeeh);
    if (raw == null) return TasbeehState.initial();
    try {
      final j = jsonDecode(raw) as Map<String, dynamic>;
      final customs = ((j['customs'] as List?) ?? const <dynamic>[])
          .map((e) => TasbeehItem.fromJson(e as Map<String, dynamic>))
          .toList();
      return TasbeehState(
        selectedId: (j['selected'] as String?) ?? 'subhanallah',
        counts: _intMap(j['counts']),
        rounds: _intMap(j['rounds']),
        history: _intMap(j['history']),
        dailyTarget: (j['daily'] as num?)?.toInt() ?? 100,
        vibrate: (j['vibrate'] as bool?) ?? true,
        customs: customs,
      );
    } catch (_) {
      return TasbeehState.initial();
    }
  }

  void _save() {
    // Sirf pichle 60 din ki history rakhte hain.
    final keys = state.history.keys.toList()..sort();
    final trimmed = <String, int>{};
    final start = keys.length > 60 ? keys.length - 60 : 0;
    for (final k in keys.sublist(start)) {
      trimmed[k] = state.history[k] ?? 0;
    }
    final data = {
      'selected': state.selectedId,
      'counts': state.counts,
      'rounds': state.rounds,
      'history': trimmed,
      'daily': state.dailyTarget,
      'vibrate': state.vibrate,
      'customs': state.customs.map((c) => c.toJson()).toList(),
    };
    _prefs.setString(AppConstants.kTasbeeh, jsonEncode(data));
  }

  /// true wapas aata hai jab ek poora daur mukammal ho.
  bool increment() {
    final item = state.selected;
    final counts = {...state.counts};
    final rounds = {...state.rounds};
    final history = {...state.history};

    var count = (counts[item.id] ?? 0) + 1;
    var completed = false;
    if (count >= item.target) {
      count = 0;
      rounds[item.id] = (rounds[item.id] ?? 0) + 1;
      completed = true;
    }
    counts[item.id] = count;

    final today = TasbeehState.dateKey(DateTime.now());
    history[today] = (history[today] ?? 0) + 1;

    state = state.copyWith(counts: counts, rounds: rounds, history: history);
    _save();
    return completed;
  }

  void resetCurrent() {
    final id = state.selectedId;
    state = state.copyWith(
      counts: {...state.counts, id: 0},
      rounds: {...state.rounds, id: 0},
    );
    _save();
  }

  void select(String id) {
    state = state.copyWith(selectedId: id);
    _save();
  }

  void setDailyTarget(int value) {
    state = state.copyWith(dailyTarget: value);
    _save();
  }

  void toggleVibrate() {
    state = state.copyWith(vibrate: !state.vibrate);
    _save();
  }

  void addCustom(String text, int target) {
    final id = 'custom_${DateTime.now().microsecondsSinceEpoch}';
    state = state.copyWith(
      customs: [
        ...state.customs,
        TasbeehItem(id: id, text: text, target: target, custom: true),
      ],
      selectedId: id,
    );
    _save();
  }

  void removeCustom(String id) {
    final customs = state.customs.where((c) => c.id != id).toList();
    state = state.copyWith(
      customs: customs,
      selectedId: state.selectedId == id ? 'subhanallah' : state.selectedId,
    );
    _save();
  }
}

final tasbeehProvider =
    NotifierProvider<TasbeehNotifier, TasbeehState>(TasbeehNotifier.new);
