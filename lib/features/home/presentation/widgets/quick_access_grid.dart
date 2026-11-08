import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/router/app_router.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../shared/widgets/soft_card.dart';

class _Item {
  final String title;
  final IconData icon;
  final VoidCallback onTap;
  const _Item(this.title, this.icon, this.onTap);
}

class QuickAccessGrid extends StatelessWidget {
  const QuickAccessGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final items = <_Item>[
      _Item('قرآن پاک', Icons.menu_book, () => context.go(AppRoutes.quran)),
      _Item('قرآن آڈیو', Icons.headphones, () => context.push(AppRoutes.audio())),
      _Item('نماز کے اوقات', Icons.mosque, () => context.go(AppRoutes.prayer)),
      _Item('حدیث شریف', Icons.auto_stories, () => context.push(AppRoutes.hadith)),
      _Item('قرآنی دعائیں', Icons.volunteer_activism, () => context.push(AppRoutes.duas)),
      _Item('تسبیح', Icons.radio_button_checked, () => context.go(AppRoutes.tasbeeh)),
      _Item('قبلہ رخ', Icons.explore, () => context.push(AppRoutes.qibla)),
      _Item('اسلامی کیلنڈر', Icons.calendar_month, () => context.push(AppRoutes.islamicCalendar)),
      _Item('ترتیبات', Icons.settings, () => context.push(AppRoutes.settings)),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: items.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 10,
        mainAxisSpacing: 10,
        childAspectRatio: 0.95,
      ),
      itemBuilder: (_, i) {
        final item = items[i];
        return SoftCard(
          onTap: item.onTap,
          margin: EdgeInsets.zero,
          padding: const EdgeInsets.all(8),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: LinearGradient(
                    colors: [AppColors.greenDark, AppColors.greenLight],
                  ),
                ),
                child: Icon(item.icon, color: Colors.white, size: 22),
              ),
              const SizedBox(height: 6),
              Text(
                item.title,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12.5, fontWeight: FontWeight.bold),
              ),
            ],
          ),
        );
      },
    );
  }
}
