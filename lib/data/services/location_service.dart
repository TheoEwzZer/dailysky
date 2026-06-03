import 'package:geolocator/geolocator.dart';

import '../../config/app_config.dart';

/// Coordonnées géographiques simples.
class Coords {
  const Coords(this.latitude, this.longitude);
  final double latitude;
  final double longitude;
}

class LocationServiceDisabledException implements Exception {
  const LocationServiceDisabledException();
}

class LocationPermissionDeniedException implements Exception {
  const LocationPermissionDeniedException();
}

class LocationPermissionDeniedForeverException implements Exception {
  const LocationPermissionDeniedForeverException();
}

/// Accès à la position de l'appareil via `geolocator`.
class LocationService {
  const LocationService();

  Future<Coords?> getCurrentCoords() async {
    if (!await Geolocator.isLocationServiceEnabled()) {
      throw const LocationServiceDisabledException();
    }

    var permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
    }
    if (permission == LocationPermission.denied) {
      throw const LocationPermissionDeniedException();
    }
    if (permission == LocationPermission.deniedForever) {
      throw const LocationPermissionDeniedForeverException();
    }

    try {
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
