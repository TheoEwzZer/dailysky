import '../../core/utils/json_parsing.dart';
import 'weather_condition.dart';

/// Un créneau de prévision de 3 h issu de l'endpoint `/forecast`.
class ForecastEntry {
  const ForecastEntry({
    required this.time,
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pop,
    required this.condition,
  });

  /// Heure locale du lieu (offset timezone déjà appliqué).
  final DateTime time;
  final double temp;
  final double feelsLike;
  final double tempMin;
  final double tempMax;
  final int humidity;
  final double windSpeed; // m/s
  final int windDeg;
  final double pop; // probabilité de précipitation 0..1
  final WeatherCondition condition;

  factory ForecastEntry.fromForecastJson(
    Map<String, dynamic> json, {
    required int timezoneOffsetSeconds,
  }) {
    final main = json['main'] as Map<String, dynamic>? ?? const {};
    final wind = json['wind'] as Map<String, dynamic>? ?? const {};
    final weather = json['weather'] as List<dynamic>? ?? const [];
    final utc = DateTime.fromMillisecondsSinceEpoch(
      asInt(json['dt']) * 1000,
      isUtc: true,
    );
    return ForecastEntry(
      // On bascule l'heure UTC vers l'heure locale du lieu en conservant le
      // drapeau UTC : les getters (.hour, .day…) renvoient ainsi l'heure murale
      // locale, ce qui est exactement ce qu'on affiche.
      time: utc.add(Duration(seconds: timezoneOffsetSeconds)),
      temp: asDouble(main['temp']),
      feelsLike: asDouble(main['feels_like']),
      tempMin: asDouble(main['temp_min']),
      tempMax: asDouble(main['temp_max']),
      humidity: asInt(main['humidity']),
      windSpeed: asDouble(wind['speed']),
      windDeg: asInt(wind['deg']),
      pop: asDouble(json['pop']),
      condition: weather.isNotEmpty
          ? WeatherCondition.fromJson(weather.first as Map<String, dynamic>)
          : const WeatherCondition(
              id: 800,
              main: 'Clear',
              description: 'ciel dégagé',
              iconCode: '01d',
            ),
    );
  }
}
