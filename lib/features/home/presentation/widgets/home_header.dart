import 'package:flutter/material.dart';

import '../../../../core/constants/app_constants.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/hijri_utils.dart';
import '../../../../shared/widgets/pattern_painter.dart';

class HomeHeader extends StatelessWidget {
  final DateTime now;
  final int hijriOffset;
  final String city;
  final VoidCallback onCityTap;

  const HomeHeader({
    super.key,
    required this.now,
    required this.hijriOffset,
    required this.city,
    required this.onCityTap,
  });

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: const BorderRadius.vertical(bottom: Radius.circular(32)),
      child: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.greenDark, AppColors.greenLight],
            begin: Alignment.topRight,
            end: Alignment.bottomLeft,
          ),
        ),
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 14, 20, 22),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(18),
                          ),
                          child: Image.asset(
                            AppConstants.logoPath,
                            height: 64,
                            width: 64,
                            fit: BoxFit.contain,
                          ),
                        ),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'السلام علیکم',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 22,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                AppConstants.appNameUrdu,
                                style: TextStyle(color: AppColors.goldLight, fontSize: 15),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Text(
                      hijriText(now, offset: hijriOffset),
                      style: const TextStyle(color: AppColors.goldLight, fontSize: 16),
                    ),
                    Text(
                      gregorianText(now),
                      style: const TextStyle(color: Colors.white70, fontSize: 13),
                    ),
                    const SizedBox(height: 8),
                    ActionChip(
                      avatar: const Icon(Icons.location_on, size: 18, color: Colors.white),
                      label: Text(city, style: const TextStyle(color: Colors.white)),
                      backgroundColor: Colors.white.withValues(alpha: 0.18),
                      side: BorderSide.none,
                      onPressed: onCityTap,
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
