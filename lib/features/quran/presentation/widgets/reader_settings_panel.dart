import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../settings/presentation/providers/settings_provider.dart';

/// Quran reading options (font size + translations). Settings aur reader dono mein use hota hai.
class ReaderSettingsPanel extends ConsumerWidget {
  const ReaderSettingsPanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final s = ref.watch(settingsProvider);
    final n = ref.read(settingsProvider.notifier);

    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text('عربی فونٹ سائز: ${s.quranFontSize.round()}'),
        Slider(
          min: 20,
          max: 44,
          divisions: 24,
          value: s.quranFontSize.clamp(20.0, 44.0).toDouble(),
          onChanged: n.setQuranFontSize,
        ),
        Text('ترجمے کا فونٹ سائز: ${s.translationFontSize.round()}'),
        Slider(
          min: 13,
          max: 30,
          divisions: 17,
          value: s.translationFontSize.clamp(13.0, 30.0).toDouble(),
          onChanged: n.setTranslationFontSize,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('اردو ترجمہ (کنز الایمان)'),
          value: s.showUrdu,
          onChanged: n.setShowUrdu,
        ),
        SwitchListTile(
          contentPadding: EdgeInsets.zero,
          title: const Text('English translation'),
          subtitle: const Text('Ahmed Raza Khan'),
          value: s.showEnglish,
          onChanged: n.setShowEnglish,
        ),
      ],
    );
  }
}

Future<void> showReaderSettingsSheet(BuildContext context) {
  return showModalBottomSheet<void>(
    context: context,
    showDragHandle: true,
    builder: (_) => const SafeArea(
      child: Padding(
        padding: EdgeInsets.fromLTRB(20, 0, 20, 20),
        child: ReaderSettingsPanel(),
      ),
    ),
  );
}
