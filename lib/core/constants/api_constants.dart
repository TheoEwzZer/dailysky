/// Points d'accès de l'API OpenWeatherMap utilisés (offre 100 % gratuite).
class ApiConstants {
  const ApiConstants._();

  static const String scheme = 'https';
  static const String host = 'api.openweathermap.org';

  /// Météo actuelle : `/data/2.5/weather`.
  static const String currentWeatherPath = '/data/2.5/weather';

  /// Prévision 5 jours par pas de 3 h : `/data/2.5/forecast`.
  /// Regroupée par jour côté application (voir `WeatherRepository`).
  static const String forecastPath = '/data/2.5/forecast';
}
