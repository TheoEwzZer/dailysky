import 'package:flutter/material.dart';

import '../../../core/utils/weather_format.dart';
import '../../../core/utils/weather_icon_mapper.dart';
import '../../../core/weather/weather_kind.dart';
import '../../../data/models/forecast_bundle.dart';
import '../../widgets/glass_card.dart';

/// En-tête immersif : ville, grande icône, grande température, condition et une
/// carte « verre » récapitulative (ressenti / humidité / vent). Transparent —
/// le dégradé plein écran et les effets animés sont gérés par l'écran.
class WeatherHeroHeader extends StatelessWidget {
  const WeatherHeroHeader({
    super.key,
    required this.bundle,
    required this.onSearch,
    required this.onMyLocation,
  });

  final ForecastBundle bundle;
  final VoidCallback onSearch;
  final VoidCallback onMyLocation;

  @override
  Widget build(BuildContext context) {
    final current = bundle.current;
    final firstDay = bundle.daily.isNotEmpty ? bundle.daily.first : null;
    final condition = current?.condition ?? firstDay?.condition;
    final kind = condition?.kind ?? WeatherKind.clear;
    final isNight = condition?.isNight ?? false;

    final temp = current?.temp ?? firstDay?.tempMax;
    final feelsLike = current?.feelsLike ?? firstDay?.feelsLike;
    final humidity = current?.humidity ?? firstDay?.humidity;
    final wind = current?.windSpeed ?? firstDay?.windSpeed;
    final city = bundle.cityName.isNotEmpty
        ? bundle.cityName
        : (current?.cityName ?? 'Position actuelle');

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 0),
      child: Column(
        children: [
          Row(
            children: [
              const Icon(Icons.location_on, color: Colors.white, size: 22),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  city,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 26,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ),
              _GlassIconButton(
                icon: Icons.my_location_rounded,
                tooltip: 'Utiliser ma position',
                onPressed: onMyLocation,
              ),
              const SizedBox(width: 10),
              _GlassIconButton(
                icon: Icons.search_rounded,
                tooltip: 'Rechercher une ville',
                onPressed: onSearch,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Icon(
            weatherIcon(kind, isNight: isNight),
            size: 104,
            color: Colors.white,
          ),
          const SizedBox(height: 8),
          Text(
            temp != null ? WeatherFormat.temp(temp) : '—',
            style: const TextStyle(
              color: Colors.white,
              fontSize: 92,
              fontWeight: FontWeight.w200,
              height: 1,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            condition?.label ?? '',
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 18,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 22),
          GlassCard(
            padding: const EdgeInsets.symmetric(vertical: 16),
            child: Row(
              children: [
                _HeroStat(
                  icon: Icons.thermostat_rounded,
                  label: 'Ressenti',
                  value: feelsLike != null
                      ? WeatherFormat.temp(feelsLike)
                      : '—',
                ),
                _divider,
                _HeroStat(
                  icon: Icons.water_drop_rounded,
                  label: 'Humidité',
                  value: humidity != null
                      ? WeatherFormat.humidity(humidity)
                      : '—',
                ),
                _divider,
                _HeroStat(
                  icon: Icons.air_rounded,
                  label: 'Vent',
                  value: wind != null ? WeatherFormat.wind(wind) : '—',
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  static const Widget _divider = SizedBox(
    height: 34,
    child: VerticalDivider(color: Colors.white24, width: 1),
  );
}

class _GlassIconButton extends StatelessWidget {
  const _GlassIconButton({
    required this.icon,
    required this.tooltip,
    required this.onPressed,
  });

  final IconData icon;
  final String tooltip;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white.withValues(alpha: 0.18),
      shape: const CircleBorder(),
      clipBehavior: Clip.antiAlias,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon, color: Colors.white, size: 20),
        tooltip: tooltip,
        visualDensity: VisualDensity.compact,
      ),
    );
  }
}

class _HeroStat extends StatelessWidget {
  const _HeroStat({
    required this.icon,
    required this.label,
    required this.value,
  });

  final IconData icon;
  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Icon(icon, color: Colors.white, size: 20),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.8),
              fontSize: 12,
            ),
          ),
        ],
      ),
    );
  }
}
