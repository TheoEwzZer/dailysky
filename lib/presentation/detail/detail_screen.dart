import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../core/theme/weather_palette.dart';
import '../../core/utils/date_formatting.dart';
import '../../core/utils/weather_format.dart';
import '../../data/models/daily_forecast.dart';
import '../weather_effects/weather_effects_layer.dart';
import '../widgets/weather_glyph.dart';
import 'widgets/hourly_strip.dart';
import 'widgets/metric_card.dart';

/// Écran de détail immersif d'une journée : grande icône, température, et les
/// métriques en cartes « verre » + bande horaire.
class DetailScreen extends StatelessWidget {
  const DetailScreen({super.key, required this.day, required this.cityName});

  final DailyForecast day;
  final String cityName;

  @override
  Widget build(BuildContext context) {
    final kind = day.kind;
    final isNight = day.condition.isNight;
    const white70 = Color(0xB3FFFFFF);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          foregroundColor: Colors.white,
          title: Text(DateFormatting.relativeWeekday(day.date)),
        ),
        body: Stack(
          children: [
            Positioned.fill(
              child: DecoratedBox(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: WeatherPalette.immersive(kind, isNight: isNight),
                  ),
                ),
              ),
            ),
            Positioned.fill(
              child: WeatherEffectsLayer(kind: kind, isNight: isNight),
            ),
            SafeArea(
              child: ListView(
                padding: const EdgeInsets.only(top: 0, bottom: 28),
                children: [
                  Center(
                    child: WeatherGlyph(
                      iconCode: day.condition.iconCode,
                      kind: kind,
                      isNight: isNight,
                      size: 128,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Center(
                    child: Text(
                      cityName.isNotEmpty ? cityName : 'Prévision',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  Center(
                    child: Text(
                      DateFormatting.fullDate(day.date),
                      style: const TextStyle(color: white70, fontSize: 14),
                    ),
                  ),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      day.condition.label,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  const SizedBox(height: 8),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          WeatherFormat.temp(day.tempMax),
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 48,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(width: 14),
                        Text(
                          WeatherFormat.temp(day.tempMin),
                          style: const TextStyle(
                            color: white70,
                            fontSize: 48,
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
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 16),
                      child: Text(
                        'Au fil de la journée',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 16,
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
      ),
    );
  }
}
