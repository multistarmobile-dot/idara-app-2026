import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/prayer_calculator.dart';
import '../../domain/entities/prayer_models.dart';
import '../providers/prayer_providers.dart';

/// Poore mahine ka namaz ka time table.
class PrayerMonthScreen extends ConsumerStatefulWidget {
  const PrayerMonthScreen({super.key});

  @override
  ConsumerState<PrayerMonthScreen> createState() => _PrayerMonthScreenState();
}

class _PrayerMonthScreenState extends ConsumerState<PrayerMonthScreen> {
  late DateTime _month;

  @override
  void initState() {
    super.initState();
    final n = DateTime.now();
    _month = DateTime(n.year, n.month);
  }

  void _shift(int delta) {
    setState(() => _month = DateTime(_month.year, _month.month + delta));
  }

  @override
  Widget build(BuildContext context) {
    final loc = ref.watch(prayerLocationProvider);
    final adj = ref.watch(prayerAdjustmentsProvider);
    final offset = ref.watch(settingsProvider.select((s) => s.hijriOffset));

    final daysInMonth = DateTime(_month.year, _month.month + 1, 0).day;
    final today = DateTime.now();

    String t(PrayerDay d, PrayerKind k) =>
        PrayerCalculator.formatTime(d.entries.firstWhere((e) => e.kind == k).time);

    final rows = <DataRow>[];
    for (int day = 1; day <= daysInMonth; day++) {
      final date = DateTime(_month.year, _month.month, day);
      final pd = PrayerCalculator.forDate(loc, date, adj);
      final isToday = date.year == today.year && date.month == today.month && date.day == today.day;
      final hijri = gregorianToHijri(date, offset: offset);
      final cellStyle = TextStyle(
        fontWeight: isToday ? FontWeight.bold : FontWeight.normal,
        fontSize: 13,
      );

      rows.add(
        DataRow(
          color: isToday
              ? WidgetStatePropertyAll(AppColors.gold.withValues(alpha: 0.25))
              : null,
          cells: [
            DataCell(
              Text(
                '$day ${urduWeekdays[date.weekday - 1]}\n${hijri.day} ${hijriMonths[(hijri.month.clamp(1, 12)).toInt() - 1]}',
                style: cellStyle.copyWith(fontSize: 12),
              ),
            ),
            for (final k in PrayerKind.values)
              DataCell(
                Directionality(
                  textDirection: TextDirection.ltr,
                  child: Text(t(pd, k), style: cellStyle),
                ),
              ),
          ],
        ),
      );
    }

    return Scaffold(
      appBar: idaraAppBar('ماہانہ نماز کیلنڈر'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(8, 8, 8, 0),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'پچھلا مہینہ',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: () => _shift(-1),
                ),
                Expanded(
                  child: Column(
                    children: [
                      Text(
                        '${urduMonths[_month.month - 1]} ${_month.year}',
                        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${loc.name} • کراچی طریقہ • حنفی عصر',
                        style: TextStyle(fontSize: 12, color: context.mutedText),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: 'اگلا مہینہ',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => _shift(1),
                ),
              ],
            ),
          ),
          Expanded(
            child: SingleChildScrollView(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columnSpacing: 16,
                  headingRowHeight: 48,
                  dataRowMinHeight: 52,
                  dataRowMaxHeight: 56,
                  columns: [
                    const DataColumn(label: Text('تاریخ')),
                    for (final k in PrayerKind.values) DataColumn(label: Text(k.urdu)),
                  ],
                  rows: rows,
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Text(
              'مغرب = غروبِ آفتاب۔ اوقات حسابی ہیں؛ مقامی مسجد کے مستند اوقات سے تصدیق کریں۔ '
              'شہر یا منٹ ایڈجسٹمنٹ نماز اسکرین سے بدلیں۔',
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 11.5, height: 1.8, color: context.mutedText),
            ),
          ),
        ],
      ),
    );
  }
}
