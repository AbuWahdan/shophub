import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:get/get.dart';
import 'package:provider/provider.dart';
import 'package:sinwar_shoping/src/config/route.dart';
import 'package:sinwar_shoping/src/l10n/app_localizations.dart';
import 'package:sinwar_shoping/src/state/app_settings.dart';
import 'package:sinwar_shoping/src/state/auth_state.dart';
import 'package:sinwar_shoping/src/themes/theme.dart';
import 'app_bindings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await AppSettings.load();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AuthState()..initialize(),
      child: ValueListenableBuilder<ThemeMode>(
        valueListenable: AppSettings.themeMode,
        builder: (context, themeMode, child) {
          return ValueListenableBuilder<Locale?>(
            valueListenable: AppSettings.locale,
            builder: (context, locale, child) {
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
                initialBinding: AppBindings(),
              );
            },
          );
        },
      ),
    );
  }
}
