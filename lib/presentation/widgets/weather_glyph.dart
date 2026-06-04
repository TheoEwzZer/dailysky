import 'package:flutter/material.dart';

import '../../core/utils/weather_icon_mapper.dart';
import '../../core/weather/weather_kind.dart';

/// Affiche l'icône météo officielle OpenWeatherMap (PNG couleur), avec **repli
/// automatique** sur l'icône Material (blanche) en cas d'erreur réseau ou
/// pendant le chargement -> aucun écran vide, fonctionne hors-ligne.
class WeatherGlyph extends StatelessWidget {
  const WeatherGlyph({
    super.key,
    required this.iconCode,
    required this.kind,
    required this.isNight,
    required this.size,
  });

  final String iconCode;
  final WeatherKind kind;
  final bool isNight;
  final double size;

  @override
  Widget build(BuildContext context) {
    final fallback = Icon(
      weatherIcon(kind, isNight: isNight),
      size: size * 0.9,
      color: Colors.white,
    );

    return SizedBox(
      width: size,
      height: size,
      child: Image.network(
        owmIconUrl(iconCode),
        width: size,
        height: size,
        fit: BoxFit.contain,
        gaplessPlayback: true,
        errorBuilder: (_, _, _) => fallback,
        loadingBuilder: (context, child, progress) =>
            progress == null ? child : Center(child: fallback),
      ),
    );
  }
}
