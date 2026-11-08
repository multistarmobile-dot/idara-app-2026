import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';
import 'package:go_router/go_router.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../../settings/presentation/providers/settings_provider.dart';
import '../../data/quran_metadata.dart';
import '../../domain/entities/ayah.dart';
import '../providers/quran_providers.dart';
import '../widgets/ayah_tile.dart';
import '../widgets/reader_settings_panel.dart';

const String _bismillah = 'بِسْمِ ٱللَّهِ ٱلرَّحْمَٰنِ ٱلرَّحِيمِ';

class _Row {
  final int? headerSurah;
  final Ayah? ayah;
  final bool footer;
  const _Row.forHeader(int surah)
      : headerSurah = surah,
        ayah = null,
        footer = false;
  const _Row.forAyah(Ayah a)
      : headerSurah = null,
        ayah = a,
        footer = false;
  const _Row.forFooter()
      : headerSurah = null,
        ayah = null,
        footer = true;
}

/// Surah ya Para ka reader. [initialAyah] par seedha jump karta hai.
class QuranReaderScreen extends ConsumerStatefulWidget {
  final int number;
  final bool isPara;
  final int? initialAyah;

  const QuranReaderScreen({
    super.key,
    required this.number,
    this.isPara = false,
    this.initialAyah,
  });

  @override
  ConsumerState<QuranReaderScreen> createState() => _QuranReaderScreenState();
}

class _QuranReaderScreenState extends ConsumerState<QuranReaderScreen> {
  final ItemScrollController _scroll = ItemScrollController();
  final ItemPositionsListener _positions = ItemPositionsListener.create();
  Timer? _debounce;
  List<_Row> _rows = const <_Row>[];

  @override
  void initState() {
    super.initState();
    _positions.itemPositions.addListener(_onScroll);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _positions.itemPositions.removeListener(_onScroll);
    super.dispose();
  }

  void _onScroll() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(seconds: 1), _saveLastRead);
  }

  void _saveLastRead() {
    if (!mounted || _rows.isEmpty) return;
    final visible = _positions.itemPositions.value
        .where((p) => p.itemTrailingEdge > 0)
        .toList();
    if (visible.isEmpty) return;
    visible.sort((a, b) => a.index.compareTo(b.index));
    for (int i = visible.first.index; i < _rows.length; i++) {
      final a = _rows[i].ayah;
      if (a != null) {
        ref.read(quranProgressProvider.notifier).setLastRead(a.surah, a.number);
        break;
      }
    }
  }

  List<_Row> _buildRows(List<Ayah> ayat) {
    final rows = <_Row>[];
    for (final a in ayat) {
      if (a.number == 1) rows.add(_Row.forHeader(a.surah));
      rows.add(_Row.forAyah(a));
    }
    rows.add(const _Row.forFooter());
    return rows;
  }

  int _initialIndex() {
    final target = widget.initialAyah;
    if (target == null) return 0;
    for (int i = 0; i < _rows.length; i++) {
      final a = _rows[i].ayah;
      if (a != null && a.number == target && (widget.isPara || a.surah == widget.number)) {
        return i;
      }
    }
    return 0;
  }

  String _shareText(Ayah a) {
    final urdu = a.translations[QuranEdition.urdu];
    final english = a.translations[QuranEdition.english];
    final name = surahNames[(a.surah - 1).clamp(0, 113).toInt()];
    return [
      a.arabic,
      if (urdu != null) urdu,
      if (english != null) english,
      '— سورۃ $name، آیت ${a.number}',
      '(ادارہ خیر العباد)',
    ].join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final settings = ref.watch(settingsProvider);
    final bookmarks = ref.watch(quranProgressProvider.select((p) => p.bookmarks));
    final req = (
      isPara: widget.isPara,
      number: widget.number,
      urdu: settings.showUrdu,
      english: settings.showEnglish,
    );
    final async = ref.watch(readerAyatProvider(req));

    final title = widget.isPara
        ? 'پارہ ${widget.number}'
        : 'سورۃ ${surahNames[(widget.number - 1).clamp(0, 113).toInt()]}';

    return Scaffold(
      appBar: idaraAppBar(
        title,
        actions: [
          if (!widget.isPara)
            IconButton(
              tooltip: 'تلاوت سنیں',
              icon: const Icon(Icons.headphones),
              onPressed: () => context.push(AppRoutes.audio(surah: widget.number)),
            ),
          IconButton(
            tooltip: 'پڑھنے کی ترتیبات',
            icon: const Icon(Icons.text_fields),
            onPressed: () => showReaderSettingsSheet(context),
          ),
        ],
      ),
      body: async.when(
        loading: () => const LoadingView(message: 'قرآن پاک لوڈ ہو رہا ہے...'),
        error: (e, _) => ErrorState(
          message:
              'یہ حصہ لوڈ نہیں ہو سکا۔ پہلی بار پڑھنے کے لیے انٹرنیٹ ضروری ہے؛ '
              'اس کے بعد یہ آف لائن بھی کھلے گا۔',
          onRetry: () => ref.invalidate(readerAyatProvider(req)),
        ),
        data: (ayat) {
          if (ayat.isEmpty) {
            return const EmptyState(icon: Icons.menu_book, title: 'کوئی آیت نہیں ملی');
          }
          _rows = _buildRows(ayat);
          return ScrollablePositionedList.builder(
            itemScrollController: _scroll,
            itemPositionsListener: _positions,
            initialScrollIndex: _initialIndex(),
            padding: const EdgeInsets.all(16),
            itemCount: _rows.length,
            itemBuilder: (context, i) {
              final row = _rows[i];
              if (row.headerSurah != null) {
                return _SurahHeader(surah: row.headerSurah!);
              }
              if (row.footer) return const _SourceFooter();
              final a = row.ayah!;
              return AyahTile(
                ayah: a,
                fontSize: settings.quranFontSize,
                translationSize: settings.translationFontSize,
                showUrdu: settings.showUrdu,
                showEnglish: settings.showEnglish,
                bookmarked: bookmarks.contains('${a.surah}:${a.number}'),
                onBookmark: () => ref
                    .read(quranProgressProvider.notifier)
                    .toggleBookmark(a.surah, a.number),
                onCopy: () {
                  Clipboard.setData(ClipboardData(text: _shareText(a)));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('آیت کاپی ہو گئی')),
                  );
                },
                onShare: () => Share.share(_shareText(a)),
              );
            },
          );
        },
      ),
    );
  }
}

class _SurahHeader extends StatelessWidget {
  final int surah;
  const _SurahHeader({required this.surah});

  @override
  Widget build(BuildContext context) {
    final idx = (surah - 1).clamp(0, 113).toInt();
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: HeroCard(
        padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 16),
        child: Column(
          children: [
            Text(
              'سورۃ ${surahNames[idx]}',
              style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
            Text(
              '${surahAyahCounts[idx]} آیات',
              style: const TextStyle(color: AppColors.goldLight),
            ),
            if (surah != 1 && surah != 9) ...[
              const SizedBox(height: 8),
              Text(
                _bismillah,
                locale: const Locale('ar'),
                textDirection: TextDirection.rtl,
                style: AppTheme.quran(context, size: 24).copyWith(color: Colors.white),
              ),
            ],
          ],
        ),
      ),
    );
  }
}

class _SourceFooter extends StatelessWidget {
  const _SourceFooter();

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16),
      child: Text(
        'قرآنی متن: Tanzil / AlQuran Cloud • اردو ترجمہ: کنز الایمان (امام احمد رضا خان بریلوی)',
        textAlign: TextAlign.center,
        style: TextStyle(fontSize: 11.5, height: 1.9, color: context.mutedText),
      ),
    );
  }
}
