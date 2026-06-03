import 'dart:ui';

import 'package:flutter/material.dart';

/// Carte « verre dépoli » (glassmorphism) : flou de l'arrière-plan + remplissage
/// blanc translucide + bordure subtile. Lisible aussi bien sur le thème clair
/// (« Ciel vivant ») que sombre (« Aurora glass »).
class GlassCard extends StatefulWidget {
  const GlassCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.borderRadius = 22,
    this.onTap,
  });

  final Widget child;
  final EdgeInsetsGeometry padding;
  final double borderRadius;
  final VoidCallback? onTap;

  @override
  State<GlassCard> createState() => _GlassCardState();
}

class _GlassCardState extends State<GlassCard> {
  ModalRoute<dynamic>? _route;
  bool _isTransitioning = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final newRoute = ModalRoute.of(context);
    if (_route != newRoute) {
      _removeRouteListeners();
      _route = newRoute;
      _addRouteListeners();
    }
    _updateTransitionState();
  }

  void _addRouteListeners() {
    _route?.animation?.addStatusListener(_onStatusChanged);
    _route?.secondaryAnimation?.addStatusListener(_onStatusChanged);
  }

  void _removeRouteListeners() {
    _route?.animation?.removeStatusListener(_onStatusChanged);
    _route?.secondaryAnimation?.removeStatusListener(_onStatusChanged);
  }

  void _onStatusChanged(AnimationStatus status) {
    _updateTransitionState();
  }

  void _updateTransitionState() {
    final route = _route;
    if (route == null) return;

    final isTransitioning = route.animation?.isAnimating == true ||
        route.secondaryAnimation?.isAnimating == true;
    if (isTransitioning != _isTransitioning) {
      setState(() {
        _isTransitioning = isTransitioning;
      });
    }
  }

  @override
  void dispose() {
    _removeRouteListeners();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final radius = BorderRadius.circular(widget.borderRadius);

    final cardContent = DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.15),
        borderRadius: radius,
        border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
      ),
      child: Material(
        type: MaterialType.transparency,
        child: InkWell(
          onTap: widget.onTap,
          borderRadius: radius,
          child: Padding(padding: widget.padding, child: widget.child),
        ),
      ),
    );

    if (_isTransitioning) {
      return ClipRRect(
        borderRadius: radius,
        child: cardContent,
      );
    }

    return ClipRRect(
      borderRadius: radius,
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 14, sigmaY: 14),
        child: cardContent,
      ),
    );
  }
}
