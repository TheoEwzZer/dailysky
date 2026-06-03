import '../../core/weather/weather_kind.dart';
import 'forecast_entry.dart';
import 'weather_condition.dart';

/// Prévision agrégée pour une journée, construite à partir des créneaux de 3 h.
class DailyForecast {
  const DailyForecast({
    required this.date,
    required this.tempMin,
    required this.tempMax,
    required this.feelsLike,
    required this.humidity,
    required this.windSpeed,
    required this.windDeg,
    required this.pop,
    required this.condition,
    required this.slots,
  });

  /// Jour concerné (minuit, heure locale du lieu).
  final DateTime date;
  final double tempMin;
  final double tempMax;
  final double feelsLike; // ressenti représentatif (créneau de midi)
  final int humidity;
  final double windSpeed; // m/s
  final int windDeg;
  final double pop; // probabilité de précipitation max de la journée (0..1)

  /// Condition représentative de la journée (créneau le plus proche de 13 h).
  final WeatherCondition condition;

  /// Créneaux de 3 h de la journée (pour la bande horaire du détail).
  final List<ForecastEntry> slots;

  WeatherKind get kind => condition.kind;

  /// Agrège une liste de créneaux d'une même journée en une prévision.
  factory DailyForecast.fromSlots(DateTime day, List<ForecastEntry> slots) {
    assert(slots.isNotEmpty, 'fromSlots nécessite au moins un créneau');
    final ordered = [...slots]..sort((a, b) => a.time.compareTo(b.time));

    var minT = double.infinity;
    var maxT = double.negativeInfinity;
    var maxPop = 0.0;
    for (final s in ordered) {
      minT = [minT, s.tempMin, s.temp].reduce((a, b) => a < b ? a : b);
      maxT = [maxT, s.tempMax, s.temp].reduce((a, b) => a > b ? a : b);
      if (s.pop > maxPop) maxPop = s.pop;
    }

    final representative = _representativeSlot(ordered);
    return DailyForecast(
      date: DateTime(day.year, day.month, day.day),
      tempMin: minT,
      tempMax: maxT,
      feelsLike: representative.feelsLike,
      humidity: representative.humidity,
      windSpeed: representative.windSpeed,
      windDeg: representative.windDeg,
      pop: maxPop,
      condition: representative.condition,
      slots: List.unmodifiable(ordered),
    );
  }

  /// Créneau le plus proche de 13 h, le plus représentatif de la journée.
  static ForecastEntry _representativeSlot(List<ForecastEntry> slots) {
    var best = slots.first;
    var bestDistance = (best.time.hour - 13).abs();
    for (final s in slots) {
      final distance = (s.time.hour - 13).abs();
      if (distance < bestDistance) {
        bestDistance = distance;
        best = s;
      }
    }
    return best;
  }
}
