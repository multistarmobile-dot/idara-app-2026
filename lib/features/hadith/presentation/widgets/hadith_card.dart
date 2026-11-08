import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:share_plus/share_plus.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../domain/hadith_models.dart';

class HadithCard extends StatelessWidget {
  final HadithItem item;
  final String collectionName;
  final bool showArabic;
  final HadithLang lang;
  final double translationSize;

  const HadithCard({
    super.key,
    required this.item,
    required this.collectionName,
    required this.showArabic,
    required this.lang,
    required this.translationSize,
  });

  String get _shareText {
    final parts = <String>[
      if (item.arabic.isNotEmpty) item.arabic,
      if (item.translation != null) item.translation!,
      '— $collectionName، حدیث نمبر ${item.number}',
      '(ادارہ خیر العباد)',
    ];
    return parts.join('\n\n');
  }

  @override
  Widget build(BuildContext context) {
    final isUrdu = lang == HadithLang.urdu;
    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: AppColors.gold, width: 1.4),
                ),
                child: Text(
                  'حدیث ${item.number}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'کاپی',
                icon: const Icon(Icons.copy, size: 20),
                onPressed: () {
                  Clipboard.setData(ClipboardData(text: _shareText));
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('حدیث کاپی ہو گئی')),
                  );
                },
              ),
              IconButton(
                tooltip: 'شیئر',
                icon: const Icon(Icons.share, size: 20),
                onPressed: () => Share.share(_shareText),
              ),
            ],
          ),
          if (showArabic && item.arabic.isNotEmpty)
            Text(
              item.arabic,
              locale: const Locale('ar'),
              textAlign: TextAlign.right,
              textDirection: TextDirection.rtl,
              style: GoogleFonts.amiri(
                fontSize: 21,
                height: 2.1,
                color: context.cs.onSurface,
              ),
            ),
          if (item.translation != null) ...[
            if (showArabic) const Divider(height: 22),
            isUrdu
                ? Text(
                    item.translation!,
                    style: TextStyle(
                      fontSize: translationSize,
                      height: 2.3,
                      color: context.cs.onSurface.withValues(alpha: 0.9),
                    ),
                  )
                : Directionality(
                    textDirection: TextDirection.ltr,
                    child: Text(
                      item.translation!,
                      style: GoogleFonts.notoSans(
                        fontSize: translationSize - 2,
                        height: 1.7,
                        color: context.cs.onSurface.withValues(alpha: 0.9),
                      ),
                    ),
                  ),
          ],
          if (item.grades.isNotEmpty) ...[
            const SizedBox(height: 8),
            Wrap(
              spacing: 6,
              runSpacing: 4,
              children: [
                for (final g in item.grades)
                  Chip(
                    visualDensity: VisualDensity.compact,
                    label: Text(
                      g.scholar.isEmpty ? g.gradeUrdu : '${g.gradeUrdu} — ${g.scholar}',
                      style: const TextStyle(fontSize: 11),
                    ),
                  ),
              ],
            ),
          ],
          if (item.book != null && item.inBook != null && item.book != 0)
            Padding(
              padding: const EdgeInsets.only(top: 6),
              child: Text(
                '$collectionName • کتاب ${item.book} • حدیث ${item.inBook}',
                style: TextStyle(fontSize: 11.5, color: context.mutedText),
              ),
            ),
        ],
      ),
    );
  }
}
