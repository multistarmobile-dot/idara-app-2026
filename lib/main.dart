import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app.dart';
import 'core/providers/app_providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();

  // Fonts pehli baar download hote hain; start par intezar karte hain taake
  // pehli screen par hi sahi font nazar aaye (internet na ho to 6 second baad aage).
  try {
    await GoogleFonts.pendingFonts([
      GoogleFonts.amiriQuran(),
      GoogleFonts.notoNastaliqUrdu(),
      GoogleFonts.notoSans(),
    ]).timeout(const Duration(seconds: 6), onTimeout: () => <void>[]);
  } catch (_) {}

  runApp(
    ProviderScope(
      overrides: [sharedPrefsProvider.overrideWithValue(prefs)],
      child: const IdaraApp(),
    ),
  );
}
