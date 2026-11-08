import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../prayer/data/prayer_calculator.dart';
import '../../../prayer/domain/entities/prayer_models.dart';
import '../../../prayer/presentation/providers/prayer_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/islamic_events.dart';

class IslamicCalendarScreen extends ConsumerWidget {
  const IslamicCalendarScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        appBar: idaraAppBar(
          'اسلامی کیلنڈر',
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.goldLight,
            tabs: [
              Tab(text: 'اہم تاریخیں'),
              Tab(text: 'رمضان ٹائم ٹیبل'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            _EventsTab(),
            _RamadanTab(),
          ],
        ),
      ),
    );
  }
}

DateTime _dateOnly(DateTime d) => DateTime(d.year, d.month, d.day);

class _EventsTab extends ConsumerWidget {
  const _EventsTab();

  DateTime? _next(IslamicEvent e, DateTime today, int offset) {
    for (int i = 0; i < 400; i++) {
      final d = DateTime(today.year, today.month, today.day + i);
      final h = gregorianToHijri(d, offset: offset);
      if (h.month == e.month && h.day == e.day) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offset = ref.watch(settingsProvider.select((s) => s.hijriOffset));
    final today = _dateOnly(DateTime.now());

    final rows = <(IslamicEvent, DateTime)>[];
    for (final e in islamicEvents) {
      final d = _next(e, today, offset);
      if (d != null) rows.add((e, d));
    }
    rows.sort((a, b) => a.$2.compareTo(b.$2));

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        HeroCard(
          child: Column(
            children: [
              const Text('آج کی تاریخ', style: TextStyle(color: Colors.white70)),
              const SizedBox(height: 4),
              Text(
                hijriText(today, offset: offset),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(
                gregorianText(today),
                style: const TextStyle(color: AppColors.goldLight, fontSize: 15),
              ),
            ],
          ),
        ),
        const SectionHeader('آنے والی اہم تاریخیں'),
        for (final r in rows)
          SoftCard(
            child: Row(
              children: [
                Container(
                  width: 58,
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(14),
                    gradient: const LinearGradient(
                      colors: [AppColors.greenDark, AppColors.greenLight],
                    ),
                  ),
                  child: Column(
                    children: [
                      Text(
                        '${r.$2.difference(today).inDays}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const Text('دن', style: TextStyle(color: Colors.white70, fontSize: 11)),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(r.$1.title, style: const TextStyle(fontWeight: FontWeight.bold)),
                      Text(
                        gregorianText(r.$2),
                        style: TextStyle(fontSize: 12, color: context.mutedText),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        Text(
          'تاریخیں حسابی طریقے سے نکالی گئی ہیں۔ پاکستان میں رویتِ ہلال سے ایک دن کا فرق ممکن ہے؛ '
          'ترتیبات میں “ہجری تاریخ” کو ایک دن آگے پیچھے کر سکتے ہیں۔',
          style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
        ),
      ],
    );
  }
}

class _RamadanTab extends ConsumerWidget {
  const _RamadanTab();

  DateTime? _ramadanStart(DateTime today, int offset) {
    final h = gregorianToHijri(today, offset: offset);
    if (h.month == 9) {
      return DateTime(today.year, today.month, today.day - (h.day - 1));
    }
    for (int i = 1; i <= 400; i++) {
      final d = DateTime(today.year, today.month, today.day + i);
      final hd = gregorianToHijri(d, offset: offset);
      if (hd.month == 9 && hd.day == 1) return d;
    }
    return null;
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final offset = ref.watch(settingsProvider.select((s) => s.hijriOffset));
    final loc = ref.watch(prayerLocationProvider);
    final adj = ref.watch(prayerAdjustmentsProvider);
    final today = _dateOnly(DateTime.now());
    final start = _ramadanStart(today, offset);

    if (start == null) {
      return const Center(child: Text('رمضان کی تاریخ نہیں نکل سکی'));
    }

    final rows = <DataRow>[];
    for (int i = 0; i < 30; i++) {
      final date = DateTime(start.year, start.month, start.day + i);
      if (gregorianToHijri(date, offset: offset).month != 9) break;
      final pd = PrayerCalculator.forDate(loc, date, adj);
      final fajr = pd.entries.firstWhere((e) => e.kind == PrayerKind.fajr).time;
      final maghrib = pd.entries.firstWhere((e) => e.kind == PrayerKind.maghrib).time;
      final isToday = date == today;
      final style = TextStyle(
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      );
      rows.add(
        DataRow(
          color: isToday ? WidgetStatePropertyAll(AppColors.gold.withValues(alpha: 0.25)) : null,
          cells: [
            DataCell(Text('${i + 1}', style: style)),
            DataCell(Text('${date.day} ${urduMonths[date.month - 1]}', style: style)),
            DataCell(Directionality(
              textDirection: TextDirection.ltr,
              child: Text(PrayerCalculator.formatTime(fajr), style: style),
            )),
            DataCell(Directionality(
              textDirection: TextDirection.ltr,
              child: Text(PrayerCalculator.formatTime(maghrib), style: style),
            )),
          ],
        ),
      );
    }

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        SoftCard(
          child: Text(
            'رمضان المبارک کا آغاز (حسابی): ${gregorianText(start)}\nشہر: ${loc.name}',
            style: const TextStyle(fontWeight: FontWeight.bold, height: 2),
          ),
        ),
        SingleChildScrollView(
          scrollDirection: Axis.horizontal,
          child: DataTable(
            columnSpacing: 22,
            columns: const [
              DataColumn(label: Text('روزہ')),
              DataColumn(label: Text('تاریخ')),
              DataColumn(label: Text('سحری ختم')),
              DataColumn(label: Text('افطار')),
            ],
            rows: rows,
          ),
        ),
        const SizedBox(height: 10),
        Text(
          'سحری کا اختتام فجر کے حسابی وقت پر اور افطار مغرب (غروبِ آفتاب) پر دکھایا گیا ہے۔ '
          'احتیاط کے لیے اپنی مقامی مسجد کا مستند سحر و افطار ٹائم ٹیبل بھی دیکھ لیں۔',
          style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
        ),
      ],
    );
  }
}
