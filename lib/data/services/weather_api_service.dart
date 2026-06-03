import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

import '../../config/app_config.dart';
import '../../core/constants/api_constants.dart';
import 'api_exceptions.dart';

/// Réponses brutes (non parsées) de l'API. La prévision est obligatoire ; la
/// météo actuelle est « best effort » (peut être `null` si son appel a échoué).
class RawWeather {
  const RawWeather({required this.forecast, this.current});
  final Map<String, dynamic> forecast;
  final Map<String, dynamic>? current;
}

/// Accès HTTP à OpenWeatherMap. Ne contient aucune logique d'affichage : il
/// effectue les requêtes, applique un timeout et lève des exceptions typées.
class WeatherApiService {
  WeatherApiService({http.Client? client, String? apiKey})
    : _client = client ?? http.Client(),
      _apiKey = apiKey ?? AppConfig.openWeatherApiKey;

  final http.Client _client;
  final String _apiKey;

  Future<RawWeather> fetchByCoords({
    required double lat,
    required double lon,
  }) => _fetch({'lat': '$lat', 'lon': '$lon'});

  Future<RawWeather> fetchByCity(String city) => _fetch({'q': city});

  Future<RawWeather> _fetch(Map<String, String> locationQuery) async {
    if (_apiKey.trim().isEmpty) throw const MissingApiKeyException();

    final query = {
      ...locationQuery,
      'appid': _apiKey,
      'units': AppConfig.units,
      'lang': AppConfig.apiLanguage,
    };
    final forecastUri = _uri(ApiConstants.forecastPath, query);
    final currentUri = _uri(ApiConstants.currentWeatherPath, query);

    // Les deux appels en parallèle : forecast obligatoire, current best effort.
    final results = await Future.wait([
      _getJson(forecastUri),
      _getJsonOrNull(currentUri),
    ]);

    return RawWeather(forecast: results[0]!, current: results[1]);
  }

  Uri _uri(String path, Map<String, String> query) => Uri(
    scheme: ApiConstants.scheme,
    host: ApiConstants.host,
    path: path,
    queryParameters: query,
  );

  Future<Map<String, dynamic>> _getJson(Uri uri) async {
    final http.Response response;
    try {
      response = await _client.get(uri).timeout(AppConfig.networkTimeout);
    } on TimeoutException {
      throw const RequestTimeoutException();
    } on SocketException {
      throw const NetworkException();
    } on http.ClientException {
      throw const NetworkException();
    }

    _throwForStatus(response.statusCode);

    try {
      final decoded = jsonDecode(response.body);
      if (decoded is Map<String, dynamic>) return decoded;
      throw const ParseException();
    } on FormatException {
      throw const ParseException();
    }
  }

  /// Variante tolérante : renvoie `null` au lieu de lever (pour la météo
  /// actuelle, dont l'échec ne doit pas faire échouer toute la requête).
  Future<Map<String, dynamic>?> _getJsonOrNull(Uri uri) async {
    try {
      return await _getJson(uri);
    } on WeatherException {
      return null;
    }
  }

  void _throwForStatus(int statusCode) {
    if (statusCode == 200) return;
    switch (statusCode) {
      case 401:
        throw const InvalidApiKeyException();
      case 404:
        throw const LocationNotFoundException();
      case 429:
        throw const RateLimitException();
      default:
        throw const ServerException();
    }
  }

  void dispose() => _client.close();
}
