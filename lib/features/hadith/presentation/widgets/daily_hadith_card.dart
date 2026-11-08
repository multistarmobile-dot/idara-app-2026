import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/hadith_models.dart';
import '../providers/hadith_providers.dart';
import 'hadith_card.dart';

/// Home par "آج کی حدیث".
class DailyHadithCard extends ConsumerWidget {
  const DailyHadithCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final async = ref.watch(dailyHadithProvider);
    final size = ref.watch(settingsProvider.select((s) => s.translationFontSize));

    return async.when(
      loading: () => const SoftCard(
        child: Padding(
          padding: EdgeInsets.all(20),
          child: Center(child: CircularProgressIndicator()),
        ),
      ),
      error: (e, _) => SoftCard(
        child: Column(
          children: [
            Text('آج کی حدیث لوڈ نہیں ہو سکی۔ انٹرنیٹ چیک کریں۔', style: TextStyle(color: context.mutedText)),
            TextButton.icon(
              onPressed: () => ref.invalidate(dailyHadithProvider),
              icon: const Icon(Icons.refresh),
              label: const Text('دوبارہ کوشش کریں'),
            ),
          ],
        ),
      ),
      data: (d) => HadithCard(
        item: d.item,
        collectionName: d.collectionName,
        showArabic: true,
        lang: HadithLang.urdu,
        translationSize: size,
      ),
    );
  }
}
