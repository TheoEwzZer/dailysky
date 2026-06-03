/// Formatage des valeurs météo pour l'affichage (unités françaises).
class WeatherFormat {
  const WeatherFormat._();

  /// Température arrondie suffixée du degré : `21°`.
  static String temp(double celsius) => '${celsius.round()}°';

  /// Température sans symbole : `21`.
  static String tempValue(double celsius) => '${celsius.round()}';

  /// Vitesse du vent convertie m/s -> km/h, arrondie : `14 km/h`.
  static String wind(double metersPerSecond) =>
      '${(metersPerSecond * 3.6).round()} km/h';

  /// Humidité : `60 %`.
  static String humidity(int percent) => '$percent %';

  /// Probabilité de précipitation (0..1) : `60 %`.
  static String precipitation(double pop) => '${(pop * 100).round()} %';

  /// Direction du vent en français : N, NE, E, SE, S, SO, O, NO.
  static String windDirection(int degrees) {
    const directions = ['N', 'NE', 'E', 'SE', 'S', 'SO', 'O', 'NO'];
    final index = (((degrees % 360) + 22) ~/ 45) % 8;
    return directions[index];
  }
}
