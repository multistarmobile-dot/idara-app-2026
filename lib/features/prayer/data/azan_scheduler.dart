import 'package:flutter/foundation.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:timezone/data/latest_all.dart' as tz_data;
import 'package:timezone/timezone.dart' as tz;

import '../domain/entities/prayer_models.dart';
import 'prayer_calculator.dart';

/// Namaz ke waqt azan wali notification (agle 7 din tak schedule hoti hai).
class AzanScheduler {
  AzanScheduler._();
  static final AzanScheduler instance = AzanScheduler._();

  final FlutterLocalNotificationsPlugin _plugin = FlutterLocalNotificationsPlugin();
  bool _initialized = false;

  static const int daysAhead = 7;
  static const String _channelNormal = 'azan_normal_v1';
  static const String _channelAlarm = 'azan_alarm_v1';
  static const RawResourceAndroidNotificationSound _sound =
      RawResourceAndroidNotificationSound('adhan');

  Future<void> init() async {
    if (_initialized) return;
    tz_data.initializeTimeZones();
    tz.setLocalLocation(tz.getLocation('Asia/Karachi'));

    await _plugin.initialize(
      const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
      ),
    );

    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelNormal,
        'اذان (فون کے موڈ کے مطابق)',
        description: 'نماز کے وقت اذان کی یاددہانی',
        importance: Importance.max,
        playSound: true,
        sound: _sound,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.notification,
      ),
    );
    await android?.createNotificationChannel(
      const AndroidNotificationChannel(
        _channelAlarm,
        'اذان (ہر صورت)',
        description: 'سائلنٹ موڈ میں بھی اذان چلانے کی کوشش',
        importance: Importance.max,
        playSound: true,
        sound: _sound,
        enableVibration: true,
        audioAttributesUsage: AudioAttributesUsage.alarm,
      ),
    );
    _initialized = true;
  }

  /// Notification aur Exact Alarm ki ijazat mangta hai. Notification ki ijazat milne par true.
  Future<bool> requestPermissions() async {
    await init();
    final android = _plugin.resolvePlatformSpecificImplementation<
        AndroidFlutterLocalNotificationsPlugin>();
    final granted = await android?.requestNotificationsPermission();
    try {
      await android?.requestExactAlarmsPermission();
    } catch (_) {}
    return granted ?? true;
  }

  NotificationDetails _details(bool alarmMode) {
    return NotificationDetails(
      android: AndroidNotificationDetails(
        alarmMode ? _channelAlarm : _channelNormal,
        alarmMode ? 'اذان (ہر صورت)' : 'اذان (فون کے موڈ کے مطابق)',
        channelDescription: 'نماز کے وقت کی یاددہانی',
        importance: Importance.max,
        priority: Priority.high,
        playSound: true,
        sound: _sound,
        enableVibration: true,
        category: AndroidNotificationCategory.alarm,
        audioAttributesUsage:
            alarmMode ? AudioAttributesUsage.alarm : AudioAttributesUsage.notification,
      ),
    );
  }

  Future<void> schedule({
    required PrayerLocation location,
    required Map<String, int> adjustments,
    required Map<String, bool> prayers,
    required bool alarmMode,
  }) async {
    await init();
    await cancelAll();

    final now = tz.TZDateTime.now(tz.local);
    for (int d = 0; d < daysAhead; d++) {
      final date = DateTime(now.year, now.month, now.day + d);
      final list = PrayerCalculator.forDate(location, date, adjustments).prayers;

      for (int i = 0; i < list.length; i++) {
        final entry = list[i];
        if (prayers[entry.kind.name] != true) continue;

        final when = tz.TZDateTime.from(entry.time, tz.local);
        if (!when.isAfter(now)) continue;

        final id = 100 + d * 10 + i;
        final title = 'نماز کا وقت ہو گیا';
        final body = '${entry.kind.urdu} کی نماز کا وقت ہو گیا ہے۔';
        try {
          await _plugin.zonedSchedule(
            id,
            title,
            body,
            when,
            _details(alarmMode),
            androidScheduleMode: AndroidScheduleMode.exactAllowWhileIdle,
            uiLocalNotificationDateInterpretation:
                UILocalNotificationDateInterpretation.absoluteTime,
          );
        } catch (e) {
          // Exact alarm ki ijazat na ho to approximate waqt par schedule karo.
          try {
            await _plugin.zonedSchedule(
              id,
              title,
              body,
              when,
              _details(alarmMode),
              androidScheduleMode: AndroidScheduleMode.inexactAllowWhileIdle,
              uiLocalNotificationDateInterpretation:
                  UILocalNotificationDateInterpretation.absoluteTime,
            );
          } catch (e2) {
            debugPrint('Azan schedule failed: $e2');
          }
        }
      }
    }
  }

  Future<void> cancelAll() async {
    await init();
    for (int d = 0; d < daysAhead; d++) {
      for (int i = 0; i < 5; i++) {
        await _plugin.cancel(100 + d * 10 + i);
      }
    }
  }

  Future<void> showTest({required bool alarmMode}) async {
    await init();
    await _plugin.show(
      999,
      'ادارہ خیر العباد',
      'اذان کی نوٹیفکیشن کا ٹیسٹ کامیاب ہے۔',
      _details(alarmMode),
    );
  }
}
