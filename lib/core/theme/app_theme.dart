import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() => _build(Brightness.light);
  static ThemeData dark() => _build(Brightness.dark);

  static ThemeData _build(Brightness brightness) {
    final dark = brightness == Brightness.dark;

    final scheme = ColorScheme.fromSeed(
      seedColor: AppColors.green,
      brightness: brightness,
    ).copyWith(
      primary: dark ? AppColors.greenLight : AppColors.green,
      secondary: AppColors.gold,
      surface: dark ? AppColors.darkSurface : Colors.white,
    );

    final base = ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: brightness,
    );

    return base.copyWith(
      scaffoldBackgroundColor:
          dark ? AppColors.darkBackground : AppColors.background,
      // Urdu: Noto Nastaliq Urdu
      textTheme: GoogleFonts.notoNastaliqUrduTextTheme(base.textTheme),
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.greenDark,
        foregroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: dark ? AppColors.darkSurface : Colors.white,
        indicatorColor: AppColors.greenLight.withValues(alpha: 0.25),
        height: 68,
      ),
      inputDecorationTheme: InputDecorationTheme(
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
      ),
    );
  }

  /// Arabic / Quran text: Amiri
  static TextStyle quran(BuildContext context, {double size = 26}) {
    final dark = Theme.of(context).brightness == Brightness.dark;
    // Amiri Quran: Uthmani rasm-ul-khat ke liye bana hai. Bold nahi lagate,
    // warna harkaat (zabar/zer/pesh) dhundhle ho jate hain.
    return GoogleFonts.amiriQuran(
      fontSize: size,
      height: 2.2,
      fontWeight: FontWeight.w400,
      letterSpacing: 0,
      color: dark ? AppColors.goldLight : AppColors.green,
    );
  }
}

extension ThemeContextX on BuildContext {
  ColorScheme get cs => Theme.of(this).colorScheme;
  bool get isDark => Theme.of(this).brightness == Brightness.dark;
  Color get mutedText => cs.onSurface.withValues(alpha: 0.6);
}
