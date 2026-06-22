import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:hiking/screens/screen.dart';

import '../screens/emergency_screen.dart';
import '../screens/trail_detail_screen.dart';
import '../models/trail_model.dart';
import '../models/weather_model.dart';
import '../services/trail_service.dart';
import '../services/weather_service.dart';
import '../screens/weather_screen.dart';
import '../screens/trail_explorer_screen.dart';
import '../utils/app_theme.dart';

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
  List<TrailModel> _trails = [];
  bool _trailsLoading = true;

  final WeatherService _weatherService = WeatherService();
  final TrailService _trailService = TrailService();

  @override
  void initState() {
    super.initState();
    timer = Timer.periodic(const Duration(seconds: 3), (Timer timer) {
      setState(() {
        currentPage = (currentPage + 1) % images.length;
      });
    });
    _loadWeather();
    _loadTrails();
  }

  Future<void> _loadWeather() async {
    try {
      final weather = await _weatherService.fetchWeatherByCity('Kathmandu');
      setState(() => _weather = weather);
    } catch (e) {
      debugPrint('Weather error: $e');
    }
  }

  Future<void> _loadTrails() async {
    try {
      final trails = await _trailService.getTrails();
      setState(() {
        _trails = trails.take(2).toList();
        _trailsLoading = false;
      });
    } catch (e) {
      setState(() => _trailsLoading = false);
    }
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final imageHeight = screenHeight * 0.35;

    return Scaffold(
      backgroundColor: AppColors.surface,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ── Hero Image + Search ──
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
                  left: 20,
                  bottom: 80,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "नेपाल हाइक",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.08,
                          fontWeight: FontWeight.bold,
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 8)],
                        ),
                      ),
                      Text(
                        "Explore the beauty of Nepal",
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: screenWidth * 0.038,
                          shadows: const [Shadow(color: Colors.black54, blurRadius: 6)],
                        ),
                      ),
                    ],
                  ),
                ),
                Positioned(
                  bottom: -28,
                  left: 20,
                  right: 20,
                  child: GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const SearchScreen()),
                    ),
                    child: Container(
                      height: 56,
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(30),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.15),
                            blurRadius: 10,
                            offset: const Offset(0, 4),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 16),
                          const Icon(Icons.search, color: AppColors.mid),
                          const SizedBox(width: 10),
                          Text(
                            'Search trails, peaks...',
                            style: TextStyle(color: AppColors.text2, fontSize: 14),
                          ),
                          const Spacer(),
                          const Icon(Icons.tune, color: AppColors.mid),
                          const SizedBox(width: 16),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: 48),

            // ── Weather Card ──
            GestureDetector(
              onTap: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const WeatherScreen()),
              ),
              child: _weather == null
                  ? Container(
                margin: const EdgeInsets.symmetric(horizontal: 16),
                height: 80,
                decoration: BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppColors.border),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
                ),
                child: const Center(child: CircularProgressIndicator(color: AppColors.accent)),
              )
                  : _buildCompactWeatherCard(_weather!, screenWidth),
            ),

            const SizedBox(height: 16),

            // ── Quick Access Grid ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  Row(
                    children: [
                      _quickCard(
                        icon: Icons.gps_fixed,
                        label: 'GPS Tracking',
                        bgColor: const Color(0xFFEAF4EE),
                        iconColor: AppColors.mid,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _quickCard(
                        icon: Icons.wifi_off_rounded,
                        label: 'Offline Maps',
                        bgColor: const Color(0xFFEAF0F4),
                        iconColor: const Color(0xFF4A6FA5),
                        onTap: () {},
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _quickCard(
                        icon: Icons.flash_on_rounded,
                        label: 'Quick Access',
                        bgColor: const Color(0xFFEAF4EE),
                        iconColor: AppColors.mid,
                        onTap: () {},
                      ),
                      const SizedBox(width: 12),
                      _quickCard(
                        icon: Icons.notifications_active_rounded,
                        label: 'Emergency SOS',
                        bgColor: const Color(0xFFC0392B),
                        iconColor: Colors.white,
                        labelColor: Colors.white,
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(builder: (_) => const EmergencyScreen()),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),

            const SizedBox(height: 28),

            // ── Featured Trails ──
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    'Featured Trails',
                    style: TextStyle(
                      fontSize: screenWidth * 0.048,
                      fontWeight: FontWeight.w700,
                      color: AppColors.text1,
                    ),
                  ),
                  GestureDetector(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const TrailExplorerScreen()),
                    ),
                    child: const Text(
                      'View all →',
                      style: TextStyle(
                        color: AppColors.mid,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 12),

            _trailsLoading
                ? const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: CircularProgressIndicator(color: AppColors.accent),
              ),
            )
                : _trails.isEmpty
                ? Center(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Text('No trails found', style: TextStyle(color: AppColors.text2)),
              ),
            )
                : Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _trails.length,
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: screenWidth < 400 ? 0.75 : 0.78,
                ),
                itemBuilder: (context, index) =>
                    _trailGridCard(_trails[index], screenWidth),
              ),
            ),

            const SizedBox(height: 30),
          ],
        ),
      ),
    );
  }

  Widget _quickCard({
    required IconData icon,
    required String label,
    required Color bgColor,
    required Color iconColor,
    required VoidCallback onTap,
    Color? labelColor,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
          decoration: BoxDecoration(
            color: bgColor,
            borderRadius: BorderRadius.circular(16),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.05),
                blurRadius: 6,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: iconColor, size: 26),
              const SizedBox(height: 8),
              Text(
                label,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: labelColor ?? AppColors.text1,
                  fontWeight: FontWeight.w600,
                  fontSize: 13,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _trailGridCard(TrailModel trail, double screenWidth) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: trail)),
      ),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.border),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                child: trail.imageUrl.isNotEmpty
                    ? CachedNetworkImage(
                  imageUrl: trail.imageUrl,
                  fit: BoxFit.cover,
                  width: double.infinity,
                  placeholder: (_, __) => Container(color: AppColors.light),
                  errorWidget: (_, __, ___) => Container(
                    color: AppColors.light,
                    child: const Icon(Icons.landscape, color: AppColors.mid, size: 40),
                  ),
                )
                    : Container(
                  color: AppColors.light,
                  child: const Icon(Icons.landscape, color: AppColors.mid, size: 40),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.name,
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: screenWidth * 0.032,
                      color: AppColors.text1,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: trail.difficultyColor.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trail.difficulty,
                          style: TextStyle(
                            color: trail.difficultyColor,
                            fontSize: screenWidth * 0.024,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                      const SizedBox(width: 6),
                      Icon(Icons.schedule, size: 11, color: AppColors.text2),
                      const SizedBox(width: 2),
                      Text(
                        '${trail.duration}d',
                        style: TextStyle(color: AppColors.text2, fontSize: screenWidth * 0.026),
                      ),
                    ],
                  ),
                  const SizedBox(height: 3),
                  Row(
                    children: [
                      Icon(Icons.terrain, size: 11, color: AppColors.text2),
                      const SizedBox(width: 2),
                      Text(
                        '${trail.elevation}m',
                        style: TextStyle(color: AppColors.text2, fontSize: screenWidth * 0.026),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCompactWeatherCard(WeatherModel weather, double screenWidth) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppColors.border),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Image.network(
            weather.iconUrl,
            width: screenWidth * 0.1,
            height: screenWidth * 0.1,
            errorBuilder: (_, __, ___) =>
                Icon(Icons.wb_sunny, color: Colors.orange, size: screenWidth * 0.1),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Weather Overview',
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    color: AppColors.text1,
                  ),
                ),
                Text(
                  '${weather.cityName} · ${weather.capitalizedDescription}',
                  style: const TextStyle(color: AppColors.text2, fontSize: 12),
                ),
              ],
            ),
          ),
          Text(
            '${weather.temperature.toStringAsFixed(0)}°',
            style: TextStyle(
              fontSize: screenWidth * 0.08,
              fontWeight: FontWeight.w800,
              color: AppColors.text1,
            ),
          ),
        ],
      ),
    );
  }
}