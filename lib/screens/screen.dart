import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/trail_model.dart';
import '../services/trail_service.dart';
import '../screens/trail_detail_screen.dart';
import '../screens/weather_screen.dart';
import '../utils/constants.dart';

enum SearchCategory { all, trails, locations, weather }

class SearchScreen extends StatefulWidget {
  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() => _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {
  final TextEditingController _controller = TextEditingController();
  final FocusNode _focusNode = FocusNode();
  final TrailService _trailService = TrailService();

  List<TrailModel> _allTrails = [];
  List<TrailModel> _trailResults = [];
  List<Map<String, dynamic>> _locationResults = [];
  SearchCategory _category = SearchCategory.all;
  bool _isLoading = false;
  bool _hasSearched = false;

  final List<String> _recentSearches = ['Everest Base Camp', 'Poon Hill', 'Annapurna', 'Kathmandu'];
  final List<String> _popularSearches = ['Easy treks', 'Langtang', 'Mustang', 'Namche Bazaar', 'Lukla', 'Pokhara'];

  @override
  void initState() {
    super.initState();
    _loadTrails();
    WidgetsBinding.instance.addPostFrameCallback((_) => _focusNode.requestFocus());
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  Future<void> _loadTrails() async {
    try {
      final trails = await _trailService.getTrails();
      setState(() => _allTrails = trails);
    } catch (_) {}
  }

  void _search(String query) {
    if (query.trim().isEmpty) {
      setState(() {
        _trailResults = [];
        _locationResults = [];
        _hasSearched = false;
      });
      return;
    }

    setState(() {
      _isLoading = true;
      _hasSearched = true;
    });

    final q = query.toLowerCase();

    // Search trails
    _trailResults = _allTrails.where((trail) {
      return trail.name.toLowerCase().contains(q) ||
          trail.region.toLowerCase().contains(q) ||
          trail.difficulty.toLowerCase().contains(q) ||
          trail.description.toLowerCase().contains(q) ||
          trail.startPoint.toLowerCase().contains(q);
    }).toList();

    // Search locations from constants
    _locationResults = AppConstants.hikingLocations.where((loc) {
      return (loc['name'] as String).toLowerCase().contains(q) ||
          (loc['description'] as String).toLowerCase().contains(q);
    }).toList();

    setState(() => _isLoading = false);
  }

  List<TrailModel> get _filteredTrails {
    if (_category == SearchCategory.locations || _category == SearchCategory.weather) return [];
    return _trailResults;
  }

  List<Map<String, dynamic>> get _filteredLocations {
    if (_category == SearchCategory.trails) return [];
    return _locationResults;
  }

  int get _totalResults => _filteredTrails.length + _filteredLocations.length;

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black87),
          onPressed: () => Navigator.pop(context),
        ),
        title: TextField(
          controller: _controller,
          focusNode: _focusNode,
          onChanged: _search,
          decoration: InputDecoration(
            hintText: 'Search trails, locations...',
            hintStyle: TextStyle(color: Colors.grey[400], fontSize: 15),
            border: InputBorder.none,
            suffixIcon: _controller.text.isNotEmpty
                ? IconButton(
              icon: Icon(Icons.close, color: Colors.grey[400]),
              onPressed: () {
                _controller.clear();
                _search('');
              },
            )
                : null,
          ),
          style: const TextStyle(fontSize: 15, color: Colors.black87),
        ),
      ),
      body: Column(
        children: [
          // ── Category Filter ──
          if (_hasSearched)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: [
                    _categoryChip('All', SearchCategory.all),
                    const SizedBox(width: 8),
                    _categoryChip('Trails (${_trailResults.length})', SearchCategory.trails),
                    const SizedBox(width: 8),
                    _categoryChip('Locations (${_locationResults.length})', SearchCategory.locations),
                  ],
                ),
              ),
            ),

          if (_hasSearched && !_isLoading)
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 10),
              child: Row(
                children: [
                  Text(
                    '$_totalResults result${_totalResults != 1 ? 's' : ''} for "${_controller.text}"',
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),

          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator(color: Colors.green))
                : !_hasSearched
                ? _buildSuggestions(screenWidth)
                : _totalResults == 0
                ? _buildEmpty(screenWidth)
                : ListView(
              padding: const EdgeInsets.all(16),
              children: [
                if (_filteredTrails.isNotEmpty) ...[
                  _sectionHeader('🥾 Trails', _filteredTrails.length),
                  const SizedBox(height: 8),
                  ..._filteredTrails.map((t) => _trailCard(t, screenWidth)),
                  const SizedBox(height: 16),
                ],
                if (_filteredLocations.isNotEmpty) ...[
                  _sectionHeader('📍 Locations', _filteredLocations.length),
                  const SizedBox(height: 8),
                  ..._filteredLocations.map((l) => _locationCard(l, screenWidth)),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _categoryChip(String label, SearchCategory category) {
    final selected = _category == category;
    return GestureDetector(
      onTap: () => setState(() => _category = category),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          color: selected ? Colors.green[700] : Colors.grey[100],
          borderRadius: BorderRadius.circular(20),
        ),
        child: Text(
          label,
          style: TextStyle(
            color: selected ? Colors.white : Colors.grey[700],
            fontSize: 12,
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
          ),
        ),
      ),
    );
  }

  Widget _sectionHeader(String title, int count) {
    return Row(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        const SizedBox(width: 6),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
          decoration: BoxDecoration(
            color: Colors.green[50],
            borderRadius: BorderRadius.circular(10),
          ),
          child: Text('$count', style: TextStyle(color: Colors.green[700], fontSize: 11, fontWeight: FontWeight.bold)),
        ),
      ],
    );
  }

  Widget _trailCard(TrailModel trail, double screenWidth) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: trail)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(10),
              child: trail.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: trail.imageUrl,
                width: screenWidth * 0.18,
                height: screenWidth * 0.18,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(color: Colors.green[100]),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.green[100],
                  child: Icon(Icons.landscape, color: Colors.green[400]),
                ),
              )
                  : Container(
                width: screenWidth * 0.18,
                height: screenWidth * 0.18,
                color: Colors.green[100],
                child: Icon(Icons.landscape, color: Colors.green[400]),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    trail.name,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.036),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text(trail.region, style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: trail.difficultyColor.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Text(
                          trail.difficulty,
                          style: TextStyle(color: trail.difficultyColor, fontSize: 11, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Icon(Icons.schedule, size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text('${trail.duration}d', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                      const SizedBox(width: 8),
                      Icon(Icons.terrain, size: 11, color: Colors.grey[500]),
                      const SizedBox(width: 2),
                      Text('${trail.elevation}m', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
                    ],
                  ),
                ],
              ),
            ),
            Icon(Icons.chevron_right, color: Colors.grey[400]),
          ],
        ),
      ),
    );
  }

  Widget _locationCard(Map<String, dynamic> loc, double screenWidth) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => const WeatherScreen()),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 10),
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.06), blurRadius: 8, offset: const Offset(0, 2))],
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.location_on, color: Colors.green[700], size: 22),
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
                  const SizedBox(height: 3),
                  Text(
                    loc['description'],
                    style: TextStyle(color: Colors.grey[500], fontSize: 12),
                  ),
                ],
              ),
            ),
            Text('⛰ ${loc['elevation']}', style: TextStyle(color: Colors.grey[500], fontSize: 11)),
          ],
        ),
      ),
    );
  }

  Widget _buildSuggestions(double screenWidth) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        if (_recentSearches.isNotEmpty) ...[
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text('Recent Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
              TextButton(
                onPressed: () => setState(() => _recentSearches.clear()),
                child: Text('Clear', style: TextStyle(color: Colors.green[700], fontSize: 12)),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _recentSearches.map((s) => GestureDetector(
              onTap: () {
                _controller.text = s;
                _search(s);
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 4)],
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(Icons.history, size: 14, color: Colors.grey[400]),
                    const SizedBox(width: 6),
                    Text(s, style: TextStyle(fontSize: 13, color: Colors.grey[700])),
                  ],
                ),
              ),
            )).toList(),
          ),
          const SizedBox(height: 24),
        ],

        const Text('Popular Searches', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 8),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _popularSearches.map((s) => GestureDetector(
            onTap: () {
              _controller.text = s;
              _search(s);
            },
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.green[50],
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: Colors.green[200]!),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.trending_up, size: 14, color: Colors.green[700]),
                  const SizedBox(width: 6),
                  Text(s, style: TextStyle(fontSize: 13, color: Colors.green[700])),
                ],
              ),
            ),
          )).toList(),
        ),
      ],
    );
  }

  Widget _buildEmpty(double screenWidth) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.search_off, size: 60, color: Colors.grey[300]),
          const SizedBox(height: 16),
          Text(
            'No results for "${_controller.text}"',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
          ),
          const SizedBox(height: 8),
          Text(
            'Try searching for a trail name,\nregion or difficulty level.',
            textAlign: TextAlign.center,
            style: TextStyle(color: Colors.grey[500], fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}