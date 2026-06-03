import '../../core/utils/json_parsing.dart';
import 'current_weather.dart';
import 'daily_forecast.dart';
import 'forecast_entry.dart';

/// Origine des données affichées (sert à informer l'utilisateur).
enum ForecastSource { gps, defaultCity, search }

/// Données météo complètes prêtes pour l'affichage : météo actuelle (en-tête)
/// + prévisions journalières (liste).
class ForecastBundle {
  const ForecastBundle({
    required this.cityName,
    required this.latitude,
    required this.longitude,
    required this.timezoneOffsetSeconds,
    required this.current,
    required this.daily,
    required this.source,
    required this.fetchedAt,
    this.isStale = false,
  });

  final String cityName;
  final double latitude;
  final double longitude;
  final int timezoneOffsetSeconds;

  /// Météo actuelle ; `null` si l'appel `/weather` a échoué (mode dégradé).
  final CurrentWeather? current;
  final List<DailyForecast> daily;
  final ForecastSource source;
  final DateTime fetchedAt;

  /// Vrai si servi depuis un cache périmé (repli après échec réseau).
  final bool isStale;

  ForecastBundle copyWith({ForecastSource? source, bool? isStale}) =>
      ForecastBundle(
        cityName: cityName,
        latitude: latitude,
        longitude: longitude,
        timezoneOffsetSeconds: timezoneOffsetSeconds,
        current: current,
        daily: daily,
        source: source ?? this.source,
        fetchedAt: fetchedAt,
        isStale: isStale ?? this.isStale,
      );

  /// Construit le bundle à partir des réponses brutes de l'API et regroupe les
  /// créneaux de 3 h en prévisions journalières. C'est ici que vit la logique
  /// de regroupement (hors widgets, donc testable directement).
  factory ForecastBundle.fromApi({
    required Map<String, dynamic> forecast,
    Map<String, dynamic>? current,
    required ForecastSource source,
    DateTime? fetchedAt,
    bool isStale = false,
  }) {
    final city = forecast['city'] as Map<String, dynamic>? ?? const {};
    final coord = city['coord'] as Map<String, dynamic>? ?? const {};
    final timezone = asInt(city['timezone']);
    final rawList = forecast['list'] as List<dynamic>? ?? const [];

    final entries = rawList
        .whereType<Map<String, dynamic>>()
        .map(
          (e) => ForecastEntry.fromForecastJson(
            e,
            timezoneOffsetSeconds: timezone,
          ),
        )
        .toList();

    return ForecastBundle(
      cityName: city['name'] as String? ?? '',
      latitude: asDouble(coord['lat']),
      longitude: asDouble(coord['lon']),
      timezoneOffsetSeconds: timezone,
      current: current == null
          ? null
          : CurrentWeather.fromJson(current, timezoneOffsetSeconds: timezone),
      daily: _groupByDay(entries),
      source: source,
      fetchedAt: fetchedAt ?? DateTime.now(),
      isStale: isStale,
    );
  }

  /// Regroupe les créneaux par jour local et les agrège en `DailyForecast`.
  static List<DailyForecast> _groupByDay(List<ForecastEntry> entries) {
    // Un littéral de map Dart conserve l'ordre d'insertion.
    final buckets = <String, List<ForecastEntry>>{};
    for (final e in entries) {
      final key = '${e.time.year}-${e.time.month}-${e.time.day}';
      buckets.putIfAbsent(key, () => <ForecastEntry>[]).add(e);
    }
    return buckets.values
        .where((slots) => slots.isNotEmpty)
        .map((slots) => DailyForecast.fromSlots(slots.first.time, slots))
        .toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }
}
