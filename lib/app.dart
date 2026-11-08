import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'core/constants/app_constants.dart';
import 'core/router/app_router.dart';
import 'core/theme/app_theme.dart';
import 'features/prayer/presentation/providers/azan_providers.dart';
import 'features/settings/presentation/providers/settings_provider.dart';

class IdaraApp extends ConsumerWidget {
  const IdaraApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final router = ref.watch(routerProvider);
    ref.watch(azanSyncProvider); // azan notifications ko taza rakhta hai
    final themeMode = ref.watch(settingsProvider.select((s) => s.themeMode));

    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: AppConstants.appNameUrdu,
      routerConfig: router,
      theme: AppTheme.light(),
      darkTheme: AppTheme.dark(),
      themeMode: themeMode,
      // Poori ایپ اردو / RTL میں
      locale: const Locale('ur'),
      supportedLocales: const [Locale('ur'), Locale('ar'), Locale('en')],
      localizationsDelegates: const [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
    );
  }
}
