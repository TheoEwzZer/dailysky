import 'package:flutter/foundation.dart';

import '../../data/models/forecast_bundle.dart';
import '../../data/repositories/weather_repository.dart';
import '../../data/services/api_exceptions.dart';
import '../state/view_state.dart';

/// ViewModel de l'écran principal. Aucune logique métier n'est dans les
/// widgets : tout passe par ici. Expose un `ViewState<ForecastBundle>`.
class HomeViewModel extends ChangeNotifier {
  HomeViewModel(this._repository);

  final WeatherRepository _repository;

  ViewState<ForecastBundle> _state = const LoadingState();
  ViewState<ForecastBundle> get state => _state;

  /// Message d'erreur transitoire (échec d'un rafraîchissement alors que des
  /// données sont déjà affichées) à montrer une seule fois via un SnackBar.
  String? _transientError;
  String? get transientError => _transientError;
  void consumeTransientError() => _transientError = null;

  /// Chargement initial : GPS puis repli sur la ville par défaut.
  Future<void> load() => _run(_repository.loadForCurrentLocation);

  /// Recherche d'une ville saisie par l'utilisateur.
  Future<void> searchCity(String city) {
    if (city.trim().isEmpty) return Future<void>.value();
    return _run(() => _repository.loadForCity(city));
  }

  /// Réessai depuis un état d'erreur.
  Future<void> retry() => load();

  /// Rafraîchissement (pull-to-refresh) : conserve l'affichage courant si
  /// l'opération échoue alors que des données sont déjà présentes.
  Future<void> refresh() async {
    try {
      final bundle = await _repository.loadForCurrentLocation();
      _state = SuccessState(bundle);
    } on WeatherException catch (e) {
      _handleRefreshError(e.message);
    } catch (_) {
      _handleRefreshError('Une erreur inattendue est survenue.');
    }
    notifyListeners();
  }

  void _handleRefreshError(String message) {
    if (_state is SuccessState<ForecastBundle>) {
      _transientError = message; // on garde les données, on signale l'échec
    } else {
      _state = FailureState(message);
    }
  }

  Future<void> _run(Future<ForecastBundle> Function() action) async {
    _state = const LoadingState();
    notifyListeners();
    try {
      _state = SuccessState(await action());
    } on WeatherException catch (e) {
      _state = FailureState(e.message);
    } catch (_) {
      _state = const FailureState('Une erreur inattendue est survenue.');
    }
    notifyListeners();
  }
}
