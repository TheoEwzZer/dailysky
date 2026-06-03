import 'package:animations/animations.dart';
import 'package:flutter/material.dart';

import '../../../core/utils/date_formatting.dart';
import '../../../core/utils/weather_format.dart';
import '../../../data/models/daily_forecast.dart';
import '../../detail/detail_screen.dart';
import '../../widgets/glass_card.dart';
import '../../widgets/weather_glyph.dart';

/// Ligne de prévision en carte « verre ». Tape → détail via « container
/// transform » (la carte s'agrandit en page détail).
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
    const white70 = Color(0xB3FFFFFF);

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 5),
      child: OpenContainer(
        tappable: false,
        closedElevation: 0,
        closedColor: Colors.transparent,
        openColor: Colors.transparent,
        closedShape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(20)),
        ),
        transitionType: ContainerTransitionType.fadeThrough,
        transitionDuration: const Duration(milliseconds: 420),
        openBuilder: (context, _) => DetailScreen(day: day, cityName: cityName),
        closedBuilder: (context, openContainer) => GlassCard(
          borderRadius: 20,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          onTap: openContainer,
          child: Row(
            children: [
              SizedBox(
                width: 92,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      DateFormatting.relativeWeekday(day.date),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                        fontSize: 15,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      DateFormatting.dayMonth(day.date),
                      style: const TextStyle(color: white70, fontSize: 12),
                    ),
                  ],
                ),
              ),
              WeatherGlyph(
                iconCode: day.condition.iconCode,
                kind: day.kind,
                isNight: day.condition.isNight,
                size: 42,
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
                      style: const TextStyle(color: Colors.white, fontSize: 14),
                    ),
                    if (day.pop > 0.05)
                      Padding(
                        padding: const EdgeInsets.only(top: 2),
                        child: Text(
                          '${WeatherFormat.precipitation(day.pop)} pluie',
                          style: const TextStyle(color: white70, fontSize: 12),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              Text(
                WeatherFormat.temp(day.tempMax),
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                  fontSize: 16,
                ),
              ),
              const SizedBox(width: 6),
              Text(
                WeatherFormat.temp(day.tempMin),
                style: const TextStyle(color: white70, fontSize: 16),
              ),
              const Icon(Icons.chevron_right_rounded, color: white70),
            ],
          ),
        ),
      ),
    );
  }
}
