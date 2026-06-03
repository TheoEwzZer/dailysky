import 'package:dailysky/core/weather/weather_kind.dart';
import 'package:dailysky/data/models/forecast_bundle.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vérifie le regroupement des créneaux de 3 h en prévisions journalières
/// (logique métier de `ForecastBundle.fromApi`).
void main() {
  int dt(int year, int month, int day, int hour) =>
      DateTime.utc(year, month, day, hour).millisecondsSinceEpoch ~/ 1000;

  Map<String, dynamic> slot(
    int timestamp,
    double temp,
    double min,
    double max,
    int conditionId,
    String icon, {
    double pop = 0,
  }) => {
    'dt': timestamp,
    'main': {
      'temp': temp,
      'feels_like': temp - 1,
      'temp_min': min,
      'temp_max': max,
      'humidity': 60,
    },
    'wind': {'speed': 3.0, 'deg': 180},
    'pop': pop,
    'weather': [
      {'id': conditionId, 'main': 'X', 'description': 'desc', 'icon': icon},
    ],
  };

  // timezone 0 => l'heure locale = l'heure UTC, ce qui simplifie les assertions.
  final forecast = <String, dynamic>{
    'city': {
      'name': 'Testville',
      'coord': {'lat': 48.85, 'lon': 2.35},
      'timezone': 0,
    },
    'list': [
      slot(dt(2024, 6, 3, 9), 15, 14, 16, 800, '01d'),
      slot(dt(2024, 6, 3, 12), 20, 19, 21, 801, '02d'),
      slot(dt(2024, 6, 3, 15), 22, 21, 23, 500, '10d', pop: 0.4),
      slot(dt(2024, 6, 4, 12), 10, 9, 11, 600, '13d'),
    ],
  };

  test('regroupe les créneaux par jour', () {
    final bundle = ForecastBundle.fromApi(
      forecast: forecast,
      source: ForecastSource.search,
    );

    expect(bundle.cityName, 'Testville');
    expect(bundle.daily.length, 2);
    expect(bundle.daily.first.slots.length, 3);
  });

  test('calcule min/max sur l\'ensemble de la journée', () {
    final bundle = ForecastBundle.fromApi(
      forecast: forecast,
      source: ForecastSource.search,
    );

    expect(bundle.daily.first.tempMin, 14);
    expect(bundle.daily.first.tempMax, 23);
    expect(bundle.daily.first.pop, 0.4);
  });

  test(
    'choisit la condition représentative (créneau le plus proche de 13 h)',
    () {
      final bundle = ForecastBundle.fromApi(
        forecast: forecast,
        source: ForecastSource.search,
      );

      // Jour 1 : créneaux à 9 h, 12 h, 15 h -> le plus proche de 13 h est 12 h
      // (condition 801 = nuageux).
      expect(bundle.daily[0].kind, WeatherKind.clouds);
      expect(bundle.daily[1].kind, WeatherKind.snow);
    },
  );
}
