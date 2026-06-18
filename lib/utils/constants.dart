import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppConstants {
  // WeatherAPI.com key
  static String get weatherApiKey => dotenv.env['WEATHER_API_KEY'] ?? '';
  static const String weatherBaseUrl = 'https://api.weatherapi.com/v1/current.json';

  // Default location for home screen
  static const String defaultCity = 'Kathmandu';

  // Nepal Hiking Destinations
  static const List<Map<String, dynamic>> hikingLocations = [
    {
      'name': 'Kathmandu',
      'lat': 27.7172,
      'lon': 85.3240,
      'description': 'Capital city & gateway to the Himalayas',
      'elevation': '1,400m',
    },
    {
      'name': 'Pokhara',
      'lat': 28.2096,
      'lon': 83.9856,
      'description': 'Base for Annapurna treks',
      'elevation': '822m',
    },
    {
      'name': 'Namche Bazaar',
      'lat': 27.8069,
      'lon': 86.7139,
      'description': 'Gateway to Everest region',
      'elevation': '3,440m',
    },
    {
      'name': 'Lukla',
      'lat': 27.6869,
      'lon': 86.7314,
      'description': 'Starting point of Everest trek',
      'elevation': '2,860m',
    },
    {
      'name': 'Langtang',
      'lat': 28.2138,
      'lon': 85.5123,
      'description': 'Langtang Valley trekking',
      'elevation': '3,430m',
    },
    {
      'name': 'Manang',
      'lat': 28.6667,
      'lon': 84.0167,
      'description': 'Annapurna Circuit acclimatization stop',
      'elevation': '3,519m',
    },
    {
      'name': 'Mustang',
      'lat': 28.9966,
      'lon': 83.8581,
      'description': 'Upper Mustang forbidden kingdom trek',
      'elevation': '3,840m',
    },
    {
      'name': 'Dharan',
      'lat': 26.8120,
      'lon': 87.2836,
      'description': 'Gateway to eastern Himalayan treks',
      'elevation': '1,070m',
    },
  ];
}