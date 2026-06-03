import 'package:flutter/material.dart';

import '../weather/weather_kind.dart';

/// Convertit une condition météo en icône Material (aucun asset, fonctionne
/// hors-ligne). Le paramètre [isNight] permet de distinguer jour et nuit pour
/// les conditions « dégagé » et « nuageux ».
IconData weatherIcon(WeatherKind kind, {required bool isNight}) {
  switch (kind) {
    case WeatherKind.clear:
      return isNight ? Icons.nightlight_round : Icons.wb_sunny;
    case WeatherKind.clouds:
      return isNight ? Icons.nights_stay : Icons.wb_cloudy;
    case WeatherKind.rain:
      return Icons.umbrella;
    case WeatherKind.drizzle:
      return Icons.grain;
    case WeatherKind.thunderstorm:
      return Icons.thunderstorm;
    case WeatherKind.snow:
      return Icons.ac_unit;
    case WeatherKind.atmosphere:
      return Icons.foggy;
  }
}

/// Couleur vive et lisible (sur fond clair comme sombre) pour teinter l'icône
/// météo affichée sur les cartes/listes.
Color weatherIconColor(WeatherKind kind) {
  switch (kind) {
    case WeatherKind.clear:
      return const Color(0xFFFFB300); // ambre
    case WeatherKind.clouds:
      return const Color(0xFF78909C); // bleu-gris
    case WeatherKind.rain:
      return const Color(0xFF42A5F5); // bleu
    case WeatherKind.drizzle:
      return const Color(0xFF4FC3F7); // bleu clair
    case WeatherKind.thunderstorm:
      return const Color(0xFF5C6BC0); // indigo
    case WeatherKind.snow:
      return const Color(0xFF4DD0E1); // cyan
    case WeatherKind.atmosphere:
      return const Color(0xFF90A4AE); // gris
  }
}
