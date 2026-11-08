import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/providers/app_providers.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../data/pakistan_cities.dart';
import '../../data/prayer_calculator.dart';
import '../../domain/entities/prayer_models.dart';
import '../providers/prayer_providers.dart';

IconData prayerIcon(PrayerKind kind) {
  switch (kind) {
    case PrayerKind.fajr:
      return Icons.wb_twilight;
    case PrayerKind.sunrise:
      return Icons.wb_sunny_outlined;
    case PrayerKind.dhuhr:
      return Icons.wb_sunny;
    case PrayerKind.asr:
      return Icons.cloud_queue;
    case PrayerKind.maghrib:
      return Icons.nights_stay_outlined;
    case PrayerKind.isha:
      return Icons.bedtime;
  }
}

class PrayerScreen extends ConsumerStatefulWidget {
  const PrayerScreen({super.key});

  @override
  ConsumerState<PrayerScreen> createState() => _PrayerScreenState();
}

class _PrayerScreenState extends ConsumerState<PrayerScreen> {
  bool _gpsBusy = false;

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _useGps() async {
    setState(() => _gpsBusy = true);
    try {
      if (!await Geolocator.isLocationServiceEnabled()) {
        throw 'فون کی لوکیشن سروس بند ہے۔ پہلے اسے آن کریں۔';
      }
      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        throw 'مقام کی اجازت نہیں ملی۔ فون کی سیٹنگ سے اجازت دیں۔';
      }
      final pos = await Geolocator.getCurrentPosition()
          .timeout(const Duration(seconds: 25));
      await ref
          .read(prayerLocationProvider.notifier)
          .setGps(pos.latitude, pos.longitude);
      _snack('مقام اپڈیٹ ہو گیا');
    } catch (e) {
      _snack(e is String ? e : 'مقام حاصل نہیں ہو سکا۔ دوبارہ کوشش کریں۔');
    } finally {
      if (mounted) setState(() => _gpsBusy = false);
    }
  }

  void _openCitySheet() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (_) => const _CitySheet(),
    );
  }

  void _openAdjustSheet() {
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      builder: (_) => const _AdjustSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final now = ref.watch(tickerProvider).value ?? DateTime.now();
    final loc = ref.watch(prayerLocationProvider);
    final adj = ref.watch(prayerAdjustmentsProvider);
    final day = PrayerCalculator.forDate(loc, now, adj);
    final next = PrayerCalculator.next(loc, now, adj);

    return Scaffold(
      appBar: idaraAppBar('نماز کے اوقات'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
        children: [
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Icon(
                      loc.isGps ? Icons.my_location : Icons.location_city,
                      color: context.cs.primary,
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            loc.name,
                            style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 18,
                            ),
                          ),
                          Text(
                            'کراچی طریقہ • حنفی عصر',
                            style: TextStyle(fontSize: 12, color: context.mutedText),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 10,
                  runSpacing: 6,
                  children: [
                    OutlinedButton.icon(
                      onPressed: _openCitySheet,
                      icon: const Icon(Icons.search),
                      label: const Text('شہر منتخب کریں'),
                    ),
                    FilledButton.tonalIcon(
                      onPressed: _gpsBusy ? null : _useGps,
                      icon: _gpsBusy
                          ? const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(strokeWidth: 2),
                            )
                          : const Icon(Icons.gps_fixed),
                      label: const Text('GPS سے مقام'),
                    ),
                  ],
                ),
              ],
            ),
          ),
          HeroCard(
            child: Column(
              children: [
                const Text('اگلی نماز', style: TextStyle(color: Colors.white70)),
                Text(
                  next.entry.kind.urdu,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  PrayerCalculator.formatTime(next.entry.time),
                  style: const TextStyle(color: AppColors.goldLight, fontSize: 20),
                ),
                const SizedBox(height: 6),
                const Text('نماز میں باقی وقت',
                    style: TextStyle(color: Colors.white70)),
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(
                    PrayerCalculator.formatDuration(
                      next.entry.time.difference(now),
                    ),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 34,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SectionHeader('آج کے اوقات'),
          for (final e in day.entries)
            _PrayerTile(
              entry: e,
              isNext: e.kind == next.entry.kind && e.kind.isPrayer,
              adjustment: adj[e.kind.name] ?? 0,
            ),
          const SizedBox(height: 4),
          SoftCard(
            onTap: () => context.push(AppRoutes.prayerMonth),
            child: Row(
              children: [
                Icon(Icons.calendar_view_month, color: context.cs.primary),
                const SizedBox(width: 12),
                const Expanded(child: Text('ماہانہ نماز کیلنڈر', style: TextStyle(fontWeight: FontWeight.bold))),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          SoftCard(
            onTap: () => context.push(AppRoutes.azanSettings),
            child: Row(
              children: [
                Icon(Icons.notifications_active, color: context.cs.primary),
                const SizedBox(width: 12),
                const Expanded(child: Text('اذان کی ترتیبات', style: TextStyle(fontWeight: FontWeight.bold))),
                const Icon(Icons.chevron_right),
              ],
            ),
          ),
          OutlinedButton.icon(
            onPressed: _openAdjustSheet,
            icon: const Icon(Icons.tune),
            label: const Text('اوقات میں منٹ ایڈجسٹ کریں'),
          ),
          const SizedBox(height: 12),
          Text(
            'مغرب کا وقت غروبِ آفتاب (${PrayerCalculator.formatTime(day.sunset)}) ہی سے شروع ہوتا ہے۔ '
            'اوقات حسابی ہیں؛ اپنی مقامی مسجد کے مستند اوقات سے تصدیق کر لیں، '
            'ضرورت ہو تو اوپر سے منٹ ایڈجسٹ کریں۔',
            style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
          ),
        ],
      ),
    );
  }
}

class _PrayerTile extends StatelessWidget {
  final PrayerEntry entry;
  final bool isNext;
  final int adjustment;
  const _PrayerTile({
    required this.entry,
    required this.isNext,
    required this.adjustment,
  });

  @override
  Widget build(BuildContext context) {
    final color = context.isDark ? AppColors.goldLight : context.cs.primary;
    return SoftCard(
      borderColor: isNext ? AppColors.gold : null,
      child: Row(
        children: [
          Icon(prayerIcon(entry.kind), color: color, size: 28),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  entry.kind.urdu,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: isNext ? 19 : 17,
                  ),
                ),
                if (isNext)
                  Text('اگلی نماز', style: TextStyle(fontSize: 11, color: context.mutedText)),
                if (adjustment != 0)
                  Text(
                    'ایڈجسٹ: ${adjustment > 0 ? '+' : ''}$adjustment منٹ',
                    style: TextStyle(fontSize: 11, color: context.mutedText),
                  ),
              ],
            ),
          ),
          Text(
            PrayerCalculator.formatTime(entry.time),
            style: TextStyle(fontSize: 18, color: color, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}

class _CitySheet extends ConsumerStatefulWidget {
  const _CitySheet();

  @override
  ConsumerState<_CitySheet> createState() => _CitySheetState();
}

class _CitySheetState extends ConsumerState<_CitySheet> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    final q = _query.trim();
    final cities = PakistanCities.all.where((c) => q.isEmpty || c.name.contains(q)).toList();
    final selected = ref.watch(prayerLocationProvider).name;

    return Padding(
      padding: EdgeInsets.only(bottom: MediaQuery.of(context).viewInsets.bottom),
      child: SizedBox(
        height: MediaQuery.of(context).size.height * 0.7,
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: TextField(
                decoration: const InputDecoration(
                  hintText: 'شہر تلاش کریں',
                  prefixIcon: Icon(Icons.search),
                ),
                onChanged: (v) => setState(() => _query = v),
              ),
            ),
            Expanded(
              child: cities.isEmpty
                  ? const Center(child: Text('کوئی شہر نہیں ملا'))
                  : ListView.builder(
                      itemCount: cities.length,
                      itemBuilder: (_, i) {
                        final c = cities[i];
                        return ListTile(
                          leading: const Icon(Icons.location_city),
                          title: Text(c.name),
                          trailing: c.name == selected
                              ? Icon(Icons.check_circle, color: context.cs.primary)
                              : null,
                          onTap: () {
                            ref.read(prayerLocationProvider.notifier).selectCity(c);
                            Navigator.of(context).pop();
                          },
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}

class _AdjustSheet extends ConsumerWidget {
  const _AdjustSheet();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final adj = ref.watch(prayerAdjustmentsProvider);
    final notifier = ref.read(prayerAdjustmentsProvider.notifier);

    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'اوقات میں منٹ ایڈجسٹ کریں',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            for (final kind in PrayerKind.values)
              Row(
                children: [
                  Expanded(child: Text(kind.urdu)),
                  IconButton(
                    icon: const Icon(Icons.remove_circle_outline),
                    onPressed: () => notifier.set(kind, (adj[kind.name] ?? 0) - 1),
                  ),
                  SizedBox(
                    width: 48,
                    child: Directionality(
                      textDirection: TextDirection.ltr,
                      child: Text(
                        '${(adj[kind.name] ?? 0) > 0 ? '+' : ''}${adj[kind.name] ?? 0}',
                        textAlign: TextAlign.center,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.add_circle_outline),
                    onPressed: () => notifier.set(kind, (adj[kind.name] ?? 0) + 1),
                  ),
                ],
              ),
            const SizedBox(height: 8),
            OutlinedButton.icon(
              onPressed: notifier.reset,
              icon: const Icon(Icons.restart_alt),
              label: const Text('سب صفر کریں'),
            ),
          ],
        ),
      ),
    );
  }
}
