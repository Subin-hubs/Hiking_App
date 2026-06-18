import 'package:flutter/material.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';
import '../widgets/weather_card.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  List<WeatherModel> _weatherList = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final results = await _weatherService.fetchAllHikingWeather();
      setState(() {
        _weatherList = results;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load weather data. Please try again.';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[100],
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text(
          'Nepal Hiking Weather',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _loadWeather,
          ),
        ],
      ),
      body: _isLoading
          ? const Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: Colors.green),
            SizedBox(height: 16),
            Text(
              'Fetching weather for hiking locations...',
              style: TextStyle(color: Colors.grey),
            ),
          ],
        ),
      )
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off,
                size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(
              _error!,
              style: const TextStyle(color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadWeather,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green[700],
                foregroundColor: Colors.white,
              ),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadWeather,
        color: Colors.green,
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 16),
          itemCount: _weatherList.length,
          itemBuilder: (context, index) {
            final weather = _weatherList[index];

            // Match location metadata from constants
            final locationMeta = AppConstants.hikingLocations
                .firstWhere(
                  (l) =>
              (l['lat'] as double).toStringAsFixed(2) ==
                  weather.cityName
                      .hashCode
                      .toString()
                      .substring(0, 2),
              orElse: () => AppConstants.hikingLocations[index <
                  AppConstants.hikingLocations.length
                  ? index
                  : 0],
            );

            return WeatherCard(
              weather: weather,
              elevation: locationMeta['elevation'] ?? '',
              locationDescription:
              locationMeta['description'] ?? '',
            );
          },
        ),
      ),
    );
  }
}