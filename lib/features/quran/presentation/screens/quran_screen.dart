import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../../../shared/widgets/state_views.dart';
import '../../data/quran_metadata.dart';
import '../providers/quran_providers.dart';

class QuranScreen extends ConsumerStatefulWidget {
  const QuranScreen({super.key});

  @override
  ConsumerState<QuranScreen> createState() => _QuranScreenState();
}

class _QuranScreenState extends ConsumerState<QuranScreen> {
  String _query = '';

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        appBar: idaraAppBar(
          'قرآن پاک',
          actions: [
            IconButton(
              tooltip: 'قرآن آڈیو',
              icon: const Icon(Icons.headphones),
              onPressed: () => context.push(AppRoutes.audio()),
            ),
          ],
          bottom: const TabBar(
            labelColor: Colors.white,
            unselectedLabelColor: Colors.white70,
            indicatorColor: AppColors.goldLight,
            tabs: [
              Tab(text: 'سورتیں'),
              Tab(text: 'پارے'),
              Tab(text: 'نشانیاں'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            _buildSurahs(context),
            _buildParas(context),
            const _BookmarksTab(),
          ],
        ),
      ),
    );
  }

  Widget _buildSurahs(BuildContext context) {
    final q = _query.trim();
    final indexes = <int>[
      for (int i = 0; i < surahNames.length; i++)
        if (q.isEmpty || surahNames[i].contains(q) || '${i + 1}' == q) i,
    ];

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            decoration: const InputDecoration(
              hintText: 'سورت کا نام یا نمبر تلاش کریں',
              prefixIcon: Icon(Icons.search),
            ),
            onChanged: (v) => setState(() => _query = v),
          ),
        ),
        Expanded(
          child: indexes.isEmpty
              ? const EmptyState(icon: Icons.search_off, title: 'کوئی سورت نہیں ملی')
              : ListView.builder(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  itemCount: indexes.length,
                  itemBuilder: (_, k) {
                    final i = indexes[k];
                    return SoftCard(
                      onTap: () => context.push(AppRoutes.surah(i + 1)),
                      child: Row(
                        children: [
                          _NumberBadge(i + 1),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  surahNames[i],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 17,
                                  ),
                                ),
                                Text(
                                  '${surahAyahCounts[i]} آیات',
                                  style: TextStyle(fontSize: 12, color: context.mutedText),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.chevron_right),
                        ],
                      ),
                    );
                  },
                ),
        ),
      ],
    );
  }

  Widget _buildParas(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: paraNames.length,
      itemBuilder: (_, i) => SoftCard(
        onTap: () => context.push(AppRoutes.para(i + 1)),
        child: Row(
          children: [
            _NumberBadge(i + 1),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'پارہ ${i + 1}',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  Text(
                    paraNames[i],
                    textDirection: TextDirection.rtl,
                    style: TextStyle(fontSize: 13, color: context.mutedText),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right),
          ],
        ),
      ),
    );
  }
}

class _NumberBadge extends StatelessWidget {
  final int number;
  const _NumberBadge(this.number);

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 44,
      height: 44,
      alignment: Alignment.center,
      decoration: const BoxDecoration(
        shape: BoxShape.circle,
        gradient: LinearGradient(
          colors: [AppColors.greenDark, AppColors.greenLight],
        ),
      ),
      child: Text(
        '$number',
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.bold,
          fontSize: 13,
        ),
      ),
    );
  }
}

class _BookmarksTab extends ConsumerWidget {
  const _BookmarksTab();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final marks = ref.watch(quranProgressProvider).bookmarks.toList();
    marks.sort((a, b) {
      final pa = a.split(':');
      final pb = b.split(':');
      final sa = int.tryParse(pa.first) ?? 0;
      final sb = int.tryParse(pb.first) ?? 0;
      if (sa != sb) return sa.compareTo(sb);
      return (int.tryParse(pa.last) ?? 0).compareTo(int.tryParse(pb.last) ?? 0);
    });

    if (marks.isEmpty) {
      return const EmptyState(
        icon: Icons.bookmark_border,
        title: 'ابھی کوئی نشان نہیں',
        message: 'کسی آیت کے ساتھ نشان (بُک مارک) کے بٹن کو دبائیں، وہ یہاں محفوظ ہو جائے گی۔',
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: marks.length,
      itemBuilder: (_, i) {
        final parts = marks[i].split(':');
        final s = int.tryParse(parts.first) ?? 1;
        final a = int.tryParse(parts.last) ?? 1;
        final name = (s >= 1 && s <= surahNames.length) ? surahNames[s - 1] : '$s';
        return SoftCard(
          onTap: () => context.push(AppRoutes.surah(s, ayah: a)),
          child: Row(
            children: [
              const Icon(Icons.bookmark, color: AppColors.gold),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  'سورۃ $name — آیت $a',
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
              ),
              IconButton(
                tooltip: 'ہٹائیں',
                icon: const Icon(Icons.delete_outline),
                onPressed: () =>
                    ref.read(quranProgressProvider.notifier).removeBookmark(marks[i]),
              ),
            ],
          ),
        );
      },
    );
  }
}
