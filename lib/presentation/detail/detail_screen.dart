import 'package:flutter/material.dart';

import '../../core/theme/weather_palette.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/utils/weather_format.dart';
import '../../core/utils/weather_icon_mapper.dart';
import '../../data/models/daily_forecast.dart';
import '../weather_effects/weather_effects_layer.dart';
import 'widgets/hourly_strip.dart';
import 'widgets/metric_card.dart';

/// Écran de détail d'une journée : icône, description, min/max, et les
/// métriques (ressenti, humidité, vent, précipitations) + bande horaire.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.day, required this.cityName});

  final DailyForecast day;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final kind = day.kind;
    final palette = WeatherPalette.of(kind, isNight: day.condition.isNight);
    final mutedStyle = theme.textTheme.bodyMedium?.copyWith(
      color: theme.colorScheme.onSurfaceVariant,
    );

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: Text(DateFormatting.relativeWeekday(day.date)),
      ),
      body: Stack(
        children: [
          // Dégradé de fond d'origine (design inchangé).
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    palette.primary.withValues(alpha: 0.22),
                    theme.colorScheme.surface,
                  ],
                  stops: const [0, 0.42],
                ),
              ),
            ),
          ),
          // Effets météo animés dans la bande supérieure (fondu vers le bas).
          Positioned.fill(
            child: ShaderMask(
              shaderCallback: (rect) => const LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [Colors.white, Colors.white, Colors.transparent],
                stops: [0, 0.35, 0.6],
              ).createShader(rect),
              blendMode: BlendMode.dstIn,
              child: WeatherEffectsLayer(
                kind: kind,
                isNight: day.condition.isNight,
                intensity: 0.7,
              ),
            ),
          ),
          SafeArea(
            child: ListView(
              padding: const EdgeInsets.only(
                top: kToolbarHeight + 8,
                bottom: 28,
              ),
              children: [
                Center(
                  child: Icon(
                    weatherIcon(kind, isNight: day.condition.isNight),
                    color: weatherIconColor(kind),
                    size: 104,
                  ),
                ),
                const SizedBox(height: 10),
                Center(
                  child: Text(
                    cityName.isNotEmpty ? cityName : 'Prévision',
                    style: theme.textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Center(
                  child: Text(
                    DateFormatting.fullDate(day.date),
                    style: mutedStyle,
                  ),
                ),
                const SizedBox(height: 12),
                Center(
                  child: Text(
                    day.condition.label,
                    textAlign: TextAlign.center,
                    style: theme.textTheme.titleLarge?.copyWith(
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.baseline,
                    textBaseline: TextBaseline.alphabetic,
                    children: [
                      Text(
                        WeatherFormat.temp(day.tempMax),
                        style: theme.textTheme.displaySmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(width: 14),
                      Text(
                        WeatherFormat.temp(day.tempMin),
                        style: theme.textTheme.displaySmall?.copyWith(
                          color: theme.colorScheme.onSurfaceVariant,
                          fontWeight: FontWeight.w300,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  child: LayoutBuilder(
                    builder: (context, constraints) {
                      final width = (constraints.maxWidth - 12) / 2;
                      final cards = <Widget>[
                        MetricCard(
                          icon: Icons.thermostat_rounded,
                          label: 'Ressenti',
                          value: WeatherFormat.temp(day.feelsLike),
                        ),
                        MetricCard(
                          icon: Icons.water_drop_rounded,
                          label: 'Humidité',
                          value: WeatherFormat.humidity(day.humidity),
                        ),
                        MetricCard(
                          icon: Icons.air_rounded,
                          label: 'Vent',
                          value:
                              '${WeatherFormat.wind(day.windSpeed)} '
                              '${WeatherFormat.windDirection(day.windDeg)}',
                        ),
                        MetricCard(
                          icon: Icons.umbrella_rounded,
                          label: 'Précipitations',
                          value: WeatherFormat.precipitation(day.pop),
                        ),
                      ];
                      return Wrap(
                        spacing: 12,
                        runSpacing: 12,
                        children: [
                          for (final card in cards)
                            SizedBox(width: width, child: card),
                        ],
                      );
                    },
                  ),
                ),
                if (day.slots.length > 1) ...[
                  const SizedBox(height: 26),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Text(
                      'Au fil de la journée',
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  HourlyStrip(slots: day.slots),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}
