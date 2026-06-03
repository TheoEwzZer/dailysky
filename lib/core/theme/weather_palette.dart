import 'package:flutter/material.dart';

import '../weather/weather_kind.dart';

/// Palette de couleurs (dégradé d'en-tête + couleur d'accent) associée à une
/// condition météo. C'est ce qui rend l'en-tête héros « vivant » : le dégradé
/// change selon le temps et le moment de la journée.
@immutable
class WeatherPalette {
  const WeatherPalette({required this.gradient, required this.accent});

  /// Couleurs du dégradé, du haut vers le bas.
  final List<Color> gradient;

  /// Couleur d'accent lisible sur le dégradé (icône, éléments décoratifs).
  final Color accent;

  /// Couleur dominante (haut du dégradé), utile pour teinter la barre système.
  Color get primary => gradient.first;

  static WeatherPalette of(WeatherKind kind, {required bool isNight}) {
    switch (kind) {
      case WeatherKind.clear:
        return isNight ? _clearNight : _clearDay;
      case WeatherKind.clouds:
        return isNight ? _cloudsNight : _cloudsDay;
      case WeatherKind.rain:
        return _rain;
      case WeatherKind.drizzle:
        return _drizzle;
      case WeatherKind.thunderstorm:
        return _thunderstorm;
      case WeatherKind.snow:
        return _snow;
      case WeatherKind.atmosphere:
        return _atmosphere;
    }
  }

  static const _clearDay = WeatherPalette(
    gradient: [Color(0xFF1E6FE0), Color(0xFF59A5FF)],
    accent: Color(0xFFFFD54F),
  );
  static const _clearNight = WeatherPalette(
    gradient: [Color(0xFF0B1026), Color(0xFF2A3A7C)],
    accent: Color(0xFFBBC7FF),
  );
  static const _cloudsDay = WeatherPalette(
    gradient: [Color(0xFF3F60A8), Color(0xFF7892C4)],
    accent: Color(0xFFE3ECFF),
  );
  static const _cloudsNight = WeatherPalette(
    gradient: [Color(0xFF1B2436), Color(0xFF3A4761)],
    accent: Color(0xFFC2CCE0),
  );
  static const _rain = WeatherPalette(
    gradient: [Color(0xFF2C3E50), Color(0xFF4B79A1)],
    accent: Color(0xFF9FD8FF),
  );
  static const _drizzle = WeatherPalette(
    gradient: [Color(0xFF3A6073), Color(0xFF6A9CB8)],
    accent: Color(0xFFCDEEFF),
  );
  static const _thunderstorm = WeatherPalette(
    gradient: [Color(0xFF141E30), Color(0xFF3A4A63)],
    accent: Color(0xFFFFE066),
  );
  static const _snow = WeatherPalette(
    gradient: [Color(0xFF3E5C8A), Color(0xFF6E92BE)],
    accent: Color(0xFFFFFFFF),
  );
  static const _atmosphere = WeatherPalette(
    gradient: [Color(0xFF4A5568), Color(0xFF808A99)],
    accent: Color(0xFFEDF1F7),
  );
}
