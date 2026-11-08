import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../prayer/data/prayer_calculator.dart';
import '../../../prayer/domain/entities/prayer_models.dart';
import '../../../prayer/presentation/screens/prayer_screen.dart' show prayerIcon;
import '../../../quran/data/quran_metadata.dart';
import '../../../quran/presentation/providers/quran_providers.dart';

class NextPrayerCard extends StatelessWidget {
  final NextPrayer next;
  final DateTime now;
  const NextPrayerCard({super.key, required this.next, required this.now});

  @override
  Widget build(BuildContext context) {
    return SoftCard(
      borderColor: AppColors.gold,
      onTap: () => context.go(AppRoutes.prayer),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('اگلی نماز', style: TextStyle(color: context.mutedText)),
                Text(
                  next.entry.kind.urdu,
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold),
                ),
                Text(
                  PrayerCalculator.formatTime(next.entry.time),
                  style: TextStyle(
                    fontSize: 16,
                    color: context.isDark ? AppColors.goldLight : context.cs.primary,
                  ),
                ),
              ],
            ),
          ),
          Directionality(
            textDirection: TextDirection.ltr,
            child: Text(
              PrayerCalculator.formatDuration(next.entry.time.difference(now)),
              style: TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.bold,
                color: context.cs.primary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class PrayerStrip extends StatelessWidget {
  final PrayerDay day;
  final PrayerKind nextKind;
  const PrayerStrip({super.key, required this.day, required this.nextKind});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        for (final e in day.prayers)
          Expanded(
            child: Container(
              margin: const EdgeInsets.symmetric(horizontal: 3),
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: e.kind == nextKind
                    ? context.cs.primary
                    : context.cs.surface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: context.cs.primary.withValues(alpha: 0.15),
                ),
              ),
              child: Column(
                children: [
                  Icon(
                    prayerIcon(e.kind),
                    size: 20,
                    color: e.kind == nextKind ? Colors.white : context.cs.primary,
                  ),
                  Text(
                    e.kind.urdu,
                    style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: e.kind == nextKind ? Colors.white : null,
                    ),
                  ),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      PrayerCalculator.formatTime(e.time).replaceAll(' ', '\n'),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 11,
                        height: 1.3,
                        color: e.kind == nextKind ? Colors.white70 : context.mutedText,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
      ],
    );
  }
}

class DailyAyahCard extends ConsumerWidget {
  const DailyAyahCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dailyAyahProvider);

    return SoftCard(
      child: async.when(
        loading: () => const Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
        error: (e, _) => Column(
          children: [
            Text(
              'آج کی آیت لوڈ نہیں ہو سکی۔ انٹرنیٹ چیک کریں۔',
              style: TextStyle(color: context.mutedText),
            ),
            TextButton.icon(
              onPressed: () => ref.invalidate(dailyAyahProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('دوبارہ کوشش کریں'),
            ),
          ],
        ),
        data: (a) {
          final name = surahNames[(a.surah - 1).clamp(0, 113).toInt()];
          final text = '${a.arabic}\n\n${a.urdu}\n\n— سورۃ $name، آیت ${a.number}\n(ادارہ خیر العباد)';
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(
                a.arabic,
                textAlign: TextAlign.center,
                locale: const Locale('ar'),
                textDirection: TextDirection.rtl,
                style: AppTheme.quran(context, size: 24),
              ),
              const Divider(height: 20),
              Text(
                a.urdu,
                style: TextStyle(height: 2.2, color: context.cs.onSurface.withValues(alpha: 0.88)),
              ),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'سورۃ $name • آیت ${a.number}',
                      style: TextStyle(fontSize: 12, color: context.mutedText),
                    ),
                  ),
                  IconButton(
                    tooltip: 'کاپی',
                    icon: const Icon(Icons.copy, size: 20),
                    onPressed: () {
                      Clipboard.setData(ClipboardData(text: text));
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('آیت کاپی ہو گئی')),
                      );
                    },
                  ),
                  IconButton(
                    tooltip: 'شیئر',
                    icon: const Icon(Icons.share, size: 20),
                    onPressed: () => Share.share(text),
                  ),
                  IconButton(
                    tooltip: 'سورت کھولیں',
                    icon: const Icon(Icons.open_in_new, size: 20),
                    onPressed: () => context.push(AppRoutes.surah(a.surah, ayah: a.number)),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

class ContinueReadingCard extends ConsumerWidget {
  const ContinueReadingCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final last = ref.watch(quranProgressProvider.select((p) => p.lastRead));
    final has = last != null;
    final name = has ? surahNames[(last.surah - 1).clamp(0, 113).toInt()] : '';

    return SoftCard(
      onTap: () => context.push(
        has ? AppRoutes.surah(last.surah, ayah: last.ayah) : AppRoutes.surah(1),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              shape: BoxShape.circle,
              gradient: LinearGradient(colors: [AppColors.greenDark, AppColors.greenLight]),
            ),
            child: const Icon(Icons.menu_book, color: Colors.white),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  has ? 'پڑھنا جاری رکھیں' : 'قرآن پاک پڑھنا شروع کریں',
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                Text(
                  has ? 'سورۃ $name • آیت ${last.ayah}' : 'سورۃ الفاتحہ سے آغاز کریں',
                  style: TextStyle(fontSize: 12, color: context.mutedText),
                ),
              ],
            ),
          ),
          const Icon(Icons.chevron_right),
        ],
      ),
    );
  }
}
