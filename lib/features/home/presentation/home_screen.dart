import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/providers/app_providers.dart';
import '../../../core/router/app_router.dart';
import '../../../shared/widgets/section_header.dart';
import '../../prayer/data/prayer_calculator.dart';
import '../../prayer/presentation/providers/prayer_providers.dart';
import '../../settings/presentation/providers/settings_provider.dart';
import '../../hadith/presentation/widgets/daily_hadith_card.dart';
import 'widgets/home_cards.dart';
import 'widgets/home_header.dart';
import 'widgets/quick_access_grid.dart';

class HomeScreen extends ConsumerWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final now = ref.watch(tickerProvider).value ?? DateTime.now();
    final loc = ref.watch(prayerLocationProvider);
    final adj = ref.watch(prayerAdjustmentsProvider);
    final offset = ref.watch(settingsProvider.select((s) => s.hijriOffset));

    final day = PrayerCalculator.forDate(loc, now, adj);
    final next = PrayerCalculator.next(loc, now, adj);

    return ListView(
      padding: EdgeInsets.zero,
      children: [
        HomeHeader(
          now: now,
          hijriOffset: offset,
          city: loc.name,
          onCityTap: () => context.go(AppRoutes.prayer),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              NextPrayerCard(next: next, now: now),
              const SizedBox(height: 4),
              PrayerStrip(day: day, nextKind: next.entry.kind),
              const SectionHeader('آج کی آیت'),
              const DailyAyahCard(),
              const SectionHeader('آج کی حدیث'),
              const DailyHadithCard(),
              const SectionHeader('قرآن پاک'),
              const ContinueReadingCard(),
              const SectionHeader('فوری رسائی'),
              const QuickAccessGrid(),
            ],
          ),
        ),
      ],
    );
  }
}
