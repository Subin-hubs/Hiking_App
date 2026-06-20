import 'package:cached_network_image/cached_network_image.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import '../models/trail_model.dart';

class TrailDetailScreen extends StatefulWidget {
  final TrailModel trail;
  const TrailDetailScreen({super.key, required this.trail});

  @override
  State<TrailDetailScreen> createState() => _TrailDetailScreenState();
}

class _TrailDetailScreenState extends State<TrailDetailScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  List<FlSpot> _generateElevationSpots() {
    final int distance = widget.trail.distance.toInt();
    final int maxElev = widget.trail.elevation;
    final List<FlSpot> spots = [];
    final int points = 10;
    for (int i = 0; i <= points; i++) {
      final double x = (distance / points) * i;
      double progress = i / points;
      double y;
      if (progress < 0.3) {
        y = (maxElev * 0.2) + (maxElev * 0.4 * (progress / 0.3));
      } else if (progress < 0.7) {
        y = (maxElev * 0.6) + (maxElev * 0.35 * ((progress - 0.3) / 0.4));
      } else if (progress < 0.85) {
        y = maxElev.toDouble();
      } else {
        y = maxElev - (maxElev * 0.3 * ((progress - 0.85) / 0.15));
      }
      spots.add(FlSpot(x, y));
    }
    return spots;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    final trail = widget.trail;

    return Scaffold(
      backgroundColor: Colors.white,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: screenHeight * 0.42,
            pinned: true,
            backgroundColor: Colors.black,
            foregroundColor: Colors.white,
            leading: GestureDetector(
              onTap: () => Navigator.pop(context),
              child: Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
            actions: [
              Container(
                margin: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.share, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
              Container(
                margin: const EdgeInsets.only(right: 8, top: 8, bottom: 8),
                decoration: BoxDecoration(
                  color: Colors.black.withOpacity(0.4),
                  shape: BoxShape.circle,
                ),
                child: IconButton(
                  icon: const Icon(Icons.favorite_border, color: Colors.white, size: 20),
                  onPressed: () {},
                ),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  trail.imageUrl.isNotEmpty
                      ? CachedNetworkImage(
                    imageUrl: trail.imageUrl,
                    fit: BoxFit.cover,
                    placeholder: (_, __) => Container(color: Colors.green[800]),
                    errorWidget: (_, __, ___) => Container(
                      color: Colors.green[800],
                      child: const Icon(Icons.landscape, color: Colors.white, size: 80),
                    ),
                  )
                      : Container(color: Colors.green[800]),
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withOpacity(0.7),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    bottom: 20,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                              decoration: BoxDecoration(
                                color: trail.difficultyColor,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              child: Text(
                                trail.difficulty,
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(Icons.star, color: Color(0xFFFFD700), size: 16),
                            const SizedBox(width: 4),
                            Text(
                              '4.9 · 2,847 reviews',
                              style: TextStyle(
                                color: Colors.white.withOpacity(0.9),
                                fontSize: 13,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(
                          trail.name,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: screenWidth * 0.065,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Row(
                          children: [
                            const Icon(Icons.location_on, color: Colors.white70, size: 14),
                            const SizedBox(width: 4),
                            Text(
                              trail.region,
                              style: const TextStyle(color: Colors.white70, fontSize: 13),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Column(
              children: [
                // ── Stats Row ──
                Container(
                  margin: const EdgeInsets.all(16),
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.07),
                        blurRadius: 10,
                        offset: const Offset(0, 3),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _statItem(Icons.schedule_outlined, '${trail.duration}d', 'Duration', screenWidth),
                      _divider(),
                      _statItem(Icons.straighten, '${trail.distance.toInt()}km', 'Distance', screenWidth),
                      _divider(),
                      _statItem(Icons.trending_up, '${trail.elevation}m', 'Max Alt', screenWidth),
                      _divider(),
                      _statItem(Icons.location_on_outlined, trail.startPoint.split(' ').first, 'Start', screenWidth),
                    ],
                  ),
                ),

                // ── Tab Bar ──
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.grey[100],
                    borderRadius: BorderRadius.circular(30),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: const Color(0xFF2D5A3D),
                      borderRadius: BorderRadius.circular(30),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: Colors.grey[600],
                    labelStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13),
                    dividerColor: Colors.transparent,
                    tabs: const [
                      Tab(text: 'Overview'),
                      Tab(text: 'Checkpoints'),
                      Tab(text: 'Weather'),
                    ],
                  ),
                ),

                const SizedBox(height: 16),

                // ── Tab Content ──
                SizedBox(
                  height: screenHeight * 0.6,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _overviewTab(trail, screenWidth),
                      _checkpointsTab(trail, screenWidth),
                      _weatherTab(trail, screenWidth),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _overviewTab(TrailModel trail, double screenWidth) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            trail.description,
            style: TextStyle(
              color: const Color(0xFF2D5A3D),
              fontSize: screenWidth * 0.038,
              height: 1.7,
            ),
          ),

          const SizedBox(height: 24),

          // ── Elevation Profile ──
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.07),
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Elevation Profile',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: screenWidth * 0.042,
                  ),
                ),
                const SizedBox(height: 16),
                SizedBox(
                  height: 160,
                  child: LineChart(
                    LineChartData(
                      gridData: FlGridData(
                        show: true,
                        drawVerticalLine: false,
                        horizontalInterval: trail.elevation / 4,
                        getDrawingHorizontalLine: (value) => FlLine(
                          color: Colors.grey[200]!,
                          strokeWidth: 1,
                        ),
                      ),
                      titlesData: FlTitlesData(
                        leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                        bottomTitles: AxisTitles(
                          sideTitles: SideTitles(
                            showTitles: true,
                            interval: trail.distance / 4,
                            getTitlesWidget: (value, meta) => Text(
                              '${value.toInt()}',
                              style: TextStyle(color: Colors.grey[500], fontSize: 10),
                            ),
                          ),
                        ),
                      ),
                      borderData: FlBorderData(show: false),
                      lineBarsData: [
                        LineChartBarData(
                          spots: _generateElevationSpots(),
                          isCurved: true,
                          color: const Color(0xFF2D5A3D),
                          barWidth: 2.5,
                          belowBarData: BarAreaData(
                            show: true,
                            color: const Color(0xFF2D5A3D).withOpacity(0.15),
                          ),
                          dotData: const FlDotData(show: false),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '0 km · ${trail.startPoint.split(' ').first}',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                    Text(
                      'Peak: ${trail.elevation}m EBC',
                      style: const TextStyle(color: Color(0xFF2D5A3D), fontSize: 11, fontWeight: FontWeight.bold),
                    ),
                    Text(
                      '${trail.distance.toInt()} km',
                      style: TextStyle(color: Colors.grey[500], fontSize: 11),
                    ),
                  ],
                ),
              ],
            ),
          ),

          const SizedBox(height: 24),

          Text(
            'Highlights',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.045),
          ),
          const SizedBox(height: 12),
          ...trail.highlights.map((h) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  margin: const EdgeInsets.only(top: 4),
                  width: 8,
                  height: 8,
                  decoration: const BoxDecoration(
                    color: Color(0xFF2D5A3D),
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    h,
                    style: TextStyle(fontSize: screenWidth * 0.036, color: Colors.grey[800], height: 1.5),
                  ),
                ),
              ],
            ),
          )),

          const SizedBox(height: 24),

          Row(
            children: [
              Expanded(
                child: _infoTile(Icons.flag_outlined, 'Start Point', trail.startPoint, screenWidth),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _infoTile(Icons.wb_sunny_outlined, 'Best Season', trail.bestSeason, screenWidth),
              ),
            ],
          ),

          const SizedBox(height: 30),
        ],
      ),
    );
  }

  Widget _checkpointsTab(TrailModel trail, double screenWidth) {
    final checkpoints = trail.highlights;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: List.generate(checkpoints.length, (index) {
          final isLast = index == checkpoints.length - 1;
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                children: [
                  Container(
                    width: 32,
                    height: 32,
                    decoration: BoxDecoration(
                      color: index == 0 || isLast
                          ? const Color(0xFF2D5A3D)
                          : Colors.white,
                      shape: BoxShape.circle,
                      border: Border.all(color: const Color(0xFF2D5A3D), width: 2),
                    ),
                    child: Center(
                      child: Text(
                        '${index + 1}',
                        style: TextStyle(
                          color: index == 0 || isLast ? Colors.white : const Color(0xFF2D5A3D),
                          fontWeight: FontWeight.bold,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ),
                  if (!isLast)
                    Container(width: 2, height: 50, color: Colors.green[200]),
                ],
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.only(top: 6, bottom: 16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        checkpoints[index],
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.036,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        'Day ${index + 1} · ${(trail.elevation * (index + 1) / checkpoints.length).toInt()}m',
                        style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.03),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _weatherTab(TrailModel trail, double screenWidth) {
    final seasons = [
      {'season': 'Spring (Mar–May)', 'icon': '🌸', 'desc': 'Best time — clear skies, blooming rhododendrons', 'rating': 5},
      {'season': 'Summer (Jun–Aug)', 'icon': '🌧', 'desc': 'Monsoon season — trails slippery, poor visibility', 'rating': 2},
      {'season': 'Autumn (Sep–Nov)', 'icon': '🍂', 'desc': 'Peak season — stable weather, best views', 'rating': 5},
      {'season': 'Winter (Dec–Feb)', 'icon': '❄️', 'desc': 'Cold and snowy — high passes may be closed', 'rating': 3},
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF2D5A3D).withOpacity(0.08),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: const Color(0xFF2D5A3D).withOpacity(0.2)),
            ),
            child: Row(
              children: [
                const Icon(Icons.wb_sunny, color: Color(0xFF2D5A3D)),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Best Season: ${trail.bestSeason}',
                    style: const TextStyle(
                      color: Color(0xFF2D5A3D),
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          ...seasons.map((s) => Container(
            margin: const EdgeInsets.only(bottom: 12),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
              ],
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(s['icon'] as String, style: const TextStyle(fontSize: 28)),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        s['season'] as String,
                        style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.036),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        s['desc'] as String,
                        style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.03),
                      ),
                      const SizedBox(height: 6),
                      Row(
                        children: List.generate(5, (i) => Icon(
                          Icons.star,
                          size: 14,
                          color: i < (s['rating'] as int) ? const Color(0xFFFFD700) : Colors.grey[300],
                        )),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          )),
        ],
      ),
    );
  }

  Widget _statItem(IconData icon, String value, String label, double screenWidth) {
    return Column(
      children: [
        Icon(icon, color: const Color(0xFF2D5A3D), size: screenWidth * 0.055),
        const SizedBox(height: 6),
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.038),
          maxLines: 1,
          overflow: TextOverflow.ellipsis,
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.028),
        ),
      ],
    );
  }

  Widget _divider() {
    return Container(width: 1, height: 40, color: Colors.grey[200]);
  }

  Widget _infoTile(IconData icon, String title, String value, double screenWidth) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(14),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2)),
        ],
      ),
      child: Row(
        children: [
          Icon(icon, color: const Color(0xFF2D5A3D), size: screenWidth * 0.05),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.028)),
                Text(
                  value,
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.03),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}