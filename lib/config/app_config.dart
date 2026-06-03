/// Configuration centrale de l'application.
///
/// La clé API OpenWeatherMap est injectée à la compilation via
/// `--dart-define-from-file=env.json` (voir `env.example.json`). Elle n'est
/// donc jamais codée en dur dans le code source ni committée dans le dépôt.
class AppConfig {
  const AppConfig._();

  /// Clé API OpenWeatherMap, fournie via `--dart-define-from-file=env.json`.
  static const String openWeatherApiKey = String.fromEnvironment('OWM_API_KEY');

  /// Indique si une clé API exploitable a été fournie au build.
  static bool get hasApiKey => openWeatherApiKey.trim().isNotEmpty;

  /// Système d'unités OpenWeatherMap : `metric` => °C et m/s.
  static const String units = 'metric';

  /// Langue demandée à l'API pour les descriptions météo.
  static const String apiLanguage = 'fr';

  /// Locale utilisée pour le formatage des dates et de l'interface.
  static const String locale = 'fr_FR';

  /// Ville de repli lorsque la géolocalisation est indisponible ou refusée.
  static const String fallbackCity = 'Paris';

  /// Durée de validité du cache météo (au-delà, on rafraîchit).
  static const Duration cacheTtl = Duration(minutes: 30);

  /// Délai maximal accordé à un appel réseau avant abandon.
  static const Duration networkTimeout = Duration(seconds: 10);
}
