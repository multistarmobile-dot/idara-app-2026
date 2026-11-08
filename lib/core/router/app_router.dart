import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../features/duas/presentation/screens/quranic_duas_screen.dart';
import '../../features/hadith/presentation/screens/hadith_screen.dart';
import '../../features/home/presentation/home_screen.dart';
import '../../features/islamic_calendar/presentation/screens/islamic_calendar_screen.dart';
import '../../features/prayer/presentation/screens/azan_settings_screen.dart';
import '../../features/prayer/presentation/screens/prayer_month_screen.dart';
import '../../features/quran/presentation/screens/quran_audio_screen.dart';
import '../../features/home/presentation/main_shell.dart';
import '../../features/more/presentation/screens/about_screen.dart';
import '../../features/more/presentation/screens/more_screen.dart';
import '../../features/onboarding/presentation/onboarding_screen.dart';
import '../../features/prayer/presentation/screens/prayer_screen.dart';
import '../../features/qibla/presentation/screens/qibla_screen.dart';
import '../../features/quran/presentation/screens/quran_reader_screen.dart';
import '../../features/quran/presentation/screens/quran_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/splash/presentation/splash_screen.dart';
import '../../features/tasbeeh/presentation/screens/tasbeeh_screen.dart';

class AppRoutes {
  static const String splash = '/splash';
  static const String onboarding = '/onboarding';
  static const String home = '/home';
  static const String quran = '/quran';
  static const String prayer = '/prayer';
  static const String tasbeeh = '/tasbeeh';
  static const String more = '/more';
  static const String qibla = '/qibla';
  static const String settings = '/settings';
  static const String about = '/about';
  static const String quranAudio = '/quran-audio';
  static const String hadith = '/hadith';
  static const String duas = '/duas';
  static const String islamicCalendar = '/islamic-calendar';
  static const String prayerMonth = '/prayer-month';
  static const String azanSettings = '/azan-settings';

  static String audio({int? surah}) =>
      surah == null ? quranAudio : '$quranAudio?surah=$surah';

  static String surah(int number, {int? ayah}) =>
      ayah == null ? '/surah/$number' : '/surah/$number?ayah=$ayah';
  static String para(int number) => '/para/$number';
}

final GlobalKey<NavigatorState> _rootNavigatorKey =
    GlobalKey<NavigatorState>(debugLabel: 'root');

int _safeInt(String? raw, int fallback) => int.tryParse(raw ?? '') ?? fallback;

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    navigatorKey: _rootNavigatorKey,
    initialLocation: AppRoutes.splash,
    routes: [
      GoRoute(
        path: AppRoutes.splash,
        builder: (context, state) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (context, state) => const OnboardingScreen(),
      ),
      StatefulShellRoute.indexedStack(
        builder: (context, state, navigationShell) =>
            MainShell(navigationShell: navigationShell),
        branches: [
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.home,
              builder: (context, state) => const HomeScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.quran,
              builder: (context, state) => const QuranScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.prayer,
              builder: (context, state) => const PrayerScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.tasbeeh,
              builder: (context, state) => const TasbeehScreen(),
            ),
          ]),
          StatefulShellBranch(routes: [
            GoRoute(
              path: AppRoutes.more,
              builder: (context, state) => const MoreScreen(),
            ),
          ]),
        ],
      ),
      GoRoute(
        path: '/surah/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = _safeInt(state.pathParameters['id'], 1).clamp(1, 114).toInt();
          final ayahRaw = state.uri.queryParameters['ayah'];
          return QuranReaderScreen(
            number: id,
            initialAyah: ayahRaw == null ? null : int.tryParse(ayahRaw),
          );
        },
      ),
      GoRoute(
        path: '/para/:id',
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final id = _safeInt(state.pathParameters['id'], 1).clamp(1, 30).toInt();
          return QuranReaderScreen(number: id, isPara: true);
        },
      ),
      GoRoute(
        path: AppRoutes.qibla,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QiblaScreen(),
      ),
      GoRoute(
        path: AppRoutes.settings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const SettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.quranAudio,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) {
          final raw = state.uri.queryParameters['surah'];
          final s = raw == null ? null : int.tryParse(raw);
          return QuranAudioScreen(surah: s == null ? null : s.clamp(1, 114).toInt());
        },
      ),
      GoRoute(
        path: AppRoutes.hadith,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const HadithScreen(),
      ),
      GoRoute(
        path: AppRoutes.duas,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const QuranicDuasScreen(),
      ),
      GoRoute(
        path: AppRoutes.islamicCalendar,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const IslamicCalendarScreen(),
      ),
      GoRoute(
        path: AppRoutes.prayerMonth,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const PrayerMonthScreen(),
      ),
      GoRoute(
        path: AppRoutes.azanSettings,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AzanSettingsScreen(),
      ),
      GoRoute(
        path: AppRoutes.about,
        parentNavigatorKey: _rootNavigatorKey,
        builder: (context, state) => const AboutScreen(),
      ),
    ],
  );
});
