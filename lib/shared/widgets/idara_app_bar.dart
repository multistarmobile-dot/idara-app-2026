import 'package:flutter/material.dart';

import '../../core/theme/app_colors.dart';

PreferredSizeWidget idaraAppBar(
  String title, {
  List<Widget>? actions,
  PreferredSizeWidget? bottom,
}) {
  return AppBar(
    title: Text(title),
    actions: actions,
    bottom: bottom,
    flexibleSpace: Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.greenDark, AppColors.greenLight],
          begin: Alignment.centerRight,
          end: Alignment.centerLeft,
        ),
      ),
    ),
  );
}
