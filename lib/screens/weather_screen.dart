import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../utils/constants.dart';

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  final WeatherService _weatherService = WeatherService();
  WeatherModel? _weather;
  List<Map<String, dynamic>> _forecast = [];
  bool _isLoading = true;
  bool _isOffline = false;
  String? _cacheTime;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadAll();
  }

  Future<void> _loadAll() async {
    setState(() { _isLoading = true; _error = null; });

    final connectivity = await Connectivity().checkConnectivity();
    final offline = connectivity == ConnectivityResult.none;
    setState(() => _isOffline = offline);

    if (offline) {
      await _loadFromCache();
    } else {
      await _fetchFresh();
    }
  }

  Future<void> _fetchFresh() async {
    try {
      final weather = await _weatherService.fetchWeatherByCity('Kathmandu');
      final forecast = await _fetchForecast('Kathmandu');
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('cached_weather', jsonEncode({
        'weather': {
          'name': weather.cityName,
          'temp': weather.temperature,
          'desc': weather.description,
          'icon': weather.iconUrl,
          'humidity': weather.humidity,
          'windKph': weather.windKph,
          'feelsLike': weather.feelsLike,
        },
        'forecast': forecast,
        'cachedAt': DateTime.now().millisecondsSinceEpoch,
      }));
      setState(() {
        _weather = weather;
        _forecast = forecast;
        _isLoading = false;
        _cacheTime = null;
      });
    } catch (e) {
      await _loadFromCache();
    }
  }

  Future<void> _loadFromCache() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final raw = prefs.getString('cached_weather');
      if (raw != null) {
        final data = jsonDecode(raw);
        final w = data['weather'];
        final cachedAt = data['cachedAt'] as int;
        final diff = DateTime.now().millisecondsSinceEpoch - cachedAt;
        final hours = (diff / 3600000).floor();
        final minutes = ((diff % 3600000) / 60000).floor();
        setState(() {
          _weather = WeatherModel(
            cityName: w['name'],
            country: 'Nepal',
            temperature: (w['temp'] as num).toDouble(),
            description: w['desc'],
            iconUrl: w['icon'],
            humidity: (w['humidity'] as num).toDouble(),
            windKph: (w['windKph'] as num).toDouble(),
            feelsLike: (w['feelsLike'] as num).toDouble(),
            condition: w['desc'],
          );
          _forecast = List<Map<String, dynamic>>.from(data['forecast'] ?? []);
          _cacheTime = hours > 0 ? '$hours hr${hours > 1 ? 's' : ''} ago' : '$minutes min ago';
          _isLoading = false;
        });
      } else {
        setState(() { _error = 'No cached data. Connect to internet.'; _isLoading = false; });
      }
    } catch (e) {
      setState(() { _error = 'Failed to load data.'; _isLoading = false; });
    }
  }

  Future<List<Map<String, dynamic>>> _fetchForecast(String city) async {
    final url = Uri.parse(
      'https://api.weatherapi.com/v1/forecast.json?key=${AppConstants.weatherApiKey}&q=$city&days=7&aqi=no',
    );
    final response = await http.get(url);
    if (response.statusCode == 200) {
      final json = jsonDecode(response.body);
      final days = json['forecast']['forecastday'] as List;
      return days.map((d) {
        final day = d['day'];
        final date = DateTime.parse(d['date']);
        return {
          'day': _dayName(date.weekday),
          'icon': 'https:${day['condition']['icon']}',
          'maxTemp': (day['maxtemp_c'] as num).toDouble(),
          'minTemp': (day['mintemp_c'] as num).toDouble(),
          'rain': (day['daily_chance_of_rain'] as num).toInt(),
        };
      }).toList();
    }
    return [];
  }

  String _dayName(int weekday) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    return days[weekday - 1];
  }

  String _getAlert(WeatherModel weather) {
    final desc = weather.description.toLowerCase();
    if (desc.contains('thunder') || desc.contains('storm')) return '⚡ Thunderstorm warning — avoid exposed ridges and summits.';
    if (desc.contains('rain') || weather.humidity > 85) return '🌧 High chance of rain — carry waterproof gear.';
    if (desc.contains('snow')) return '❄️ Snow expected on higher passes — check conditions.';
    if (desc.contains('fog') || desc.contains('mist')) return '🌫 Low visibility — stay on marked trails.';
    if (weather.windKph > 40) return '💨 Strong winds — extra caution on exposed ridges.';
    return '✅ Conditions look good for trekking today!';
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('NepalHike', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.notifications_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: Colors.green))
          : _error != null
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.cloud_off, size: 60, color: Colors.grey),
            const SizedBox(height: 16),
            Text(_error!, style: const TextStyle(color: Colors.grey)),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _loadAll,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: _loadAll,
        color: Colors.green,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Main Weather Card ──
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.green[700],
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Everest Region',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.055,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Image.network(
                          _weather!.iconUrl,
                          width: 48,
                          height: 48,
                          errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, color: Colors.white, size: 40),
                        ),
                      ],
                    ),
                    Text(
                      '${_weather!.temperature.toStringAsFixed(0)}°',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.18,
                        fontWeight: FontWeight.bold,
                        height: 1,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        _weatherStat('Tem.', '${_weather!.feelsLike.toStringAsFixed(0)}°C', screenWidth),
                        const SizedBox(width: 24),
                        _weatherStat('Wind speed', '${_weather!.windKph.toStringAsFixed(0)} km', screenWidth),
                        const SizedBox(width: 24),
                        _weatherStat('Rain', '${_weather!.humidity.toInt()}%', screenWidth),
                      ],
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // ── 7-Day Forecast ──
              Text(
                '7-day forecast',
                style: TextStyle(fontSize: screenWidth * 0.042, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              _forecast.isEmpty
                  ? Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(child: Text('No forecast data', style: TextStyle(color: Colors.grey))),
              )
                  : Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 12),
                  child: Row(
                    children: _forecast.map((day) => _forecastItem(day, screenWidth)).toList(),
                  ),
                ),
              ),

              const SizedBox(height: 12),

              // ── Cache indicator ──
              if (_cacheTime != null || _isOffline)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.access_time, size: 14, color: Colors.grey[500]),
                      const SizedBox(width: 6),
                      Text(
                        _isOffline && _cacheTime != null
                            ? 'Data cached $_cacheTime'
                            : _cacheTime != null
                            ? 'Data cached $_cacheTime'
                            : 'You are offline',
                        style: TextStyle(color: Colors.grey[600], fontSize: 12),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 20),

              // ── Weather Alerts ──
              Text(
                'Weather Alerts',
                style: TextStyle(fontSize: screenWidth * 0.042, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: [
                    BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
                  ],
                ),
                child: Text(
                  _getAlert(_weather!),
                  style: TextStyle(
                    fontSize: screenWidth * 0.036,
                    color: Colors.grey[800],
                    height: 1.5,
                  ),
                ),
              ),

              const SizedBox(height: 20),

              // ── All Hiking Locations ──
              Text(
                'Hiking Locations',
                style: TextStyle(fontSize: screenWidth * 0.042, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),

              ...AppConstants.hikingLocations.map((loc) => _locationCard(loc, screenWidth)),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _weatherStat(String label, String value, double screenWidth) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: Colors.white.withOpacity(0.7), fontSize: screenWidth * 0.028)),
        Text(value, style: TextStyle(color: Colors.white, fontSize: screenWidth * 0.036, fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _forecastItem(Map<String, dynamic> day, double screenWidth) {
    return Container(
      width: screenWidth * 0.22,
      margin: const EdgeInsets.symmetric(horizontal: 4),
      child: Column(
        children: [
          Text(
            day['day'],
            style: TextStyle(fontWeight: FontWeight.w600, fontSize: screenWidth * 0.032, color: Colors.grey[700]),
          ),
          const SizedBox(height: 8),
          Image.network(
            day['icon'],
            width: 36,
            height: 36,
            errorBuilder: (_, __, ___) => const Icon(Icons.wb_sunny, color: Colors.orange, size: 30),
          ),
          const SizedBox(height: 6),
          Text(
            '${(day['maxTemp'] as double).toStringAsFixed(0)}°',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.036),
          ),
          Text(
            '${day['rain']}rain',
            style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.026),
          ),
        ],
      ),
    );
  }

  Widget _locationCard(Map<String, dynamic> loc, double screenWidth) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 6, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: Colors.green[50],
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(Icons.landscape, color: Colors.green[700], size: 22),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  loc['name'],
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.036),
                ),
                Text(
                  loc['description'],
                  style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.028),
                ),
              ],
            ),
          ),
          Text(
            '⛰ ${loc['elevation']}',
            style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.028),
          ),
        ],
      ),
    );
  }
}