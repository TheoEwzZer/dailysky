import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../data/models/forecast_bundle.dart';
import '../../shared/widgets/app_error_view.dart';
import '../../shared/widgets/app_loading_view.dart';
import '../state/view_state.dart';
import 'home_view_model.dart';
import 'widgets/city_search_sheet.dart';
import 'widgets/daily_forecast_tile.dart';
import 'widgets/weather_hero_header.dart';

/// Écran principal : liste des jours. Délègue toute la logique au ViewModel et
/// se contente d'afficher l'état courant (chargement / erreur / succès).
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

    // Erreur transitoire (échec d'un rafraîchissement) : SnackBar one-shot.
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
    final theme = Theme.of(context);
    return SafeArea(
      bottom: false,
      child: RefreshIndicator(
        onRefresh: onRefresh,
        child: ListView(
          padding: const EdgeInsets.only(bottom: 24),
          children: [
            WeatherHeroHeader(
              bundle: bundle,
              onSearch: onSearch,
              onMyLocation: onMyLocation,
            ),
            if (bundle.source == ForecastSource.defaultCity)
              _InfoBanner(
                icon: Icons.location_off_rounded,
                text:
                    'Localisation indisponible — météo de la ville par '
                    'défaut (${bundle.cityName}).',
              ),
            if (bundle.isStale)
              const _InfoBanner(
                icon: Icons.cloud_off_rounded,
                text: 'Hors-ligne : données possiblement périmées (cache).',
              ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 8),
              child: Text(
                'Prévisions sur ${bundle.daily.length} jours',
                style: theme.textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            for (final day in bundle.daily)
              DailyForecastTile(day: day, cityName: bundle.cityName),
            const SizedBox(height: 10),
            Center(
              child: Text(
                'Données fournies par OpenWeatherMap',
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSurfaceVariant,
                ),
              ),
            ),
          ],
        ),
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
    final theme = Theme.of(context);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 0),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: theme.colorScheme.secondaryContainer,
          borderRadius: BorderRadius.circular(14),
        ),
        child: Row(
          children: [
            Icon(icon, size: 18, color: theme.colorScheme.onSecondaryContainer),
            const SizedBox(width: 10),
            Expanded(
              child: Text(
                text,
                style: theme.textTheme.bodySmall?.copyWith(
                  color: theme.colorScheme.onSecondaryContainer,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
