import 'package:flutter/material.dart';

import '../../core/theme/app_theme.dart';

class SoftCard extends StatelessWidget {
  final Widget child;
  final VoidCallback? onTap;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Color? borderColor;

  const SoftCard({
    super.key,
    required this.child,
    this.onTap,
    this.padding = const EdgeInsets.all(14),
    this.margin = const EdgeInsets.only(bottom: 10),
    this.borderColor,
  });

  @override
  Widget build(BuildContext context) {
    final dark = context.isDark;
    final radius = BorderRadius.circular(18);
    return Container(
      margin: margin,
      decoration: BoxDecoration(
        color: context.cs.surface,
        borderRadius: radius,
        border: Border.all(
          color: borderColor ??
              context.cs.primary.withValues(alpha: dark ? 0.25 : 0.10),
        ),
        boxShadow: dark
            ? null
            : [
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.05),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                ),
              ],
      ),
      child: Material(
        color: Colors.transparent,
        borderRadius: radius,
        child: InkWell(
          borderRadius: radius,
          onTap: onTap,
          child: Padding(padding: padding, child: child),
        ),
      ),
    );
  }
}
