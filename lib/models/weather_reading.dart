import 'package:flutter/material.dart';

/// Current-conditions snapshot from Open-Meteo, keyed off the WMO weather
/// code it returns (https://open-meteo.com/en/docs — "WMO Weather interpretation codes").
class WeatherReading {
  const WeatherReading({
    required this.temperatureC,
    required this.weatherCode,
    required this.humidityPercent,
    required this.precipitationMm,
  });

  factory WeatherReading.fromJson(Map<String, dynamic> json) {
    final current = json['current'] as Map<String, dynamic>;
    return WeatherReading(
      temperatureC: (current['temperature_2m'] as num).toDouble(),
      weatherCode: (current['weather_code'] as num).toInt(),
      humidityPercent: (current['relative_humidity_2m'] as num).toInt(),
      precipitationMm: (current['precipitation'] as num).toDouble(),
    );
  }

  final double temperatureC;
  final int weatherCode;
  final int humidityPercent;
  final double precipitationMm;

  String get description {
    if (weatherCode == 0) return 'Clear sky';
    if (weatherCode <= 3) return 'Partly cloudy';
    if (weatherCode <= 48) return 'Fog';
    if (weatherCode <= 57) return 'Drizzle';
    if (weatherCode <= 67) return 'Rain';
    if (weatherCode <= 77) return 'Snow';
    if (weatherCode <= 82) return 'Rain showers';
    if (weatherCode <= 86) return 'Snow showers';
    return 'Thunderstorm';
  }

  IconData get icon {
    if (weatherCode == 0) return Icons.wb_sunny_outlined;
    if (weatherCode <= 3) return Icons.cloud_outlined;
    if (weatherCode <= 48) return Icons.blur_on;
    if (weatherCode <= 67) return Icons.water_drop_outlined;
    if (weatherCode <= 86) return Icons.ac_unit;
    return Icons.thunderstorm_outlined;
  }
}
