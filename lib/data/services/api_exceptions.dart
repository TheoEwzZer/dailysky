/// Exceptions typées de la couche réseau/API météo. Le message est en français
/// et directement présentable à l'utilisateur.
sealed class WeatherException implements Exception {
  const WeatherException(this.message);
  final String message;

  /// Vrai si réessayer plus tard / avec du réseau a des chances d'aider
  /// (utilisé par le repository pour décider de servir un cache périmé).
  bool get isTransient => false;

  @override
  String toString() => 'WeatherException($message)';
}

class MissingApiKeyException extends WeatherException {
  const MissingApiKeyException()
      : super(
          "Aucune clé API configurée. Renseignez votre clé OpenWeatherMap "
          "dans env.json puis relancez l'application.",
        );
}

class InvalidApiKeyException extends WeatherException {
  const InvalidApiKeyException()
      : super(
          "Clé API invalide ou pas encore activée. Vérifiez votre clé "
          "OpenWeatherMap (l'activation peut prendre jusqu'à 2 h).",
        );
}

class LocationNotFoundException extends WeatherException {
  const LocationNotFoundException()
      : super("Ville introuvable. Vérifiez l'orthographe et réessayez.");
}

class RateLimitException extends WeatherException {
  const RateLimitException()
      : super('Trop de requêtes. Patientez un instant avant de réessayer.');
  @override
  bool get isTransient => true;
}

class ServerException extends WeatherException {
  const ServerException()
      : super('Le service météo est momentanément indisponible. '
            'Réessayez plus tard.');
  @override
  bool get isTransient => true;
}

class NetworkException extends WeatherException {
  const NetworkException()
      : super('Pas de connexion Internet. Vérifiez votre réseau et réessayez.');
  @override
  bool get isTransient => true;
}

class RequestTimeoutException extends WeatherException {
  const RequestTimeoutException()
      : super('La requête a expiré. Vérifiez votre connexion et réessayez.');
  @override
  bool get isTransient => true;
}

class ParseException extends WeatherException {
  const ParseException() : super('Réponse inattendue du serveur météo.');
}
