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
  final Stopwatch _stopwatch = Stopwatch();
  bool _started = false;
  ModalRoute<dynamic>? _route;

  @override
  void initState() {
    super.initState();
    _ticker = createTicker((elapsed) {
      _time.value = _stopwatch.elapsedMicroseconds / 1e6;
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRoute = ModalRoute.of(context);
    if (_route != newRoute) {
      _removeRouteListeners();
      _route = newRoute;
      _addRouteListeners();
    }
    _updateTickerState();
  }

  void _addRouteListeners() {
    _route?.animation?.addListener(_onRouteAnimationTick);
    _route?.secondaryAnimation?.addListener(_onRouteAnimationTick);
  }

  void _removeRouteListeners() {
    _route?.animation?.removeListener(_onRouteAnimationTick);
    _route?.secondaryAnimation?.removeListener(_onRouteAnimationTick);
  }

  void _onRouteAnimationTick() {
    _updateTickerState();
  }

  void _updateTickerState() {
    if (!mounted) return;

    final reduceMotion = MediaQuery.maybeDisableAnimationsOf(context) ?? false;
    if (reduceMotion) {
      if (_started) {
        _stopwatch.stop();
        _ticker.stop();
        _started = false;
      }
      return;
    }

    final route = _route;
    final isTransitioning =
        route?.animation?.isAnimating == true ||
        route?.secondaryAnimation?.isAnimating == true;
    final isCurrent = route?.isCurrent ?? true;
    final shouldRun = isCurrent && !isTransitioning;

    if (shouldRun && !_started) {
      _stopwatch.start();
      _ticker.start();
      _started = true;
    } else if (!shouldRun && _started) {
      _stopwatch.stop();
      _ticker.stop();
      _started = false;
    }
  }

  @override
  void dispose() {
    _removeRouteListeners();
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
