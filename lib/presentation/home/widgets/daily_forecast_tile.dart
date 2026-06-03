import 'package:flutter/material.dart';

import '../../../core/routing/fade_through_route.dart';
import '../../../core/utils/date_formatting.dart';
import '../../../core/utils/weather_format.dart';
import '../../../core/utils/weather_icon_mapper.dart';
import '../../../data/models/daily_forecast.dart';
import '../../detail/detail_screen.dart';

/// Une ligne de la liste : un jour avec son icône, sa condition et ses min/max.
/// Tape -> écran de détail (transition douce + animation Hero sur l'icône).
class DailyForecastTile extends StatelessWidget {
  const DailyForecastTile({
    super.key,
    required this.day,
    required this.heroTag,
    required this.cityName,
  });

  final DailyForecast day;
  final String heroTag;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final muted = theme.colorScheme.onSurfaceVariant;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: InkWell(
        onTap: () => Navigator.of(context).push(
          FadeThroughPageRoute<void>(
            builder: (_) =>
                DetailScreen(day: day, heroTag: heroTag, cityName: cityName),
          ),
        ),
        child: Padding(
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
              Hero(
                tag: heroTag,
                child: Icon(
                  weatherIcon(day.kind, isNight: day.condition.isNight),
                  color: weatherIconColor(day.kind),
                  size: 30,
                ),
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
