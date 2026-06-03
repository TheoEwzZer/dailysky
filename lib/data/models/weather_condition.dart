import '../../core/utils/json_parsing.dart';
import '../../core/weather/weather_kind.dart';

/// Condition météo telle que renvoyée par OpenWeatherMap (objet `weather[0]`).
class WeatherCondition {
  const WeatherCondition({
    required this.id,
    required this.main,
    required this.description,
    required this.iconCode,
  });

  /// Identifiant de condition OpenWeatherMap (ex. 500 = pluie légère).
  final int id;

  /// Groupe brut (ex. « Rain »).
  final String main;

  /// Description détaillée, déjà en français (`lang=fr`), ex. « pluie modérée ».
  final String description;

  /// Code icône OWM (ex. « 10d », « 01n »).
  final String iconCode;

  /// Famille de condition (utilisée pour l'icône et la palette).
  WeatherKind get kind => WeatherKind.fromOwmConditionId(id);

  /// Le code icône OWM se termine par « n » la nuit, « d » le jour.
  bool get isNight => iconCode.endsWith('n');

  /// Description avec une majuscule initiale, pour l'affichage.
  String get label => description.isEmpty
      ? main
      : '${description[0].toUpperCase()}${description.substring(1)}';

  factory WeatherCondition.fromJson(Map<String, dynamic> json) {
    return WeatherCondition(
      id: asInt(json['id'], 800),
      main: json['main'] as String? ?? '',
      description: json['description'] as String? ?? '',
      iconCode: json['icon'] as String? ?? '01d',
    );
  }
}
