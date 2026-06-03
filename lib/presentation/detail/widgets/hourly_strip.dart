import 'package:flutter/material.dart';

import '../../../core/utils/date_formatting.dart';
import '../../../core/utils/weather_format.dart';
import '../../../core/utils/weather_icon_mapper.dart';
import '../../../data/models/forecast_entry.dart';

/// Bande horizontale des créneaux de 3 h de la journée (données déjà chargées,
/// aucun appel réseau supplémentaire).
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.slots});

  final List<ForecastEntry> slots;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    return SizedBox(
      height: 138,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: slots.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final slot = slots[index];
          return Container(
            width: 74,
            padding: const EdgeInsets.symmetric(vertical: 14),
            decoration: BoxDecoration(
              color: theme.colorScheme.surfaceContainerHigh,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Text(
                  DateFormatting.hour(slot.time),
                  style: theme.textTheme.bodySmall,
                ),
                Icon(
                  weatherIcon(slot.condition.kind,
                      isNight: slot.condition.isNight),
                  color: weatherIconColor(slot.condition.kind),
                  size: 26,
                ),
                Text(
                  WeatherFormat.temp(slot.temp),
                  style: theme.textTheme.titleSmall
                      ?.copyWith(fontWeight: FontWeight.w700),
                ),
                if (slot.pop > 0.05)
                  Text(
                    WeatherFormat.precipitation(slot.pop),
                    style: theme.textTheme.labelSmall?.copyWith(
                      color: weatherIconColor(slot.condition.kind),
                    ),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }
}
