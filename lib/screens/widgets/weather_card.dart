import 'package:flutter/material.dart';

import '../../models/project.dart';
import '../../models/weather_reading.dart';
import '../../services/weather_service.dart';
import '../auth/auth_colors.dart';

/// Current-conditions card for the project's location, shown on the Daily
/// Progress Log screen so whoever's writing today's entry has weather
/// context handy (e.g. "rained today, work delayed"). Fetches once per
/// project (not on every parent rebuild) and fails quietly — a missing
/// location or a network hiccup shouldn't block logging progress.
class WeatherCard extends StatefulWidget {
  const WeatherCard({super.key, required this.project});

  final Project project;

  @override
  State<WeatherCard> createState() => _WeatherCardState();
}

class _WeatherCardState extends State<WeatherCard> {
  final _weatherService = WeatherService();
  Future<WeatherReading>? _future;

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(WeatherCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.project.id != widget.project.id) _load();
  }

  void _load() {
    if (!widget.project.hasCoordinates) {
      _future = null;
      return;
    }
    _future = _weatherService.getCurrentWeather(
      latitude: widget.project.latitude!,
      longitude: widget.project.longitude!,
    );
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.project.hasCoordinates) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Text(
          'No location set for this project — weather will show here once one is added.',
          style: Theme.of(
            context,
          ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
        ),
      );
    }

    return FutureBuilder<WeatherReading>(
      future: _future,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Padding(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: SizedBox(
              height: 16,
              width: 16,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
          );
        }
        if (snapshot.hasError || !snapshot.hasData) {
          return Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
            child: Text(
              "Couldn't load weather for ${widget.project.location}",
              style: Theme.of(
                context,
              ).textTheme.bodySmall?.copyWith(color: Theme.of(context).colorScheme.outline),
            ),
          );
        }

        final weather = snapshot.data!;
        return Container(
          margin: const EdgeInsets.fromLTRB(16, 0, 16, 12),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: kAuthNavy.withValues(alpha: 0.06),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: kAuthNavy.withValues(alpha: 0.15)),
          ),
          child: Row(
            children: [
              Icon(weather.icon, color: kAuthNavy, size: 32),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${weather.temperatureC.toStringAsFixed(1)}°C • ${weather.description}',
                      style: const TextStyle(fontWeight: FontWeight.w700, color: kAuthNavy),
                    ),
                    Text(
                      '${widget.project.location} • Humidity ${weather.humidityPercent}%'
                      '${weather.precipitationMm > 0 ? ' • ${weather.precipitationMm.toStringAsFixed(1)}mm rain' : ''}',
                      style: Theme.of(context).textTheme.bodySmall?.copyWith(color: kAuthNavyMuted),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
