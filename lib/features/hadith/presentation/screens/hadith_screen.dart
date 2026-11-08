import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../domain/hadith_models.dart';
import '../providers/hadith_providers.dart';
import '../widgets/hadith_card.dart';

class HadithScreen extends ConsumerStatefulWidget {
  const HadithScreen({super.key});

  @override
  ConsumerState<HadithScreen> createState() => _HadithScreenState();
}

class _HadithScreenState extends ConsumerState<HadithScreen> {
  int _collection = 0;
  HadithLang _lang = HadithLang.urdu;
  int _section = 1;
  bool _showArabic = true;

  void _pickSection() {
    final ctrl = TextEditingController(text: '$_section');
    final formKey = GlobalKey<FormState>();
    showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('کتاب / باب نمبر'),
        content: Form(
          key: formKey,
          child: TextFormField(
            controller: ctrl,
            keyboardType: TextInputType.number,
            validator: (v) {
              final n = int.tryParse((v ?? '').trim());
              if (n == null || n < 0 || n > 200) return '0 سے 200 کے درمیان عدد لکھیں';
              return null;
            },
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(ctx).pop(), child: const Text('منسوخ')),
          FilledButton(
            onPressed: () {
              if (!formKey.currentState!.validate()) return;
              setState(() => _section = int.parse(ctrl.text.trim()));
              Navigator.of(ctx).pop();
            },
            child: const Text('کھولیں'),
          ),
        ],
      ),
    ).then((_) => ctrl.dispose());
  }

  @override
  Widget build(BuildContext context) {
    final col = hadithCollections[_collection];
    final size = ref.watch(settingsProvider.select((s) => s.translationFontSize));
    final req = (collection: col.id, section: _section, lang: _lang);
    final async = ref.watch(hadithSectionProvider(req));

    return Scaffold(
      appBar: idaraAppBar('حدیث شریف'),
      body: Column(
        children: [
          SizedBox(
            height: 56,
            child: ListView(
              scrollDirection: Axis.horizontal,
              padding: const EdgeInsets.fromLTRB(12, 10, 12, 4),
              children: [
                for (int i = 0; i < hadithCollections.length; i++)
                  Padding(
                    padding: const EdgeInsetsDirectional.only(end: 8),
                    child: ChoiceChip(
                      label: Text(
                        hadithCollections[i].nameUrdu,
                        style: TextStyle(color: i == _collection ? Colors.white : null),
                      ),
                      selected: i == _collection,
                      selectedColor: AppColors.greenLight,
                      showCheckmark: false,
                      onSelected: (_) => setState(() {
                        _collection = i;
                        _section = 1;
                      }),
                    ),
                  ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                SegmentedButton<HadithLang>(
                  segments: [
                    for (final l in HadithLang.values)
                      ButtonSegment(value: l, label: Text(l.label)),
                  ],
                  selected: {_lang},
                  onSelectionChanged: (v) => setState(() => _lang = v.first),
                ),
                const Spacer(),
                const Text('عربی'),
                Switch(
                  value: _showArabic,
                  onChanged: (v) => setState(() => _showArabic = v),
                ),
              ],
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8),
            child: Row(
              children: [
                IconButton(
                  tooltip: 'پچھلا باب',
                  icon: const Icon(Icons.chevron_left),
                  onPressed: _section > 0 ? () => setState(() => _section -= 1) : null,
                ),
                Expanded(
                  child: TextButton(
                    onPressed: _pickSection,
                    child: Text(
                      'کتاب / باب نمبر $_section',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                    ),
                  ),
                ),
                IconButton(
                  tooltip: 'اگلا باب',
                  icon: const Icon(Icons.chevron_right),
                  onPressed: () => setState(() => _section += 1),
                ),
              ],
            ),
          ),
          Expanded(
            child: async.when(
              loading: () => const LoadingView(message: 'احادیث لوڈ ہو رہی ہیں...'),
              error: (e, _) => ErrorState(
                message:
                    'یہ باب لوڈ نہیں ہو سکا۔ انٹرنیٹ چیک کریں، یا ہو سکتا ہے اس نمبر کا باب موجود نہ ہو۔',
                onRetry: () => ref.invalidate(hadithSectionProvider(req)),
              ),
              data: (sec) => ListView.builder(
                padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                itemCount: sec.items.length + 2,
                itemBuilder: (context, i) {
                  if (i == 0) {
                    return SoftCard(
                      child: Text(
                        '${col.nameUrdu} — ${sec.title}',
                        style: const TextStyle(fontWeight: FontWeight.bold, height: 2),
                      ),
                    );
                  }
                  if (i == sec.items.length + 1) {
                    return Padding(
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      child: Text(
                        'ماخذ: hadith-api (fawazahmed0) • احادیث ایپ میں ہاتھ سے نہیں لکھی گئیں۔ '
                        'درجات متعلقہ محدثین کے ہیں؛ مسائل کے لیے اہلِ علم سے رجوع کریں۔',
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 11.5, height: 1.9, color: context.mutedText),
                      ),
                    );
                  }
                  return HadithCard(
                    item: sec.items[i - 1],
                    collectionName: col.nameUrdu,
                    showArabic: _showArabic,
                    lang: _lang,
                    translationSize: size,
                  );
                },
              ),
            ),
          ),
        ],
      ),
    );
  }
}
