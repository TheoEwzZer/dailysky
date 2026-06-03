import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

/// Entrée de cache : réponses brutes de l'API + horodatage.
class CachedWeather {
  const CachedWeather({
    required this.cachedAt,
    required this.forecast,
    this.current,
  });

  final DateTime cachedAt;
  final Map<String, dynamic> forecast;
  final Map<String, dynamic>? current;

  bool isFresh(Duration ttl) => DateTime.now().difference(cachedAt) < ttl;
}

/// Cache local (via `shared_preferences`) des réponses brutes, par lieu.
/// Évite les requêtes inutiles et permet un repli hors-ligne.
class WeatherCache {
  WeatherCache({SharedPreferences? prefs}) : _prefsOverride = prefs;

  final SharedPreferences? _prefsOverride;
  static const String _prefix = 'weather_cache_';

  Future<SharedPreferences> get _prefs async =>
      _prefsOverride ?? await SharedPreferences.getInstance();

  Future<void> save(
    String key, {
    required Map<String, dynamic> forecast,
    Map<String, dynamic>? current,
  }) async {
    try {
      final prefs = await _prefs;
      final payload = jsonEncode({
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
        'forecast': forecast,
        'current': current,
      });
      await prefs.setString('$_prefix$key', payload);
    } catch (_) {
      // Écrire dans le cache ne doit jamais faire échouer une requête réussie.
    }
  }

  Future<CachedWeather?> read(String key) async {
    try {
      final prefs = await _prefs;
      final raw = prefs.getString('$_prefix$key');
      if (raw == null) return null;
      final map = jsonDecode(raw) as Map<String, dynamic>;
      final forecast = map['forecast'] as Map<String, dynamic>?;
      if (forecast == null) return null;
      return CachedWeather(
        cachedAt: DateTime.fromMillisecondsSinceEpoch(
          (map['cachedAt'] as num?)?.toInt() ?? 0,
        ),
        forecast: forecast,
        current: map['current'] as Map<String, dynamic>?,
      );
    } catch (_) {
      return null; // cache absent ou corrompu : on l'ignore
    }
  }
}
