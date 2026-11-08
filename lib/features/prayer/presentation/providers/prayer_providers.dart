import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/providers/app_providers.dart';
import '../../data/pakistan_cities.dart';
import '../../domain/entities/prayer_models.dart';

class PrayerLocationNotifier extends Notifier<PrayerLocation> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  PrayerLocation build() {
    final p = ref.watch(sharedPrefsProvider);
    final name = p.getString(AppConstants.kLocName);
    final lat = p.getDouble(AppConstants.kLocLat);
    final lng = p.getDouble(AppConstants.kLocLng);
    if (name == null || lat == null || lng == null) {
      return PakistanCities.defaultLocation;
    }
    return PrayerLocation(
      name: name,
      latitude: lat,
      longitude: lng,
      isGps: p.getBool(AppConstants.kLocGps) ?? false,
    );
  }

  Future<void> _save(PrayerLocation loc) async {
    state = loc;
    await _prefs.setString(AppConstants.kLocName, loc.name);
    await _prefs.setDouble(AppConstants.kLocLat, loc.latitude);
    await _prefs.setDouble(AppConstants.kLocLng, loc.longitude);
    await _prefs.setBool(AppConstants.kLocGps, loc.isGps);
  }

  Future<void> selectCity(PakistanCity city) => _save(
        PrayerLocation(
          name: city.name,
          latitude: city.latitude,
          longitude: city.longitude,
        ),
      );

  Future<void> setGps(double lat, double lng) => _save(
        PrayerLocation(
          name: 'موجودہ مقام (GPS)',
          latitude: lat,
          longitude: lng,
          isGps: true,
        ),
      );
}

final prayerLocationProvider =
    NotifierProvider<PrayerLocationNotifier, PrayerLocation>(
  PrayerLocationNotifier.new,
);

/// Har namaz ke liye manual minute adjustment (-30 se +30).
class PrayerAdjustmentsNotifier extends Notifier<Map<String, int>> {
  SharedPreferences get _prefs => ref.read(sharedPrefsProvider);

  @override
  Map<String, int> build() {
    final raw = ref.watch(sharedPrefsProvider).getString(AppConstants.kPrayerAdjust);
    if (raw == null) return const <String, int>{};
    try {
      final decoded = jsonDecode(raw) as Map<String, dynamic>;
      return decoded.map((k, v) => MapEntry(k, (v as num).toInt()));
    } catch (_) {
      return const <String, int>{};
    }
  }

  void set(PrayerKind kind, int minutes) {
    final clamped = minutes < -30 ? -30 : (minutes > 30 ? 30 : minutes);
    state = {...state, kind.name: clamped};
    _prefs.setString(AppConstants.kPrayerAdjust, jsonEncode(state));
  }

  void reset() {
    state = const <String, int>{};
    _prefs.remove(AppConstants.kPrayerAdjust);
  }
}

final prayerAdjustmentsProvider =
    NotifierProvider<PrayerAdjustmentsNotifier, Map<String, int>>(
  PrayerAdjustmentsNotifier.new,
);
