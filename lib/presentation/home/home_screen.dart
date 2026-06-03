import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../core/theme/weather_palette.dart';
import '../../core/weather/weather_kind.dart';
import '../../data/models/forecast_bundle.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/app_loading_view.dart';
import '../state/view_state.dart';
import '../weather_effects/weather_effects_layer.dart';
import 'home_view_model.dart';
import 'widgets/city_search_sheet.dart';
import 'widgets/daily_forecast_tile.dart';
import 'widgets/weather_hero_header.dart';

/// Écran principal immersif : fond météo plein écran + liste des jours.
class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  Future<void> _openSearch(BuildContext context) async {
    final viewModel = context.read<HomeViewModel>();
    final city = await CitySearchSheet.show(context);
    if (city != null) {
      await viewModel.searchCity(city);
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewModel = context.watch<HomeViewModel>();

    final transientError = viewModel.transientError;
    if (transientError != null) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!context.mounted) return;
        viewModel.consumeTransientError();
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(transientError)));
      });
    }

    return Scaffold(
      body: switch (viewModel.state) {
        LoadingState() => const AppLoadingView(
          message: 'Chargement de la météo…',
        ),
        FailureState(:final message) => AppErrorView(
          message: message,
          onRetry: viewModel.retry,
        ),
        SuccessState(:final data) => _SuccessView(
          bundle: data,
          onRefresh: viewModel.refresh,
          onSearch: () => _openSearch(context),
          onMyLocation: viewModel.load,
        ),
      },
    );
  }
}

class _SuccessView extends StatelessWidget {
  const _SuccessView({
    required this.bundle,
    required this.onRefresh,
    required this.onSearch,
    required this.onMyLocation,
  });

  final ForecastBundle bundle;
  final Future<void> Function() onRefresh;
  final VoidCallback onSearch;
  final VoidCallback onMyLocation;

  @override
  Widget build(BuildContext context) {
    final condition =
        bundle.current?.condition ??
        (bundle.daily.isNotEmpty ? bundle.daily.first.condition : null);
    final kind = condition?.kind ?? WeatherKind.clear;
    final isNight = condition?.isNight ?? false;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Stack(
        children: [
          Positioned.fill(
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: WeatherPalette.immersive(kind, isNight: isNight),
                ),
              ),
            ),
          ),
          Positioned.fill(
            child: WeatherEffectsLayer(kind: kind, isNight: isNight),
          ),
          RefreshIndicator(
            onRefresh: onRefresh,
            child: SafeArea(
              bottom: false,
              child: ListView(
                padding: const EdgeInsets.only(top: 8, bottom: 28),
                children: [
                  WeatherHeroHeader(
                    bundle: bundle,
                    onSearch: onSearch,
                    onMyLocation: onMyLocation,
                  ),
                  if (bundle.source == ForecastSource.defaultCity)
                    const _InfoBanner(
                      icon: Icons.location_off_rounded,
                      text: 'Localisation indisponible — ville par défaut.',
                    ),
                  if (bundle.isStale)
                    const _InfoBanner(
                      icon: Icons.cloud_off_rounded,
                      text: 'Hors-ligne : données possiblement périmées.',
                    ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(20, 20, 20, 10),
                    child: Text(
                      'Prévisions sur ${bundle.daily.length} jours',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                  for (final day in bundle.daily)
                    DailyForecastTile(day: day, cityName: bundle.cityName),
                  const SizedBox(height: 12),
                  Center(
                    child: Text(
                      'Données fournies par OpenWeatherMap',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.7),
                        fontSize: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _InfoBanner extends StatelessWidget {
  const _InfoBanner({required this.icon, required this.text});

  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 10, 20, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: Colors.white.withValues(alpha: 0.15),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: Colors.white.withValues(alpha: 0.22)),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: Colors.white),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: const TextStyle(color: Colors.white, fontSize: 13),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
