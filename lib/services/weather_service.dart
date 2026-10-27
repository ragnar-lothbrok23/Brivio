import 'dart:convert';

import 'package:http/http.dart' as http;

import '../models/weather_reading.dart';

/// Wraps Open-Meteo's free current-weather endpoint — no API key, no
/// signup, matching the "easy" ask for a college demo.
class WeatherService {
  Future<WeatherReading> getCurrentWeather({
    required double latitude,
    required double longitude,
  }) async {
    final uri = Uri.https('api.open-meteo.com', '/v1/forecast', {
      'latitude': '$latitude',
      'longitude': '$longitude',
      'current': 'temperature_2m,relative_humidity_2m,precipitation,weather_code',
    });
    final response = await http.get(uri).timeout(const Duration(seconds: 8));
    if (response.statusCode != 200) {
      throw Exception('Weather request failed (${response.statusCode})');
    }
    return WeatherReading.fromJson(jsonDecode(response.body) as Map<String, dynamic>);
  }
}
