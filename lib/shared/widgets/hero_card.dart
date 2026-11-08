import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';
import 'pattern_painter.dart';

/// Green gradient card with Islamic pattern.
class HeroCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final double radius;
  const HeroCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(20),
    this.radius = 26,
  });

  @override
  Widget build(BuildContext context) {
    final br = BorderRadius.circular(radius);
    return Container(
      decoration: BoxDecoration(
        borderRadius: br,
        gradient: const LinearGradient(
          colors: [AppColors.greenDark, AppColors.greenLight],
          begin: Alignment.topRight,
          end: Alignment.bottomLeft,
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.greenDark.withValues(alpha: 0.30),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: br,
        child: Stack(
          children: [
            Positioned.fill(
              child: CustomPaint(
                painter: PatternPainter(Colors.white.withValues(alpha: 0.08)),
              ),
            ),
            Padding(padding: padding, child: child),
          ],
        ),
      ),
    );
  }
}
