import 'package:dailysky/core/weather/weather_kind.dart';
import 'package:dailysky/presentation/weather_effects/weather_effects_layer.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

/// Vérifie que le fond animé se peint sans exception pour **toutes** les
/// conditions météo, de jour comme de nuit (couvre toutes les branches du
/// CustomPainter : nuages, soleil, étoiles, pluie, neige, éclair).
void main() {
  testWidgets('le fond animé se rend pour toutes les conditions (jour/nuit)', (
    tester,
  ) async {
    for (final kind in WeatherKind.values) {
      for (final isNight in [false, true]) {
        await tester.pumpWidget(
          MaterialApp(
            home: Scaffold(
              body: SizedBox(
                width: 320,
                height: 480,
                child: WeatherEffectsLayer(kind: kind, isNight: isNight),
              ),
            ),
          ),
        );
        // Deux frames : la première (~16 ms) tombe dans la fenêtre d'éclair.
        await tester.pump(const Duration(milliseconds: 16));
        await tester.pump(const Duration(milliseconds: 200));
        expect(
          tester.takeException(),
          isNull,
          reason: '$kind (night=$isNight)',
        );
      }
    }
    // Démonte l'arbre pour disposer proprement le Ticker.
    await tester.pumpWidget(const SizedBox());
  });
}
