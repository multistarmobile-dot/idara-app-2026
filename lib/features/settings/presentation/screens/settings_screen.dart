import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../quran/presentation/widgets/reader_settings_panel.dart';
import '../providers/settings_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Scaffold(
      appBar: idaraAppBar('ترتیبات'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          const SectionHeader('ظاہری شکل'),
          SoftCard(
            child: SegmentedButton<ThemeMode>(
              segments: const [
                ButtonSegment(value: ThemeMode.light, label: Text('روشن'), icon: Icon(Icons.light_mode)),
                ButtonSegment(value: ThemeMode.dark, label: Text('ڈارک'), icon: Icon(Icons.dark_mode)),
                ButtonSegment(value: ThemeMode.system, label: Text('سسٹم'), icon: Icon(Icons.phone_android)),
              ],
              selected: {s.themeMode},
              onSelectionChanged: (v) => n.setThemeMode(v.first),
            ),
          ),
          const SectionHeader('ہجری تاریخ'),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Text(hijriText(DateTime.now(), offset: s.hijriOffset),
                    style: const TextStyle(fontWeight: FontWeight.bold)),
                const SizedBox(height: 8),
                SegmentedButton<int>(
                  segments: const [
                    ButtonSegment(value: -1, label: Text('-1 دن')),
                    ButtonSegment(value: 0, label: Text('درست')),
                    ButtonSegment(value: 1, label: Text('+1 دن')),
                  ],
                  selected: {s.hijriOffset},
                  onSelectionChanged: (v) => n.setHijriOffset(v.first),
                ),
                const SizedBox(height: 6),
                Text(
                  'چاند کی رویت کے مطابق تاریخ ایک دن آگے پیچھے کر سکتے ہیں۔',
                  style: TextStyle(fontSize: 12, color: context.mutedText),
                ),
              ],
            ),
          ),
          const SectionHeader('قرآن پڑھنے کی ترتیب'),
          const SoftCard(child: ReaderSettingsPanel()),
        ],
      ),
    );
  }
}
