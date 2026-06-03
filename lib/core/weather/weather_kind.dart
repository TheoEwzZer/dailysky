/// Grande famille de conditions météo, dérivée du code condition OpenWeatherMap.
///
/// OpenWeatherMap renvoie un identifiant numérique (`weather[].id`) dont les
/// plages sont documentées : https://openweathermap.org/weather-conditions
enum WeatherKind {
  thunderstorm,
  drizzle,
  rain,
  snow,
  atmosphere,
  clear,
  clouds;

  /// Déduit la famille à partir de l'identifiant de condition OpenWeatherMap.
  static WeatherKind fromOwmConditionId(int id) {
    if (id >= 200 && id < 300) return WeatherKind.thunderstorm;
    if (id >= 300 && id < 400) return WeatherKind.drizzle;
    if (id >= 500 && id < 600) return WeatherKind.rain;
    if (id >= 600 && id < 700) return WeatherKind.snow;
    if (id >= 700 && id < 800) return WeatherKind.atmosphere;
    if (id == 800) return WeatherKind.clear;
    return WeatherKind.clouds; // 801..804 (et repli)
  }
}
