import 'dart:io';

import 'package:dailysky/data/services/api_exceptions.dart';
import 'package:dailysky/data/services/weather_api_service.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

/// Vérifie que les codes HTTP et erreurs réseau sont traduits en exceptions
/// typées (qui portent un message français).
void main() {
  WeatherApiService serviceReturning(int statusCode, [String body = '{}']) {
    return WeatherApiService(
      apiKey: 'test-key',
      client: MockClient(
        (_) async => http.Response(
          body,
          statusCode,
          headers: {'content-type': 'application/json'},
        ),
      ),
    );
  }

  test(
    'clé absente -> MissingApiKeyException (avant tout appel réseau)',
    () async {
      final service = WeatherApiService(
        apiKey: '',
        client: MockClient((_) async => http.Response('{}', 200)),
      );
      await expectLater(
        service.fetchByCity('Paris'),
        throwsA(isA<MissingApiKeyException>()),
      );
    },
  );

  test('401 -> InvalidApiKeyException', () async {
    await expectLater(
      serviceReturning(401).fetchByCity('Paris'),
      throwsA(isA<InvalidApiKeyException>()),
    );
  });

  test('404 -> LocationNotFoundException', () async {
    await expectLater(
      serviceReturning(404).fetchByCity('Nimporteouia'),
      throwsA(isA<LocationNotFoundException>()),
    );
  });

  test('429 -> RateLimitException', () async {
    await expectLater(
      serviceReturning(429).fetchByCity('Paris'),
      throwsA(isA<RateLimitException>()),
    );
  });

  test('500 -> ServerException', () async {
    await expectLater(
      serviceReturning(500).fetchByCity('Paris'),
      throwsA(isA<ServerException>()),
    );
  });

  test('SocketException -> NetworkException', () async {
    final service = WeatherApiService(
      apiKey: 'test-key',
      client: MockClient((_) async => throw const SocketException('offline')),
    );
    await expectLater(
      service.fetchByCity('Paris'),
      throwsA(isA<NetworkException>()),
    );
  });

  test('JSON invalide -> ParseException', () async {
    await expectLater(
      serviceReturning(200, 'pas du json').fetchByCity('Paris'),
      throwsA(isA<ParseException>()),
    );
  });

  test('200 valide -> renvoie RawWeather', () async {
    final service = WeatherApiService(
      apiKey: 'test-key',
      client: MockClient((request) async {
        final body = request.url.path.contains('forecast')
            ? '{"city":{"name":"Paris","coord":{"lat":1,"lon":2},'
                  '"timezone":0},"list":[]}'
            : '{"name":"Paris","main":{"temp":20},"weather":[]}';
        return http.Response(
          body,
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    final result = await service.fetchByCity('Paris');
    expect(result.forecast['city'], isNotNull);
    expect(result.current, isNotNull);
  });
}
