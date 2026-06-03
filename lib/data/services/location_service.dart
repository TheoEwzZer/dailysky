import 'package:geolocator/geolocator.dart';

import '../../config/app_config.dart';

/// Coordonnées géographiques simples.
class Coords {
  const Coords(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

/// Accès à la position de l'appareil via `geolocator`.
///
/// Ne lève jamais d'exception : renvoie `null` si la localisation est
/// désactivée, refusée, indisponible ou expirée. Le repository bascule alors
/// proprement sur la ville par défaut (aucun crash).
class LocationService {
  const LocationService();

  Future<Coords?> getCurrentCoords() async {
    try {
      if (!await Geolocator.isLocationServiceEnabled()) return null;

      var permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
      if (permission == LocationPermission.denied ||
          permission == LocationPermission.deniedForever) {
        return null;
      }

      final position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.medium,
          timeLimit: AppConfig.networkTimeout,
        ),
      );
      return Coords(position.latitude, position.longitude);
    } catch (_) {
      // Timeout, service coupé en route, plateforme non supportée…
      return null;
    }
  }
}
