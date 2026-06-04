import 'package:dailysky/data/models/forecast_bundle.dart';
import 'package:dailysky/data/repositories/weather_repository.dart';
import 'package:dailysky/data/services/api_exceptions.dart';
import 'package:dailysky/presentation/home/home_view_model.dart';
import 'package:dailysky/presentation/state/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements WeatherRepository {
  _FakeRepository({this.bundle, this.error, this.cityError});
  final ForecastBundle? bundle;
  final Object? error;

  /// Erreur spécifique à loadForCity (si non null, prioritaire sur `error`).
  final Object? cityError;

  @override
  Future<ForecastBundle> loadForCurrentLocation() async {
    if (error != null) throw error!;
    return bundle!;
  }

  @override
  Future<ForecastBundle> loadForCity(String city) async {
    if (cityError != null) throw cityError!;
    if (error != null) throw error!;
    return bundle!;
  }
}

ForecastBundle _bundle([String city = 'Lyon']) => ForecastBundle(
  cityName: city,
  latitude: 0,
  longitude: 0,
  timezoneOffsetSeconds: 0,
  current: null,
  daily: const [],
  source: ForecastSource.search,
  fetchedAt: DateTime(2024),
);

void main() {
  test('état initial = LoadingState', () {
    final vm = HomeViewModel(_FakeRepository(bundle: _bundle()));
    expect(vm.state, isA<LoadingState<ForecastBundle>>());
  });

  test('load réussi -> SuccessState avec les données', () async {
    final vm = HomeViewModel(_FakeRepository(bundle: _bundle()));
    await vm.load();
    expect(vm.state, isA<SuccessState<ForecastBundle>>());
    expect((vm.state as SuccessState<ForecastBundle>).data.cityName, 'Lyon');
  });

  test('load en échec -> FailureState avec message en français', () async {
    final vm = HomeViewModel(_FakeRepository(error: const NetworkException()));
    await vm.load();
    expect(vm.state, isA<FailureState<ForecastBundle>>());
    expect(
      (vm.state as FailureState<ForecastBundle>).message,
      contains('connexion'),
    );
  });

  test(
    'searchCity avec une chaîne vide ne déclenche aucun chargement',
    () async {
      final vm = HomeViewModel(_FakeRepository(bundle: _bundle()));
      final result = await vm.searchCity('   ');
      expect(result, isNull);
      expect(vm.state, isA<LoadingState<ForecastBundle>>());
    },
  );

  test('searchCity réussi retourne null', () async {
    final vm = HomeViewModel(_FakeRepository(bundle: _bundle('Tokyo')));
    await vm.load();
    final result = await vm.searchCity('Tokyo');
    expect(result, isNull);
    expect(vm.state, isA<SuccessState<ForecastBundle>>());
    expect((vm.state as SuccessState<ForecastBundle>).data.cityName, 'Tokyo');
  });

  test(
    'searchCity en échec avec données existantes -> conserve les données + retourne le message d\'erreur',
    () async {
      final vm = HomeViewModel(
        _FakeRepository(
          bundle: _bundle(),
          cityError: const LocationNotFoundException(),
        ),
      );
      // D'abord on charge avec succès
      await vm.load();
      expect(vm.state, isA<SuccessState<ForecastBundle>>());

      // Puis on cherche une ville invalide
      final error = await vm.searchCity('XyzInexistant');

      // L'erreur est retournée
      expect(error, isNotNull);
      expect(error, contains('introuvable'));

      // L'état reste SuccessState avec les données précédentes
      expect(vm.state, isA<SuccessState<ForecastBundle>>());
      expect((vm.state as SuccessState<ForecastBundle>).data.cityName, 'Lyon');
    },
  );

  test(
    'searchCity en échec sans données existantes -> FailureState + retourne le message',
    () async {
      final vm = HomeViewModel(
        _FakeRepository(error: const LocationNotFoundException()),
      );
      // Pas de load préalable -> l'état est LoadingState (pas SuccessState)
      final error = await vm.searchCity('XyzInexistant');

      expect(error, isNotNull);
      expect(error, contains('introuvable'));
      expect(vm.state, isA<FailureState<ForecastBundle>>());
      expect(
        (vm.state as FailureState<ForecastBundle>).message,
        contains('introuvable'),
      );
    },
  );
}
