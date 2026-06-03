import 'package:dailysky/data/models/forecast_bundle.dart';
import 'package:dailysky/data/repositories/weather_repository.dart';
import 'package:dailysky/data/services/api_exceptions.dart';
import 'package:dailysky/presentation/home/home_view_model.dart';
import 'package:dailysky/presentation/state/view_state.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakeRepository implements WeatherRepository {
  _FakeRepository({this.bundle, this.error});
  final ForecastBundle? bundle;
  final Object? error;

  @override
  Future<ForecastBundle> loadForCurrentLocation() async {
    if (error != null) throw error!;
    return bundle!;
  }

  @override
  Future<ForecastBundle> loadForCity(String city) async {
    if (error != null) throw error!;
    return bundle!;
  }
}

ForecastBundle _bundle() => ForecastBundle(
  cityName: 'Lyon',
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
      await vm.searchCity('   ');
      expect(vm.state, isA<LoadingState<ForecastBundle>>());
    },
  );
}
