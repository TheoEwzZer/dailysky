import 'dart:math' as math;

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../core/weather/weather_kind.dart';

/// Peint les effets météo animés sur un canvas **transparent** (le dégradé de
/// fond reste géré par l'appelant, le design n'est donc pas modifié).
///
/// Le rendu dépend de la condition météo et du moment de la journée ; il est
/// piloté en continu par [time] (secondes écoulées). Les positions des
/// particules sont générées avec un [math.Random] à graine fixe → stables d'une
/// frame à l'autre, seul le temps les fait évoluer.
class WeatherEffectsPainter extends CustomPainter {
  WeatherEffectsPainter({
    required this.time,
    required this.kind,
    required this.isNight,
    this.intensity = 1.0,
  }) : super(repaint: time);

  final ValueListenable<double> time;
  final WeatherKind kind;
  final bool isNight;
  final double intensity;

  @override
  void paint(Canvas canvas, Size size) {
    final t = time.value;
    switch (kind) {
      case WeatherKind.clear:
        if (isNight) {
          _stars(canvas, size, t);
        } else {
          _sun(canvas, size, t);
        }
        _clouds(canvas, size, t, count: 2, baseAlpha: 0.08);
      case WeatherKind.clouds:
      case WeatherKind.atmosphere:
        _clouds(canvas, size, t, count: 4, baseAlpha: 0.16);
      case WeatherKind.drizzle:
        _clouds(canvas, size, t, count: 3, baseAlpha: 0.13);
        _rain(canvas, size, t, count: 24);
      case WeatherKind.rain:
        _clouds(canvas, size, t, count: 3, baseAlpha: 0.14);
        _rain(canvas, size, t, count: 40);
      case WeatherKind.thunderstorm:
        _clouds(canvas, size, t, count: 3, baseAlpha: 0.16);
        _rain(canvas, size, t, count: 38);
        _lightning(canvas, size, t);
      case WeatherKind.snow:
        _clouds(canvas, size, t, count: 3, baseAlpha: 0.13);
        _snow(canvas, size, t, count: 34);
    }
  }

  // --- Nuages : amas de cercles flous qui dérivent horizontalement. ---
  void _clouds(
    Canvas canvas,
    Size size,
    double t, {
    required int count,
    required double baseAlpha,
  }) {
    final rnd = math.Random(7);
    final paint = Paint()
      ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 12);
    for (var i = 0; i < count; i++) {
      final speed = 6 + rnd.nextDouble() * 14; // px/s
      final scale = 0.6 + rnd.nextDouble() * 0.9;
      final cloudW = size.width * 0.5 * scale;
      final y = size.height * (0.12 + rnd.nextDouble() * 0.5);
      final span = size.width + cloudW * 2.0;
      final baseX = rnd.nextDouble() * span;
      final x = ((baseX + t * speed) % span) - cloudW;
      paint.color = Colors.white.withValues(
        alpha: (baseAlpha * intensity).clamp(0, 1),
      );
      _drawCloud(canvas, Offset(x, y), cloudW, paint);
    }
  }

  void _drawCloud(Canvas canvas, Offset c, double w, Paint paint) {
    final r = w * 0.22;
    canvas.drawCircle(c, r, paint);
    canvas.drawCircle(c + Offset(r * 1.1, r * 0.3), r * 0.85, paint);
    canvas.drawCircle(c + Offset(-r * 1.1, r * 0.35), r * 0.8, paint);
    canvas.drawCircle(c + Offset(r * 0.2, -r * 0.4), r * 0.7, paint);
  }

  // --- Soleil : halo radial doux + rayons faibles tournant lentement. ---
  void _sun(Canvas canvas, Size size, double t) {
    final center = Offset(size.width * 0.84, size.height * 0.18);
    final pulse = 1 + 0.05 * math.sin(t * 1.0);
    final radius = size.shortestSide * 0.42 * pulse;
    final glow = Paint()
      ..shader = RadialGradient(
        colors: [
          Colors.white.withValues(alpha: 0.30 * intensity),
          Colors.white.withValues(alpha: 0),
        ],
      ).createShader(Rect.fromCircle(center: center, radius: radius));
    canvas.drawCircle(center, radius, glow);

    final rayPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05 * intensity)
      ..strokeWidth = 3
      ..strokeCap = StrokeCap.round;
    const rayCount = 10;
    final rotation = t * 0.15;
    for (var i = 0; i < rayCount; i++) {
      final angle = rotation + i * (2 * math.pi / rayCount);
      final inner =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius * 0.35);
      final outer =
          center + Offset(math.cos(angle), math.sin(angle)) * (radius * 0.95);
      canvas.drawLine(inner, outer, rayPaint);
    }
  }

  // --- Étoiles : points blancs scintillants. ---
  void _stars(Canvas canvas, Size size, double t) {
    final rnd = math.Random(11);
    final paint = Paint();
    for (var i = 0; i < 30; i++) {
      final x = rnd.nextDouble() * size.width;
      final y = rnd.nextDouble() * size.height * 0.8;
      final phase = rnd.nextDouble() * math.pi * 2;
      final freq = 1.5 + rnd.nextDouble() * 2;
      final twinkle = 0.4 + 0.6 * (0.5 + 0.5 * math.sin(t * freq + phase));
      paint.color = Colors.white.withValues(
        alpha: (twinkle * 0.9 * intensity).clamp(0, 1),
      );
      canvas.drawCircle(Offset(x, y), 0.8 + rnd.nextDouble() * 1.4, paint);
    }
  }

  // --- Pluie : traits légèrement obliques qui tombent. ---
  void _rain(Canvas canvas, Size size, double t, {required int count}) {
    final rnd = math.Random(23);
    final paint = Paint()
      ..color = Colors.white.withValues(alpha: 0.26 * intensity)
      ..strokeWidth = 1.6
      ..strokeCap = StrokeCap.round;
    const length = 14.0;
    const slant = 3.0;
    for (var i = 0; i < count; i++) {
      final x = rnd.nextDouble() * size.width;
      final speed = 0.9 + rnd.nextDouble() * 0.6; // proportion de hauteur/s
      final phase = rnd.nextDouble();
      final progress = (t * speed + phase) % 1.0;
      final y = progress * (size.height + length) - length;
      canvas.drawLine(Offset(x, y), Offset(x - slant, y + length), paint);
    }
  }

  // --- Neige : flocons qui descendent avec un léger balancement. ---
  void _snow(Canvas canvas, Size size, double t, {required int count}) {
    final rnd = math.Random(29);
    final paint = Paint();
    for (var i = 0; i < count; i++) {
      final baseX = rnd.nextDouble() * size.width;
      final speed = 0.16 + rnd.nextDouble() * 0.16;
      final phase = rnd.nextDouble();
      final progress = (t * speed + phase) % 1.0;
      final y = progress * (size.height + 12) - 12;
      final sway = math.sin(t * 0.8 + phase * 6) * 10;
      paint.color = Colors.white.withValues(
        alpha: (0.8 * intensity).clamp(0, 1),
      );
      canvas.drawCircle(
        Offset(baseX + sway, y),
        1.4 + rnd.nextDouble() * 2,
        paint,
      );
    }
  }

  // --- Éclair : flash blanc bref et périodique. ---
  void _lightning(Canvas canvas, Size size, double t) {
    const period = 6.0;
    final localT = t % period;
    double flash = 0;
    if (localT < 0.12) {
      flash = 1 - localT / 0.12;
    } else if (localT > 0.22 && localT < 0.32) {
      flash = (1 - (localT - 0.22) / 0.10) * 0.6;
    }
    if (flash > 0) {
      canvas.drawRect(
        Offset.zero & size,
        Paint()
          ..color = Colors.white.withValues(alpha: 0.5 * flash * intensity),
      );
    }
  }

  @override
  bool shouldRepaint(WeatherEffectsPainter oldDelegate) =>
      oldDelegate.kind != kind ||
      oldDelegate.isNight != isNight ||
      oldDelegate.intensity != intensity ||
      oldDelegate.time != time;
}
