import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:sinwar_shoping/src/config/route.dart';
import 'package:sinwar_shoping/src/themes/theme.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ShopHub - E-Commerce',
      theme: AppTheme.lightTheme.copyWith(
        textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
      ),
      darkTheme: AppTheme.darkTheme.copyWith(
        textTheme: GoogleFonts.mulishTextTheme(Theme.of(context).textTheme),
      ),
      debugShowCheckedModeBanner: false,
      routes: Routes.getRoute(),
      initialRoute: '/',
    );
  }
}
