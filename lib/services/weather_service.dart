import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';
import '../utils/constants.dart';

class WeatherService {
  Future<WeatherModel> fetchWeatherByCity(String city) async {
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}?key=${AppConstants.weatherApiKey}&q=$city&aqi=no',
    );

    final response = await http.get(url);

    print('🌤 Status: ${response.statusCode}');
    print('🌤 Body: ${response.body}');

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherModel.fromJson(json);
    } else {
      throw Exception('Failed to load weather for $city — ${response.statusCode}: ${response.body}');
    }
  }

  Future<WeatherModel> fetchWeatherByLatLon(double lat, double lon) async {
    final url = Uri.parse(
      '${AppConstants.weatherBaseUrl}?key=${AppConstants.weatherApiKey}&q=$lat,$lon&aqi=no',
    );

    final response = await http.get(url);

    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      return WeatherModel.fromJson(json);
    } else {
      throw Exception('Failed to load weather for ($lat, $lon) — ${response.statusCode}');
    }
  }

  Future<List<WeatherModel>> fetchAllHikingWeather() async {
    final List<WeatherModel> results = [];

    for (final location in AppConstants.hikingLocations) {
      try {
        final weather = await fetchWeatherByLatLon(
          location['lat'],
          location['lon'],
        );
        results.add(weather);
      } catch (e) {
        print('⚠️ Skipped ${location['name']}: $e');
      }
    }

    return results;
  }
}