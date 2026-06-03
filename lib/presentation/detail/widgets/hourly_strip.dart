import 'package:flutter/material.dart';

import '../../../core/utils/date_formatting.dart';
import '../../../core/utils/weather_format.dart';
import '../../../data/models/forecast_entry.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/weather_glyph.dart';

/// Bande horizontale des créneaux de 3 h, en cartes « verre ».
class HourlyStrip extends StatelessWidget {
  const HourlyStrip({super.key, required this.slots});

  final List<ForecastEntry> slots;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 132,
      child: ListView.separated(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 16),
        itemCount: slots.length,
        separatorBuilder: (_, _) => const SizedBox(width: 10),
        itemBuilder: (context, index) {
          final slot = slots[index];
          return SizedBox(
            width: 72,
            child: GlassCard(
              borderRadius: 18,
              padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 4),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Text(
                    DateFormatting.hour(slot.time),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.85),
                      fontSize: 12,
                    ),
                  ),
                  WeatherGlyph(
                    iconCode: slot.condition.iconCode,
                    kind: slot.condition.kind,
                    isNight: slot.condition.isNight,
                    size: 40,
                  ),
                  Text(
                    WeatherFormat.temp(slot.temp),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 15,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
