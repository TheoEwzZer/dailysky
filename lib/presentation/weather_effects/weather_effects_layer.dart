import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

import '../../core/weather/weather_kind.dart';
import 'weather_effects_painter.dart';

/// Couche d'effets météo animés, à placer **derrière** le contenu d'un écran
/// (le dégradé de fond reste géré par l'appelant, donc le design est conservé).
///
/// Un [Ticker] alimente en continu un [ValueNotifier] de temps consommé par le
/// peintre. Le Ticker est automatiquement suspendu par Flutter (`TickerMode`)
/// quand l'écran est masqué, et n'est pas démarré si l'utilisateur a activé
/// « réduire les animations ».
class WeatherEffectsLayer extends StatefulWidget {
  const WeatherEffectsLayer({
    super.key,
    required this.kind,
    required this.isNight,
    this.intensity = 1.0,
  });

  final WeatherKind kind;
  final bool isNight;
  final double intensity;

  @override
  State<WeatherEffectsLayer> createState() => _WeatherEffectsLayerState();
}

class _WeatherEffectsLayerState extends State<WeatherEffectsLayer>
    with SingleTickerProviderStateMixin {
  late final Ticker _ticker;
  final ValueNotifier<double> _time = ValueNotifier<double>(0);
  bool _started = false;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _time.value = elapsed.inMicroseconds / 1e6;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion && _started) {
      _ticker.stop();
      _started = false;
    } else if (!reduceMotion && !_started) {
      _ticker.start();
      _started = true;
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _time.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size.infinite,
        painter: WeatherEffectsPainter(
          time: _time,
          kind: widget.kind,
          isNight: widget.isNight,
          intensity: widget.intensity,
        ),
      ),
    );
  }
}
