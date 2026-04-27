import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:provider/single_child_widget.dart';

import '../../l10n/app_localizations.dart';
import '../../src/config/route.dart';
import '../../src/state/app_settings.dart';
import 'app_theme.dart';

class MyApp extends StatelessWidget {
  final List<SingleChildWidget> providers;

  const MyApp({super.key, required this.providers});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: providers,
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppSettings.themeMode,
        builder: (context, themeMode, _) {
          return ValueListenableBuilder<Locale?>(
            valueListenable: AppSettings.locale,
            builder: (context, locale, _) {
              return GetMaterialApp(
                onGenerateTitle: (context) =>
                AppLocalizations.of(context).appTitle,
                theme: AppTheme.lightTheme,
                darkTheme: AppTheme.darkTheme,
                themeMode: themeMode,
                locale: locale,
                supportedLocales: AppLocalizations.supportedLocales,
                localizationsDelegates: const [
                  AppLocalizations.delegate,
                  GlobalMaterialLocalizations.delegate,
                  GlobalWidgetsLocalizations.delegate,
                  GlobalCupertinoLocalizations.delegate,
                ],
                debugShowCheckedModeBanner: false,
                onGenerateRoute: AppRoutes.onGenerateRoute,
                initialRoute: AppRoutes.splash,
              );
            },
          );
        },
      ),
    );
  }
}