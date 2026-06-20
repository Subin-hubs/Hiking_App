import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/trail_model.dart';
import '../services/trail_service.dart';
import 'trail_detail_screen.dart';

class TrailExplorerScreen extends StatefulWidget {
  const TrailExplorerScreen({super.key});

  @override
  State<TrailExplorerScreen> createState() => _TrailExplorerScreenState();
}

class _TrailExplorerScreenState extends State<TrailExplorerScreen> {
  final TrailService _trailService = TrailService();
  List<TrailModel> _allTrails = [];
  List<TrailModel> _filteredTrails = [];
  bool _isLoading = true;
  String? _error;

  String? _selectedDifficulty;
  String? _selectedRegion;
  int? _maxDuration;
  int? _maxElevation;

  final List<String> _difficulties = ['Easy', 'Moderate', 'Hard', 'Expert'];
  final List<String> _regions = [
    'Everest', 'Annapurna', 'Langtang', 'Mustang',
    'Manaslu', 'Kanchenjunga', 'Dolpo', 'Rolwaling'
  ];

  @override
  void initState() {
    super.initState();
    _loadTrails();
  }

  Future<void> _loadTrails({bool forceRefresh = false}) async {
    setState(() {
      _isLoading = true;
      _error = null;
    });
    try {
      final trails = await _trailService.getTrails(forceRefresh: forceRefresh);
      setState(() {
        _allTrails = trails;
        _filteredTrails = trails;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to load trails. Check your connection.';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTrails = _allTrails.where((trail) {
        if (_selectedDifficulty != null &&
            trail.difficulty.toLowerCase() != _selectedDifficulty!.toLowerCase()) {
          return false;
        }
        if (_selectedRegion != null &&
            !trail.region.toLowerCase().contains(_selectedRegion!.toLowerCase())) {
          return false;
        }
        if (_maxDuration != null && trail.duration > _maxDuration!) {
          return false;
        }
        if (_maxElevation != null && trail.elevation > _maxElevation!) {
          return false;
        }
        return true;
      }).toList();
    });
  }

  void _clearFilters() {
    setState(() {
      _selectedDifficulty = null;
      _selectedRegion = null;
      _maxDuration = null;
      _maxElevation = null;
      _filteredTrails = _allTrails;
    });
  }

  void _showFilterSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (_) => StatefulBuilder(
        builder: (context, setSheetState) => Padding(
          padding: EdgeInsets.only(
            left: 20,
            right: 20,
            top: 20,
            bottom: MediaQuery.of(context).viewInsets.bottom + 20,
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Filters', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  TextButton(
                    onPressed: () {
                      setSheetState(() {
                        _selectedDifficulty = null;
                        _selectedRegion = null;
                        _maxDuration = null;
                        _maxElevation = null;
                      });
                    },
                    child: Text('Clear all', style: TextStyle(color: Colors.green[700])),
                  ),
                ],
              ),
              const SizedBox(height: 16),

              const Text('Difficulty', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: _difficulties.map((d) {
                  final selected = _selectedDifficulty == d;
                  return ChoiceChip(
                    label: Text(d),
                    selected: selected,
                    onSelected: (_) => setSheetState(() {
                      _selectedDifficulty = selected ? null : d;
                    }),
                    selectedColor: Colors.green[700],
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text('Region', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                runSpacing: 4,
                children: _regions.map((r) {
                  final selected = _selectedRegion == r;
                  return ChoiceChip(
                    label: Text(r),
                    selected: selected,
                    onSelected: (_) => setSheetState(() {
                      _selectedRegion = selected ? null : r;
                    }),
                    selectedColor: Colors.green[700],
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text('Max Duration (days)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [7, 14, 21, 30].map((d) {
                  final selected = _maxDuration == d;
                  return ChoiceChip(
                    label: Text('$d days'),
                    selected: selected,
                    onSelected: (_) => setSheetState(() {
                      _maxDuration = selected ? null : d;
                    }),
                    selectedColor: Colors.green[700],
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 16),
              const Text('Max Elevation (m)', style: TextStyle(fontWeight: FontWeight.bold)),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: [3000, 4000, 5000, 6000].map((e) {
                  final selected = _maxElevation == e;
                  return ChoiceChip(
                    label: Text('${e}m'),
                    selected: selected,
                    onSelected: (_) => setSheetState(() {
                      _maxElevation = selected ? null : e;
                    }),
                    selectedColor: Colors.green[700],
                    labelStyle: TextStyle(
                      color: selected ? Colors.white : Colors.black,
                    ),
                  );
                }).toList(),
              ),

              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green[700],
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                    _applyFilters();
                  },
                  child: const Text('Apply Filters', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final hasActiveFilters = _selectedDifficulty != null ||
        _selectedRegion != null ||
        _maxDuration != null ||
        _maxElevation != null;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Explore Trails', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          if (hasActiveFilters)
            IconButton(
              icon: const Icon(Icons.filter_alt_off),
              onPressed: _clearFilters,
            ),
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterSheet,
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => _loadTrails(forceRefresh: true),
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
              onPressed: () => _loadTrails(),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green[700], foregroundColor: Colors.white),
              child: const Text('Retry'),
            ),
          ],
        ),
      )
          : _filteredTrails.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.search_off, size: 60, color: Colors.grey[400]),
            const SizedBox(height: 16),
            Text('No trails match your filters', style: TextStyle(color: Colors.grey[600])),
            const SizedBox(height: 12),
            TextButton(
              onPressed: _clearFilters,
              child: Text('Clear filters', style: TextStyle(color: Colors.green[700])),
            ),
          ],
        ),
      )
          : RefreshIndicator(
        onRefresh: () => _loadTrails(forceRefresh: true),
        color: Colors.green,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _filteredTrails.length,
          itemBuilder: (context, index) {
            return _trailListCard(_filteredTrails[index], screenWidth);
          },
        ),
      ),
    );
  }

  Widget _trailListCard(TrailModel trail, double screenWidth) {
    return GestureDetector(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: trail)),
      ),
      child: Container(
        margin: const EdgeInsets.only(bottom: 14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.07),
              blurRadius: 10,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: const BorderRadius.horizontal(left: Radius.circular(18)),
              child: trail.imageUrl.isNotEmpty
                  ? CachedNetworkImage(
                imageUrl: trail.imageUrl,
                width: screenWidth * 0.3,
                height: screenWidth * 0.28,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.28,
                  color: Colors.green[100],
                  child: const Center(child: CircularProgressIndicator(color: Colors.green)),
                ),
                errorWidget: (_, __, ___) => Container(
                  width: screenWidth * 0.3,
                  height: screenWidth * 0.28,
                  color: Colors.green[100],
                  child: Icon(Icons.landscape, color: Colors.green[400], size: 40),
                ),
              )
                  : Container(
                width: screenWidth * 0.3,
                height: screenWidth * 0.28,
                color: Colors.green[100],
                child: Icon(Icons.landscape, color: Colors.green[400], size: 40),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            trail.name,
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: screenWidth * 0.038,
                            ),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                          decoration: BoxDecoration(
                            color: trail.difficultyColor.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Text(
                            trail.difficulty,
                            style: TextStyle(
                              color: trail.difficultyColor,
                              fontSize: screenWidth * 0.025,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                        const SizedBox(width: 2),
                        Text(
                          trail.region,
                          style: TextStyle(color: Colors.grey[500], fontSize: screenWidth * 0.03),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        _miniStat(Icons.schedule, '${trail.duration}d', screenWidth),
                        const SizedBox(width: 10),
                        _miniStat(Icons.terrain, '${trail.elevation}m', screenWidth),
                        const SizedBox(width: 10),
                        _miniStat(Icons.straighten, '${trail.distance}km', screenWidth),
                      ],
                    ),
                    const SizedBox(height: 6),
                    Text(
                      trail.bestSeason,
                      style: TextStyle(
                        color: Colors.green[700],
                        fontSize: screenWidth * 0.028,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _miniStat(IconData icon, String value, double screenWidth) {
    return Row(
      children: [
        Icon(icon, size: screenWidth * 0.032, color: Colors.grey[500]),
        const SizedBox(width: 2),
        Text(
          value,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: screenWidth * 0.028,
            fontWeight: FontWeight.w500,
          ),
        ),
      ],
    );
  }
}