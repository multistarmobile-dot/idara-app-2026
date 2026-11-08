import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../data/azan_scheduler.dart';
import '../providers/azan_providers.dart';
import 'prayer_screen.dart' show prayerIcon;

class AzanSettingsScreen extends ConsumerStatefulWidget {
  const AzanSettingsScreen({super.key});

  @override
  ConsumerState<AzanSettingsScreen> createState() => _AzanSettingsScreenState();
}

class _AzanSettingsScreenState extends ConsumerState<AzanSettingsScreen> {
  final AudioPlayer _preview = AudioPlayer();
  bool _previewing = false;

  @override
  void initState() {
    super.initState();
    _preview.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _previewing = false);
    });
  }

  @override
  void dispose() {
    _preview.dispose();
    super.dispose();
  }

  void _snack(String m) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(m)));
  }

  Future<void> _togglePreview() async {
    try {
      if (_previewing) {
        await _preview.stop();
        setState(() => _previewing = false);
      } else {
        await _preview.play(AssetSource('audio/adhan.ogg'));
        setState(() => _previewing = true);
      }
    } catch (_) {
      _snack('اذان چلانے میں مسئلہ آیا۔');
    }
  }

  @override
  Widget build(BuildContext context) {
    final s = ref.watch(azanSettingsProvider);
    final n = ref.read(azanSettingsProvider.notifier);

    return Scaffold(
      appBar: idaraAppBar('اذان کی ترتیبات'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          SoftCard(
            child: SwitchListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text('نماز کی اذان / یاددہانی', style: TextStyle(fontWeight: FontWeight.bold)),
              subtitle: const Text('نماز کے وقت نوٹیفکیشن کے ساتھ اذان بجے گی'),
              value: s.enabled,
              onChanged: (v) async {
                final ok = await n.setEnabled(v);
                if (!ok) _snack('نوٹیفکیشن کی اجازت نہیں ملی۔ فون کی سیٹنگ سے اجازت دیں۔');
              },
            ),
          ),
          const SectionHeader('کن نمازوں کی اذان'),
          for (final k in azanPrayers)
            SoftCard(
              child: SwitchListTile(
                contentPadding: EdgeInsets.zero,
                secondary: Icon(prayerIcon(k), color: context.cs.primary),
                title: Text(k.urdu),
                value: s.prayers[k.name] ?? true,
                onChanged: s.enabled ? (v) => n.setPrayer(k, v) : null,
              ),
            ),
          const SectionHeader('آواز کا انداز'),
          SoftCard(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('فون کے موڈ کے مطابق')),
                    ButtonSegment(value: true, label: Text('ہر صورت (الارم)')),
                  ],
                  selected: {s.alarmMode},
                  onSelectionChanged: (v) => n.setAlarmMode(v.first),
                ),
                const SizedBox(height: 8),
                Text(
                  '“ہر صورت” میں الارم والیوم استعمال ہوتا ہے۔ ڈو ناٹ ڈسٹرب میں فون کی اجازت درکار ہو سکتی ہے۔',
                  style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
                ),
              ],
            ),
          ),
          const SectionHeader('آزمائش'),
          Wrap(
            spacing: 10,
            runSpacing: 8,
            children: [
              FilledButton.icon(
                onPressed: _togglePreview,
                icon: Icon(_previewing ? Icons.stop : Icons.play_arrow),
                label: Text(_previewing ? 'بند کریں' : 'اذان سنیں'),
              ),
              OutlinedButton.icon(
                onPressed: () async {
                  final ok = await AzanScheduler.instance.requestPermissions();
                  if (!ok) {
                    _snack('نوٹیفکیشن کی اجازت نہیں ملی۔');
                    return;
                  }
                  await AzanScheduler.instance.showTest(alarmMode: s.alarmMode);
                },
                icon: const Icon(Icons.notifications_active_outlined),
                label: const Text('نوٹیفکیشن ٹیسٹ'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            'بہتر کام کے لیے: فون کی سیٹنگ میں ایپ کے لیے “Alarms & reminders” کی اجازت دیں اور '
            'بیٹری آپٹیمائزیشن کو “Unrestricted / No restrictions” کر دیں۔ اوقات اسی شہر/مقام اور '
            'منٹ ایڈجسٹمنٹ کے مطابق لگتے ہیں جو نماز اسکرین میں منتخب ہے۔ ایپ ہر بار کھلنے پر اگلے 7 دن کے الارم تازہ کرتی ہے۔',
            style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
          ),
        ],
      ),
    );
  }
}
