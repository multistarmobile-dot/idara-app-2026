import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_theme.dart';
import '../../../../shared/widgets/hero_card.dart';
import '../../../../shared/widgets/idara_app_bar.dart';
import '../../../../shared/widgets/soft_card.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final entries = <(String, String, IconData, String)>[
      ('قرآن آڈیو', 'مشاری العفاسی کی تلاوت، آیت بہ آیت', Icons.headphones, AppRoutes.quranAudio),
      ('ماہانہ نماز کیلنڈر', 'پورے مہینے کے اوقات', Icons.calendar_view_month, AppRoutes.prayerMonth),
      ('اذان کی ترتیبات', 'نماز کے وقت اذان / الارم', Icons.notifications_active, AppRoutes.azanSettings),
      ('اسلامی کیلنڈر', 'اہم تاریخیں اور رمضان ٹائم ٹیبل', Icons.calendar_month, AppRoutes.islamicCalendar),
      ('حدیث شریف', 'بخاری، مسلم، ابوداود، ترمذی، نسائی، ابن ماجہ', Icons.auto_stories, AppRoutes.hadith),
      ('قرآنی دعائیں', 'قرآن مجید کی دعائیں، کنز الایمان کے ساتھ', Icons.volunteer_activism, AppRoutes.duas),
      ('قبلہ رخ', 'کمپاس کے ساتھ قبلے کی سمت', Icons.explore, AppRoutes.qibla),
      ('ترتیبات', 'تھیم، ہجری تاریخ، قرآن پڑھنے کی ترتیب', Icons.settings, AppRoutes.settings),
      ('ہمارے بارے میں', 'ادارہ، ماخذ اور شکریہ', Icons.info_outline, AppRoutes.about),
    ];

    return Scaffold(
      appBar: idaraAppBar('مزید'),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          HeroCard(
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Image.asset(AppConstants.logoPath, height: 70, width: 70),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        AppConstants.appNameUrdu,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        AppConstants.tagline,
                        style: TextStyle(color: AppColors.goldLight),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          for (final e in entries)
            SoftCard(
              onTap: () => context.push(e.$4),
              child: Row(
                children: [
                  Icon(e.$3, color: context.cs.primary, size: 28),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(e.$1, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text(e.$2, style: TextStyle(fontSize: 12, color: context.mutedText)),
                      ],
                    ),
                  ),
                  const Icon(Icons.chevron_right),
                ],
              ),
            ),
        ],
      ),
    );
  }
}
