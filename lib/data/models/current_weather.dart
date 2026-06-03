import '../../core/utils/json_parsing.dart';
import 'weather_condition.dart';

/// Météo actuelle issue de l'endpoint `/weather`, utilisée pour l'en-tête héros.
class CurrentWeather {
  const CurrentWeather({
    required this.cityName,
    required this.time,
    required this.temp,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.condition,
  });

  final String cityName;
  final DateTime time;
  final double temp;
  final double feelsLike;
  final int humidity;
  final double windSpeed; // m/s
  final int windDeg;
  final WeatherCondition condition;

  factory CurrentWeather.fromJson(
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
    return CurrentWeather(
      cityName: json['name'] as String? ?? '',
      time: utc.add(Duration(seconds: timezoneOffsetSeconds)),
      temp: asDouble(main['temp']),
      feelsLike: asDouble(main['feels_like']),
      humidity: asInt(main['humidity']),
      windSpeed: asDouble(wind['speed']),
      windDeg: asInt(wind['deg']),
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
