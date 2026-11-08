import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/soft_card.dart';
import '../../domain/entities/ayah.dart';

class AyahTile extends StatelessWidget {
  final Ayah ayah;
  final double fontSize;
  final double translationSize;
  final bool showUrdu;
  final bool showEnglish;
  final bool bookmarked;
  final VoidCallback onBookmark;
  final VoidCallback onCopy;
  final VoidCallback onShare;

  const AyahTile({
    super.key,
    required this.ayah,
    required this.fontSize,
    required this.translationSize,
    required this.showUrdu,
    required this.showEnglish,
    required this.bookmarked,
    required this.onBookmark,
    required this.onCopy,
    required this.onShare,
  });

  @override
  Widget build(BuildContext context) {
    final urdu = ayah.translations[QuranEdition.urdu];
    final english = ayah.translations[QuranEdition.english];

    return SoftCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Container(
                width: 34,
                height: 34,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.gold, width: 1.5),
                ),
                child: Text(
                  '${ayah.number}',
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                ),
              ),
              const Spacer(),
              IconButton(
                tooltip: 'نشان',
                icon: Icon(
                  bookmarked ? Icons.bookmark : Icons.bookmark_border,
                  color: bookmarked ? AppColors.gold : null,
                ),
                onPressed: onBookmark,
              ),
              IconButton(
                tooltip: 'کاپی',
                icon: const Icon(Icons.copy, size: 20),
                onPressed: onCopy,
              ),
              IconButton(
                tooltip: 'شیئر',
                icon: const Icon(Icons.share, size: 20),
                onPressed: onShare,
              ),
            ],
          ),
          Text(
            ayah.arabic,
            locale: const Locale('ar'),
            textAlign: TextAlign.right,
            textDirection: TextDirection.rtl,
            style: AppTheme.quran(context, size: fontSize),
          ),
          if (showUrdu && urdu != null) ...[
            const Divider(height: 24),
            Text(
              urdu,
              style: TextStyle(
                fontSize: translationSize,
                height: 2.3,
                color: context.cs.onSurface.withValues(alpha: 0.88),
              ),
            ),
          ],
          if (showEnglish && english != null) ...[
            const Divider(height: 24),
            Directionality(
              textDirection: TextDirection.ltr,
              child: Text(
                english,
                style: GoogleFonts.notoSans(
                  fontSize: translationSize - 2,
                  height: 1.7,
                  color: context.cs.onSurface.withValues(alpha: 0.85),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}
