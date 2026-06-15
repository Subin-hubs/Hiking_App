import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/weather_model.dart';

class WeatherService {

  Future<WeatherModel> getWeather(
      double latitude,
      double longitude,
      ) async {

    final url =
        'https://api.open-meteo.com/v1/forecast'
        '?latitude=$latitude'
        '&longitude=$longitude'
        '&daily=temperature_2m_max,temperature_2m_min'
        '&forecast_days=7'
        '&timezone=auto';

    final response =
    await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      return WeatherModel.fromJson(
        jsonDecode(response.body),
      );
    }

    throw Exception(
        'Failed to load weather'
    );
  }
}