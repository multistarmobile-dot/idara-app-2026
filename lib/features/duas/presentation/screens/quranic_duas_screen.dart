import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../quran/data/quran_metadata.dart';
import '../../../quran/domain/entities/ayah.dart';
import '../../../quran/presentation/providers/quran_providers.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/quranic_duas.dart';

final ayahRefProvider = FutureProvider.autoDispose.family<DailyAyah, String>((ref, reference) {
  return ref.watch(quranRepositoryProvider).getAyahByReference(reference);
});

class QuranicDuasScreen extends StatelessWidget {
  const QuranicDuasScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: idaraAppBar('قرآنی دعائیں'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          for (final d in quranicDuas)
            SoftCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Text(
                    d.title,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                  ),
                  const SizedBox(height: 4),
                  for (final r in d.refs) _RefBlock(reference: r),
                ],
              ),
            ),
          Text(
            'یہ دعائیں قرآن مجید کی آیات ہیں؛ متن اور کنز الایمان ترجمہ AlQuran Cloud سے آتا ہے '
            '(پہلی بار انٹرنیٹ چاہیے، پھر آف لائن بھی کھلتی ہیں)۔ عنوانات صرف رہنمائی کے لیے ہیں۔ '
            'مسنون دعائیں (احادیث سے) اگلے مرحلے میں مستند ماخذ کے ساتھ شامل ہوں گی۔',
            style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
          ),
        ],
      ),
    );
  }
}

class _RefBlock extends ConsumerWidget {
  final String reference;
  const _RefBlock({required this.reference});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(ayahRefProvider(reference));
    final size = ref.watch(settingsProvider.select((s) => s.translationFontSize));
    final arabicSize = ref.watch(settingsProvider.select((s) => s.quranFontSize));

    return async.when(
      loading: () => const Padding(
        padding: EdgeInsets.all(16),
        child: Center(child: CircularProgressIndicator()),
      ),
      error: (e, _) => Column(
        children: [
          Text('لوڈ نہیں ہو سکی ($reference)', style: TextStyle(color: context.mutedText)),
          TextButton.icon(
            onPressed: () => ref.invalidate(ayahRefProvider(reference)),
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
            const Divider(),
            Text(
              a.arabic,
              locale: const Locale('ar'),
              textAlign: TextAlign.center,
              textDirection: TextDirection.rtl,
              style: AppTheme.quran(context, size: arabicSize - 3),
            ),
            Text(
              a.urdu,
              style: TextStyle(
                fontSize: size,
                height: 2.3,
                color: context.cs.onSurface.withValues(alpha: 0.9),
              ),
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
              ],
            ),
          ],
        );
      },
    );
  }
}
