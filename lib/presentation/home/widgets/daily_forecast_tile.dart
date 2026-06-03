import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/date_formatting.dart';
import '../../../core/utils/weather_format.dart';
import '../../../core/utils/weather_icon_mapper.dart';
import '../../../data/models/daily_forecast.dart';
import '../../detail/detail_screen.dart';

/// Une ligne de la liste : un jour avec son icône, sa condition et ses min/max.
/// Tape → écran de détail via une transition « container transform » : la carte
/// s'agrandit/morphe en page détail (package `animations`).
class DailyForecastTile extends StatelessWidget {
  const DailyForecastTile({
    super.key,
    required this.day,
    required this.cityName,
  });

  final DailyForecast day;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    // Réglages choisis pour conserver exactement le look de la carte d'origine
    // (même couleur, même rayon, même élévation, même marge).
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: OpenContainer(
        tappable: true,
        closedElevation: 0,
        closedColor: theme.colorScheme.surfaceContainerHigh,
        openColor: theme.colorScheme.surface,
        closedShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 420),
        openBuilder: (context, _) => DetailScreen(day: day, cityName: cityName),
        closedBuilder: (context, openContainer) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          child: Row(
            children: [
              SizedBox(
                width: 88,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatting.relativeWeekday(day.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.titleMedium?.copyWith(
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatting.dayMonth(day.date),
                      style: theme.textTheme.bodySmall?.copyWith(color: muted),
                    ),
                  ],
                ),
              ),
              Icon(
                weatherIcon(day.kind, isNight: day.condition.isNight),
                color: weatherIconColor(day.kind),
                size: 30,
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      day.condition.label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: theme.textTheme.bodyMedium,
                    ),
                    if (day.pop > 0.05)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Row(
                          children: [
                            Icon(
                              Icons.water_drop_rounded,
                              size: 13,
                              color: weatherIconColor(day.kind),
                            ),
                            const SizedBox(width: 3),
                            Text(
                              WeatherFormat.precipitation(day.pop),
                              style: theme.textTheme.bodySmall?.copyWith(
                                color: muted,
                              ),
                            ),
                          ],
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                WeatherFormat.temp(day.tempMax),
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                WeatherFormat.temp(day.tempMin),
                style: theme.textTheme.titleMedium?.copyWith(color: muted),
              ),
              Icon(Icons.chevron_right_rounded, color: muted),
            ],
          ),
        ),
      ),
    );
  }
}
