import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:scrollable_positioned_list/scrollable_positioned_list.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../data/quran_metadata.dart';
import '../../domain/entities/ayah.dart';
import '../providers/quran_audio_provider.dart';

class QuranAudioScreen extends ConsumerStatefulWidget {
  /// [surah] diya ho to usi ki tilawat shuru hoti hai.
  final int? surah;
  const QuranAudioScreen({super.key, this.surah});

  @override
  ConsumerState<QuranAudioScreen> createState() => _QuranAudioScreenState();
}

class _QuranAudioScreenState extends ConsumerState<QuranAudioScreen> {
  final ItemScrollController _scroll = ItemScrollController();

  @override
  void initState() {
    super.initState();
    Future<void>.microtask(() {
      final st = ref.read(quranAudioProvider);
      final notifier = ref.read(quranAudioProvider.notifier);
      if (widget.surah != null) {
        if (st.surah != widget.surah) notifier.openSurah(widget.surah!);
      } else if (st.surah == null) {
        notifier.openSurah(1, autoplay: false);
      }
    });
  }

  void _pickSurah() {
    showModalBottomSheet<void>(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => SizedBox(
        height: MediaQuery.of(ctx).size.height * 0.75,
        child: ListView.builder(
          itemCount: surahNames.length,
          itemBuilder: (_, i) => ListTile(
            leading: CircleAvatar(
              radius: 16,
              backgroundColor: AppColors.greenLight,
              child: Text('${i + 1}', style: const TextStyle(color: Colors.white, fontSize: 11)),
            ),
            title: Text(surahNames[i]),
            subtitle: Text('${surahAyahCounts[i]} آیات'),
            onTap: () {
              Navigator.of(ctx).pop();
              ref.read(quranAudioProvider.notifier).openSurah(i + 1);
            },
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final st = ref.watch(quranAudioProvider);
    final notifier = ref.read(quranAudioProvider.notifier);

    ref.listen<int>(quranAudioProvider.select((s) => s.index), (prev, next) {
      if (_scroll.isAttached && prev != next) {
        _scroll.scrollTo(index: next, duration: const Duration(milliseconds: 350));
      }
    });

    final surahName = st.surah == null ? '—' : surahNames[(st.surah! - 1).clamp(0, 113).toInt()];
    final current = (st.index < st.ayat.length) ? st.ayat[st.index] : null;

    return Scaffold(
      appBar: idaraAppBar('قرآن آڈیو'),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 0),
            child: SoftCard(
              onTap: _pickSurah,
              child: Row(
                children: [
                  const Icon(Icons.headphones, color: AppColors.gold),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      'سورۃ $surahName',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                    ),
                  ),
                  const Text('سورت بدلیں'),
                  const Icon(Icons.expand_more),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: HeroCard(
              child: Column(
                children: [
                  if (st.loading)
                    const Padding(
                      padding: EdgeInsets.all(24),
                      child: CircularProgressIndicator(color: Colors.white),
                    )
                  else ...[
                    Text(
                      st.tracks.isEmpty
                          ? 'سورت منتخب کریں'
                          : 'آیت ${st.tracks[st.index].number} / ${st.tracks.length}',
                      style: const TextStyle(color: AppColors.goldLight),
                    ),
                    if (current != null) ...[
                      Text(
                        current.arabic,
                        locale: const Locale('ar'),
                        textAlign: TextAlign.center,
                        textDirection: TextDirection.rtl,
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                        style: AppTheme.quran(context, size: 24).copyWith(color: Colors.white),
                      ),
                      if (current.translations[QuranEdition.urdu] != null)
                        Text(
                          current.translations[QuranEdition.urdu]!,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style: const TextStyle(color: Colors.white70, fontSize: 13, height: 2),
                        ),
                    ],
                  ],
                  if (st.error != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(
                        st.error!,
                        textAlign: TextAlign.center,
                        style: const TextStyle(color: Colors.orangeAccent),
                      ),
                    ),
                  const SizedBox(height: 8),
                  Directionality(
                    textDirection: TextDirection.ltr,
                    child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      IconButton(
                        tooltip: 'دہرائیں',
                        onPressed: notifier.cycleRepeat,
                        icon: Icon(
                          st.repeat == AudioRepeat.ayah ? Icons.repeat_one : Icons.repeat,
                          color: st.repeat == AudioRepeat.off ? Colors.white54 : AppColors.goldLight,
                        ),
                      ),
                      IconButton(
                        tooltip: 'پچھلی آیت',
                        iconSize: 34,
                        color: Colors.white,
                        onPressed: st.index > 0 ? notifier.previous : null,
                        icon: const Icon(Icons.skip_previous),
                      ),
                      Container(
                        decoration: const BoxDecoration(
                          shape: BoxShape.circle,
                          color: AppColors.gold,
                        ),
                        child: IconButton(
                          iconSize: 40,
                          color: Colors.white,
                          onPressed: st.tracks.isEmpty ? null : notifier.togglePlay,
                          icon: Icon(st.playing ? Icons.pause : Icons.play_arrow),
                        ),
                      ),
                      IconButton(
                        tooltip: 'اگلی آیت',
                        iconSize: 34,
                        color: Colors.white,
                        onPressed: st.index < st.tracks.length - 1 ? notifier.next : null,
                        icon: const Icon(Icons.skip_next),
                      ),
                      IconButton(
                        tooltip: 'بند کریں',
                        onPressed: notifier.stop,
                        icon: const Icon(Icons.stop, color: Colors.white),
                      ),
                    ],
                  ),
                  ),
                  Text(
                    switch (st.repeat) {
                      AudioRepeat.off => 'دہرانا: بند',
                      AudioRepeat.ayah => 'دہرانا: ایک آیت',
                      AudioRepeat.surah => 'دہرانا: پوری سورت',
                    },
                    style: const TextStyle(color: Colors.white60, fontSize: 11),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: st.tracks.isEmpty
                ? (st.loading
                    ? const SizedBox.shrink()
                    : const EmptyState(
                        icon: Icons.headphones,
                        title: 'تلاوت سنیں',
                        message: 'اوپر سے سورت منتخب کریں۔ تلاوت آن لائن چلتی ہے، انٹرنیٹ ضروری ہے۔',
                      ))
                : ScrollablePositionedList.builder(
                    itemScrollController: _scroll,
                    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
                    itemCount: st.tracks.length + 1,
                    itemBuilder: (context, i) {
                      if (i == st.tracks.length) {
                        return Padding(
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          child: Text(
                            'تلاوت: مشاری راشد العفاسی • ماخذ: AlQuran Cloud / Islamic Network',
                            textAlign: TextAlign.center,
                            style: TextStyle(fontSize: 11.5, color: context.mutedText),
                          ),
                        );
                      }
                      final isCurrent = i == st.index;
                      final text = i < st.ayat.length ? st.ayat[i].arabic : null;
                      return SoftCard(
                        borderColor: isCurrent ? AppColors.gold : null,
                        onTap: () => notifier.playAt(i),
                        child: Row(
                          children: [
                            Icon(
                              isCurrent && st.playing ? Icons.volume_up : Icons.play_circle_outline,
                              color: isCurrent ? AppColors.gold : context.mutedText,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: text == null
                                  ? Text('آیت ${st.tracks[i].number}')
                                  : Text(
                                      text,
                                      locale: const Locale('ar'),
                                      textAlign: TextAlign.right,
                                      textDirection: TextDirection.rtl,
                                      style: AppTheme.quran(context, size: 21),
                                    ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${st.tracks[i].number}',
                              style: TextStyle(fontSize: 12, color: context.mutedText),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
