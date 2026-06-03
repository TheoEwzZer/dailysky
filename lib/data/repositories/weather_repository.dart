import '../../config/app_config.dart';
import '../models/forecast_bundle.dart';
import '../services/api_exceptions.dart';
import '../services/location_service.dart';
import '../services/weather_api_service.dart';
import '../services/weather_cache.dart';

/// Contrat de chargement des prévisions. L'interface facilite l'injection d'un
/// double de test dans le `HomeViewModel`.
abstract interface class WeatherRepository {
  /// Météo de la position GPS ; repli automatique sur la ville par défaut.
  Future<ForecastBundle> loadForCurrentLocation();

  /// Météo d'une ville recherchée manuellement.
  Future<ForecastBundle> loadForCity(String city);
}

/// Implémentation : orchestre localisation, API et cache, et regroupe les
/// créneaux en prévisions journalières (via `ForecastBundle.fromApi`).
class WeatherRepositoryImpl implements WeatherRepository {
  WeatherRepositoryImpl({
    WeatherApiService? api,
    WeatherCache? cache,
    LocationService? location,
  }) : _api = api ?? WeatherApiService(),
       _cache = cache ?? WeatherCache(),
       _location = location ?? const LocationService();

  final WeatherApiService _api;
  final WeatherCache _cache;
  final LocationService _location;

  @override
  Future<ForecastBundle> loadForCurrentLocation() async {
    final coords = await _location.getCurrentCoords();
    if (coords != null) {
      return _load(
        cacheKey: _coordsKey(coords.latitude, coords.longitude),
        source: ForecastSource.gps,
        fetch: () =>
            _api.fetchByCoords(lat: coords.latitude, lon: coords.longitude),
      );
    }
    // Pas de position disponible : on bascule sur la ville par défaut.
    return _load(
      cacheKey: _cityKey(AppConfig.fallbackCity),
      source: ForecastSource.defaultCity,
      fetch: () => _api.fetchByCity(AppConfig.fallbackCity),
    );
  }

  @override
  Future<ForecastBundle> loadForCity(String city) {
    final trimmed = city.trim();
    return _load(
      cacheKey: _cityKey(trimmed),
      source: ForecastSource.search,
      fetch: () => _api.fetchByCity(trimmed),
    );
  }

  /// Cache frais -> retour immédiat ; sinon réseau (puis mise en cache) ; sinon,
  /// en cas d'échec réseau transitoire, repli sur le cache périmé s'il existe.
  Future<ForecastBundle> _load({
    required String cacheKey,
    required ForecastSource source,
    required Future<RawWeather> Function() fetch,
  }) async {
    final cached = await _cache.read(cacheKey);
    if (cached != null && cached.isFresh(AppConfig.cacheTtl)) {
      return ForecastBundle.fromApi(
        forecast: cached.forecast,
        current: cached.current,
        source: source,
        fetchedAt: cached.cachedAt,
      );
    }

    try {
      final raw = await fetch();
      await _cache.save(cacheKey, forecast: raw.forecast, current: raw.current);
      return ForecastBundle.fromApi(
        forecast: raw.forecast,
        current: raw.current,
        source: source,
      );
    } on WeatherException catch (e) {
      if (e.isTransient && cached != null) {
        return ForecastBundle.fromApi(
          forecast: cached.forecast,
          current: cached.current,
          source: source,
          fetchedAt: cached.cachedAt,
          isStale: true,
        );
      }
      rethrow;
    }
  }

  String _coordsKey(double lat, double lon) =>
      'coords_${lat.toStringAsFixed(2)}_${lon.toStringAsFixed(2)}';

  String _cityKey(String city) => 'city_${city.toLowerCase()}';

  void dispose() => _api.dispose();
}
