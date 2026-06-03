import 'package:flutter/material.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

import 'app.dart';
import 'config/app_config.dart';
import 'data/repositories/weather_repository.dart';
import 'presentation/home/home_view_model.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Données de locale pour le formatage des dates en français.
  await initializeDateFormatting(AppConfig.locale);

  runApp(
    ChangeNotifierProvider<HomeViewModel>(
      create: (_) => HomeViewModel(WeatherRepositoryImpl())..load(),
      child: const DailySkyApp(),
    ),
  );
}
