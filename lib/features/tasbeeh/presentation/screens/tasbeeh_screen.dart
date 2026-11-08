import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../domain/entities/tasbeeh_models.dart';
import '../providers/tasbeeh_provider.dart';

class TasbeehScreen extends ConsumerWidget {
  const TasbeehScreen({super.key});

  Future<void> _addCustomDialog(BuildContext context, WidgetRef ref) async {
    final formKey = GlobalKey<FormState>();
    final textCtrl = TextEditingController();
    final targetCtrl = TextEditingController(text: '100');

    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('اپنی تسبیح شامل کریں'),
        content: Form(
          key: formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: textCtrl,
                decoration: const InputDecoration(labelText: 'ذکر / تسبیح کا متن'),
                validator: (v) {
                  final t = (v ?? '').trim();
                  if (t.isEmpty) return 'متن لکھنا ضروری ہے';
                  if (t.length > 60) return 'زیادہ سے زیادہ 60 حروف';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: targetCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'ہدف (ایک دور کی گنتی)'),
                validator: (v) {
                  final n = int.tryParse((v ?? '').trim());
                  if (n == null || n < 1 || n > 100000) {
                    return '1 سے 100000 کے درمیان عدد لکھیں';
                  }
                  return null;
                },
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('منسوخ'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              ref.read(tasbeehProvider.notifier).addCustom(
                    textCtrl.text.trim(),
                    int.parse(targetCtrl.text.trim()),
                  );
              Navigator.of(ctx).pop();
            },
            child: const Text('محفوظ کریں'),
          ),
        ],
      ),
    );
    textCtrl.dispose();
    targetCtrl.dispose();
  }

  Future<void> _dailyTargetDialog(BuildContext context, WidgetRef ref, int current) async {
    final ctrl = TextEditingController(text: '$current');
    final formKey = GlobalKey<FormState>();
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('روزانہ کا ہدف'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(labelText: 'روزانہ کتنی بار'),
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n < 1 || n > 1000000) return '1 سے 1000000 کے درمیان عدد لکھیں';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('منسوخ'),
          ),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              ref.read(tasbeehProvider.notifier).setDailyTarget(int.parse(ctrl.text.trim()));
              Navigator.of(ctx).pop();
            },
            child: const Text('محفوظ کریں'),
          ),
        ],
      ),
    );
    ctrl.dispose();
  }

  Future<void> _confirmDelete(BuildContext context, WidgetRef ref, TasbeehItem item) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('تسبیح حذف کریں؟'),
        content: Text(item.text),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(false),
            child: const Text('نہیں'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(ctx).pop(true),
            child: const Text('حذف کریں'),
          ),
        ],
      ),
    );
    if (ok == true) ref.read(tasbeehProvider.notifier).removeCustom(item.id);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final st = ref.watch(tasbeehProvider);
    final notifier = ref.read(tasbeehProvider.notifier);
    final item = st.selected;
    final count = st.counts[item.id] ?? 0;
    final rounds = st.rounds[item.id] ?? 0;
    final progress = item.target == 0 ? 0.0 : count / item.target;
    final dailyProgress =
        st.dailyTarget == 0 ? 0.0 : (st.todayTotal / st.dailyTarget).clamp(0.0, 1.0).toDouble();

    // Pichle 7 din
    final days = <String>[
      for (int i = 0; i < 7; i++)
        TasbeehState.dateKey(DateTime.now().subtract(Duration(days: i))),
    ];

    return Scaffold(
      appBar: idaraAppBar('ڈیجیٹل تسبیح'),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
        children: [
          SizedBox(
            height: 52,
            child: ListView(
              scrollDirection: Axis.horizontal,
              children: [
                for (final it in st.items)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: GestureDetector(
                      onLongPress: it.custom ? () => _confirmDelete(context, ref, it) : null,
                      child: ChoiceChip(
                        label: Text(
                          it.text,
                          style: AppTheme.quran(context, size: 15).copyWith(
                            height: 1.5,
                            color: it.id == st.selectedId ? Colors.white : null,
                          ),
                        ),
                        selected: it.id == st.selectedId,
                        selectedColor: AppColors.greenLight,
                        showCheckmark: false,
                        onSelected: (_) => notifier.select(it.id),
                      ),
                    ),
                  ),
                ActionChip(
                  avatar: const Icon(Icons.add, size: 18),
                  label: const Text('اپنی تسبیح'),
                  onPressed: () => _addCustomDialog(context, ref),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          HeroCard(
            child: Column(
              children: [
                Text(
                  item.text,
                  textAlign: TextAlign.center,
                  textDirection: TextDirection.rtl,
                  style: AppTheme.quran(context, size: 28).copyWith(color: Colors.white),
                ),
                Text(
                  'ہدف: ${item.target}  •  مکمل دور: $rounds',
                  style: const TextStyle(color: AppColors.goldLight),
                ),
                const SizedBox(height: 14),
                GestureDetector(
                  onTap: () {
                    final completed = notifier.increment();
                    if (st.vibrate) {
                      if (completed) {
                        HapticFeedback.heavyImpact();
                      } else {
                        HapticFeedback.lightImpact();
                      }
                    }
                  },
                  child: SizedBox(
                    width: 220,
                    height: 220,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        SizedBox(
                          width: 220,
                          height: 220,
                          child: CircularProgressIndicator(
                            value: progress,
                            strokeWidth: 10,
                            color: AppColors.goldLight,
                            backgroundColor: Colors.white24,
                          ),
                        ),
                        Container(
                          width: 180,
                          height: 180,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: Colors.white.withValues(alpha: 0.15),
                            border: Border.all(color: Colors.white38, width: 2),
                          ),
                          child: Directionality(
                            textDirection: TextDirection.ltr,
                            child: Text(
                              '$count',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 64,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                const Text(
                  'گننے کے لیے دائرے پر ٹیپ کریں',
                  style: TextStyle(color: Colors.white70, fontSize: 12),
                ),
              ],
            ),
          ),
          const SizedBox(height: 12),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed: notifier.resetCurrent,
                  icon: const Icon(Icons.refresh),
                  label: const Text('ری سیٹ'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: SwitchListTile(
                  contentPadding: EdgeInsets.zero,
                  dense: true,
                  title: const Text('وائبریشن'),
                  value: st.vibrate,
                  onChanged: (_) => notifier.toggleVibrate(),
                ),
              ),
            ],
          ),
          const SectionHeader('روزانہ کا ہدف'),
          SoftCard(
            onTap: () => _dailyTargetDialog(context, ref, st.dailyTarget),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        'آج: ${st.todayTotal} / ${st.dailyTarget}',
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    const Icon(Icons.edit, size: 18),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: dailyProgress,
                  minHeight: 8,
                  borderRadius: BorderRadius.circular(8),
                ),
              ],
            ),
          ),
          const SectionHeader('پچھلے 7 دن'),
          SoftCard(
            child: Column(
              children: [
                for (final d in days)
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    child: Row(
                      children: [
                        Directionality(
                          textDirection: TextDirection.ltr,
                          child: Text(d, style: TextStyle(color: context.mutedText)),
                        ),
                        const Spacer(),
                        Text(
                          '${st.history[d] ?? 0}',
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
              ],
            ),
          ),
          Text(
            'اپنی بنائی ہوئی تسبیح کو ہٹانے کے لیے اس پر دیر تک دبائیں۔ تمام گنتی فون میں محفوظ رہتی ہے (آف لائن کام کرتی ہے)۔',
            style: TextStyle(fontSize: 12, height: 1.9, color: context.mutedText),
          ),
        ],
      ),
    );
  }
}
