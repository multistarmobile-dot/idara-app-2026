import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/providers/app_providers.dart';
import '../../data/azan_scheduler.dart';
import '../../domain/entities/prayer_models.dart';
import 'prayer_providers.dart';

class AzanSettings {
  final bool enabled;
  final bool alarmMode;
  final Map<String, bool> prayers;
  const AzanSettings({
    required this.enabled,
    required this.alarmMode,
    required this.prayers,
  });

  AzanSettings copyWith({bool? enabled, bool? alarmMode, Map<String, bool>? prayers}) {
    return AzanSettings(
      enabled: enabled ?? this.enabled,
      alarmMode: alarmMode ?? this.alarmMode,
      prayers: prayers ?? this.prayers,
    );
  }
}

const List<PrayerKind> azanPrayers = [
  PrayerKind.fajr,
  PrayerKind.dhuhr,
  PrayerKind.asr,
  PrayerKind.maghrib,
  PrayerKind.isha,
];

class AzanSettingsNotifier extends Notifier<AzanSettings> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  AzanSettings build() {
    final p = ref.watch(sharedPrefsProvider);
    return AzanSettings(
      enabled: p.getBool('azan_enabled') ?? false,
      alarmMode: p.getBool('azan_alarm_mode') ?? false,
      prayers: {
        for (final k in azanPrayers) k.name: p.getBool('azan_${k.name}') ?? true,
      },
    );
  }

  /// Azan on karte waqt ijazat mangta hai. Ijazat na mile to false.
  Future<bool> setEnabled(bool value) async {
    if (value) {
      final ok = await AzanScheduler.instance.requestPermissions();
      if (!ok) return false;
    }
    state = state.copyWith(enabled: value);
    await _prefs.setBool('azan_enabled', value);
    return true;
  }

  void setPrayer(PrayerKind kind, bool value) {
    state = state.copyWith(prayers: {...state.prayers, kind.name: value});
    _prefs.setBool('azan_${kind.name}', value);
  }

  void setAlarmMode(bool value) {
    state = state.copyWith(alarmMode: value);
    _prefs.setBool('azan_alarm_mode', value);
  }
}

final azanSettingsProvider =
    NotifierProvider<AzanSettingsNotifier, AzanSettings>(AzanSettingsNotifier.new);

/// Shehr, adjustment ya azan settings badalne par notifications dobara lagata hai.
final azanSyncProvider = Provider<void>((ref) {
  final loc = ref.watch(prayerLocationProvider);
  final adj = ref.watch(prayerAdjustmentsProvider);
  final s = ref.watch(azanSettingsProvider);

  Future<void>(() async {
    try {
      if (s.enabled) {
        await AzanScheduler.instance.schedule(
          location: loc,
          adjustments: adj,
          prayers: s.prayers,
          alarmMode: s.alarmMode,
        );
      } else {
        await AzanScheduler.instance.cancelAll();
      }
    } catch (_) {}
  });
});
