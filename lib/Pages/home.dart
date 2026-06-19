import 'dart:async';

import 'package:flutter/material.dart';
import 'package:hiking/screens/emergency_screen.dart';
import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../screens/weather_screen.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  final List<String> images = [
    'assets/Home_Screen_photo/1.jpeg',
    'assets/Home_Screen_photo/2.jpeg',
    'assets/Home_Screen_photo/3.jpeg',
    'assets/Home_Screen_photo/4.jpeg',
    'assets/Home_Screen_photo/5.webp',
  ];

  int currentPage = 0;
  Timer? timer;
  WeatherModel? _weather;
  final WeatherService _weatherService = WeatherService();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        currentPage = (currentPage + 1) % images.length;
      });
    });
    _loadWeather();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.fetchWeatherByCity('Kathmandu');
      setState(() {
        _weather = weather;
      });
    } catch (e) {
      print('Weather error: $e');
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  String _getTrekTip(WeatherModel weather) {
    final desc = weather.description.toLowerCase();
    if (desc.contains('clear')) return 'Clear skies — great day for trekking!';
    if (desc.contains('cloud')) return 'Cloudy conditions — carry a rain layer.';
    if (desc.contains('rain')) return 'Rain expected — check trail conditions.';
    if (desc.contains('snow')) return 'Snow on higher passes — take care.';
    if (desc.contains('mist') || desc.contains('fog')) return 'Low visibility — stay on marked trails.';
    if (desc.contains('thunder') || desc.contains('storm')) return 'Storm warning — avoid exposed ridges.';
    return 'Check local conditions before heading out.';
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenHeight * 0.35;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              clipBehavior: Clip.none,
              children: [
                SizedBox(
                  height: imageHeight,
                  width: screenWidth,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 800),
                    transitionBuilder: (child, animation) =>
                        FadeTransition(opacity: animation, child: child),
                    layoutBuilder: (currentChild, previousChildren) => Stack(
                      fit: StackFit.expand,
                      children: [
                        ...previousChildren,
                        if (currentChild != null) currentChild,
                      ],
                    ),
                    child: Image.asset(
                      images[currentPage],
                      key: ValueKey<int>(currentPage),
                      fit: BoxFit.cover,
                      width: screenWidth,
                      height: imageHeight,
                    ),
                  ),
                ),
                Positioned(
                  bottom: -28,
                  left: 20,
                  right: 20,
                  child: Container(
                    height: 56,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(30),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.15),
                          blurRadius: 10,
                          offset: const Offset(0, 4),
                        ),
                      ],
                    ),
                    child: TextField(
                      decoration: InputDecoration(
                        hintText: 'Search trails, peaks...',
                        hintStyle: TextStyle(color: Colors.grey[400], fontSize: 14),
                        prefixIcon: const Icon(Icons.search, color: Colors.green),
                        suffixIcon: const Icon(Icons.tune, color: Colors.green),
                        border: InputBorder.none,
                        contentPadding: const EdgeInsets.symmetric(vertical: 16),
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeatherScreen()),
              ),
              child: _weather == null
                  ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                height: 160,
                decoration: BoxDecoration(
                  color: const Color(0xFF2D5A3D),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Center(
                  child: CircularProgressIndicator(color: Colors.white54),
                ),
              )
                  : _buildWeatherCard(_weather!),
            ),

            const SizedBox(height: 30),

            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => EmergencyScreen()),
              ),
              child: Text("Emergency contact")
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildWeatherCard(WeatherModel weather) {
    final summitTemp = (weather.temperature - 15).toStringAsFixed(0);
    final tip = _getTrekTip(weather);
    final windKmh = weather.windKph.toStringAsFixed(0);

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF2D5A3D),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.18),
            blurRadius: 12,
            offset: const Offset(0, 5),
          ),
        ],
      ),
      child: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(18, 16, 18, 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "TODAY'S CONDITIONS",
                  style: TextStyle(
                    color: Colors.white.withOpacity(0.65),
                    fontSize: 11,
                    letterSpacing: 1.2,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Text(
                      'Summit',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.65),
                        fontSize: 11,
                        letterSpacing: 0.5,
                      ),
                    ),
                    Text(
                      '$summitTemp°C',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.fromLTRB(18, 6, 18, 14),
            child: Align(
              alignment: Alignment.centerLeft,
              child: Text(
                weather.cityName,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 14),
            child: Row(
              children: [
                _statBox(
                  icon: Icons.thermostat,
                  value: weather.temperatureString,
                  label: 'Temp',
                ),
                const SizedBox(width: 8),
                _statBox(
                  icon: Icons.air,
                  value: '$windKmh km/h',
                  label: 'Winds',
                ),
                const SizedBox(width: 8),
                _statBox(
                  icon: Icons.water_drop_outlined,
                  value: '${weather.humidity.toInt()}%',
                  label: weather.capitalizedDescription,
                ),
              ],
            ),
          ),

          const SizedBox(height: 10),

          Container(
            margin: const EdgeInsets.fromLTRB(14, 4, 14, 14),
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded,
                    color: Color(0xFFFFCC00), size: 18),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    tip,
                    style: TextStyle(
                      color: Colors.white.withOpacity(0.85),
                      fontSize: 12.5,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _statBox({
    required IconData icon,
    required String value,
    required String label,
  }) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
        decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.1),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(icon, color: Colors.white70, size: 18),
            const SizedBox(height: 6),
            Text(
              value,
              style: const TextStyle(
                color: Colors.white,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              label,
              style: TextStyle(
                color: Colors.white.withOpacity(0.6),
                fontSize: 11,
              ),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
          ],
        ),
      ),
    );
  }
}