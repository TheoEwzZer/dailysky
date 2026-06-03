import 'dart:async';

import 'package:dailysky/data/models/forecast_bundle.dart';
import 'package:dailysky/data/repositories/weather_repository.dart';
import 'package:dailysky/presentation/home/home_screen.dart';
import 'package:dailysky/presentation/home/home_view_model.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';

class _FakeRepository implements WeatherRepository {
  _FakeRepository(this._completer);
  final Completer<ForecastBundle> _completer;

  @override
  Future<ForecastBundle> loadForCurrentLocation() => _completer.future;

  @override
  Future<ForecastBundle> loadForCity(String city) => _completer.future;
}

ForecastBundle _sampleBundle() {
  int dt(int y, int mo, int d, int h) =>
      DateTime.utc(y, mo, d, h).millisecondsSinceEpoch ~/ 1000;
  Map<String, dynamic> slot(int t) => {
    'dt': t,
    'main': {
      'temp': 20.0,
      'feels_like': 19.0,
      'temp_min': 18.0,
      'temp_max': 22.0,
      'humidity': 55,
    },
    'wind': {'speed': 3.0, 'deg': 200},
    'pop': 0.1,
    'weather': [
      {'id': 800, 'main': 'Clear', 'description': 'ciel dégagé', 'icon': '01d'},
    ],
  };
  return ForecastBundle.fromApi(
    forecast: {
      'city': {
        'name': 'Lyon',
        'coord': {'lat': 45.75, 'lon': 4.85},
        'timezone': 7200,
      },
      'list': [slot(dt(2024, 6, 3, 12)), slot(dt(2024, 6, 4, 12))],
    },
    source: ForecastSource.gps,
  );
}

Widget _wrap(WeatherRepository repo) => ChangeNotifierProvider<HomeViewModel>(
  create: (_) => HomeViewModel(repo)..load(),
  child: const MaterialApp(
    locale: Locale('fr'),
    supportedLocales: [Locale('fr')],
    localizationsDelegates: [
      GlobalMaterialLocalizations.delegate,
      GlobalWidgetsLocalizations.delegate,
      GlobalCupertinoLocalizations.delegate,
    ],
    home: HomeScreen(),
  ),
);

void main() {
  setUpAll(() => initializeDateFormatting('fr_FR'));

  testWidgets('affiche l\'indicateur de chargement au démarrage', (
    tester,
  ) async {
    // Future jamais complétée -> reste en chargement.
    await tester.pumpWidget(
      _wrap(_FakeRepository(Completer<ForecastBundle>())),
    );
    await tester.pump();
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });

  testWidgets('affiche les prévisions une fois chargées', (tester) async {
    final completer = Completer<ForecastBundle>();
    await tester.pumpWidget(_wrap(_FakeRepository(completer)));
    completer.complete(_sampleBundle());
    // Pas de pumpAndSettle : le fond animé (Ticker) tourne en continu et ne se
    // « stabiliserait » jamais. On pompe quelques frames fixes à la place.
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 50));

    expect(find.textContaining('Prévisions sur'), findsOneWidget);
    expect(find.text('Lyon'), findsWidgets);

    // Démonte l'arbre pour stopper proprement le Ticker du fond animé.
    await tester.pumpWidget(const SizedBox());
  });
}
