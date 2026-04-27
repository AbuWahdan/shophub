import 'package:flutter/material.dart';
import 'core/app/app.dart';
import 'core/app/app_initializer.dart';

Future<void> main() async {
  final providers = await AppInitializer.initialize();
  runApp(MyApp(providers: providers));
}