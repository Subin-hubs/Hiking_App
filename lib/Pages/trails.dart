import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../models/trail_model.dart';
import '../services/trail_service.dart';
import '../screens/trail_detail_screen.dart';

class Trails extends StatefulWidget {
  const Trails({super.key});

  @override
  State<Trails> createState() => _TrailsState();
}

class _TrailsState extends State<Trails> {
  final TrailService _trailService = TrailService();
  List<TrailModel> _allTrails = [];
  List<TrailModel> _filteredTrails = [];
  bool _isLoading = true;
  String? _error;
  String _searchQuery = '';
  final TextEditingController _searchController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  bool _isSearchFocused = false;

  String? _selectedDifficulty;
  String? _selectedRegion;
  int? _maxDuration;
  int? _maxElevation;

  static const _kForestDeep = Color(0xFF1A3C2E);
  static const _kForestMid = Color(0xFF2D6A4F);
  static const _kForestAccent = Color(0xFF52B788);
  static const _kSurface = Color(0xFFF7F9F8);
  static const _kCard = Color(0xFFFFFFFF);
  static const _kTextPrimary = Color(0xFF0D1F17);
  static const _kTextSecondary = Color(0xFF6B7F74);
  static const _kDivider = Color(0xFFE8EDEA);

  final List<String> _difficulties = ['Easy', 'Moderate', 'Hard', 'Expert'];
  final List<String> _regions = [
    'Everest', 'Annapurna', 'Langtang', 'Mustang',
    'Manaslu', 'Kanchenjunga', 'Dolpo', 'Rolwaling',
  ];

  @override
  void initState() {
    super.initState();
    _searchFocus.addListener(() {
      setState(() => _isSearchFocused = _searchFocus.hasFocus);
    });
    _loadTrails();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocus.dispose();
    super.dispose();
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
        _error = 'Connection lost. Check your network and try again.';
        _isLoading = false;
      });
    }
  }

  void _applyFilters() {
    setState(() {
      _filteredTrails = _allTrails.where((trail) {
        if (_searchQuery.isNotEmpty &&
            !trail.name.toLowerCase().contains(_searchQuery.toLowerCase()) &&
            !trail.region.toLowerCase().contains(_searchQuery.toLowerCase())) {
          return false;
        }
        if (_selectedDifficulty != null &&
            trail.difficulty.toLowerCase() != _selectedDifficulty!.toLowerCase()) {
          return false;
        }
        if (_selectedRegion != null &&
            !trail.region.toLowerCase().contains(_selectedRegion!.toLowerCase())) {
          return false;
        }
        if (_maxDuration != null && trail.duration > _maxDuration!) return false;
        if (_maxElevation != null && trail.elevation > _maxElevation!) return false;
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
      _searchQuery = '';
      _searchController.clear();
      _filteredTrails = _allTrails;
    });
  }

  bool get _hasActiveFilters =>
      _selectedDifficulty != null ||
          _selectedRegion != null ||
          _maxDuration != null ||
          _maxElevation != null;

  int get _activeFilterCount => [
    _selectedDifficulty,
    _selectedRegion,
    _maxDuration != null ? '$_maxDuration' : null,
    _maxElevation != null ? '$_maxElevation' : null,
  ].where((e) => e != null).length;

  void _showFilterSheet() {
    HapticFeedback.lightImpact();
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (_) => _FilterSheet(
        difficulties: _difficulties,
        regions: _regions,
        selectedDifficulty: _selectedDifficulty,
        selectedRegion: _selectedRegion,
        maxDuration: _maxDuration,
        maxElevation: _maxElevation,
        onApply: (diff, region, dur, elev) {
          setState(() {
            _selectedDifficulty = diff;
            _selectedRegion = region;
            _maxDuration = dur;
            _maxElevation = elev;
          });
          _applyFilters();
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light.copyWith(
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        backgroundColor: _kSurface,
        body: CustomScrollView(
          physics: const BouncingScrollPhysics(),
          slivers: [
            _buildSliverAppBar(size),
            SliverToBoxAdapter(child: _buildSearchBar()),
            if (_hasActiveFilters)
              SliverToBoxAdapter(child: _buildActiveFiltersBanner()),
            _buildTrailList(size),
          ],
        ),
      ),
    );
  }

  Widget _buildSliverAppBar(Size size) {
    return SliverAppBar(
      expandedHeight: 130,
      pinned: true,
      stretch: true,
      backgroundColor: _kForestDeep,
      systemOverlayStyle: SystemUiOverlayStyle.light,
      flexibleSpace: FlexibleSpaceBar(
        stretchModes: const [StretchMode.zoomBackground, StretchMode.fadeTitle],
        titlePadding: const EdgeInsets.only(left: 20, bottom: 14),
        title: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'TRAILS',
              style: TextStyle(
                color: Colors.white,
                fontSize: 22,
                fontWeight: FontWeight.w800,
                letterSpacing: 3.0,
                height: 1.0,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              'Nepal Himalaya',
              style: TextStyle(
                color: Colors.white.withOpacity(0.55),
                fontSize: 11,
                fontWeight: FontWeight.w400,
                letterSpacing: 1.0,
              ),
            ),
          ],
        ),
        background: Stack(
          fit: StackFit.expand,
          children: [
            Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Color(0xFF0F2D20), Color(0xFF1A4A32), Color(0xFF2D6A4F)],
                  stops: [0.0, 0.5, 1.0],
                ),
              ),
            ),
            Positioned(
              right: -30,
              top: -20,
              child: Container(
                width: 180,
                height: 180,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kForestAccent.withOpacity(0.07),
                ),
              ),
            ),
            Positioned(
              right: 30,
              bottom: 10,
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: _kForestAccent.withOpacity(0.05),
                ),
              ),
            ),
          ],
        ),
      ),
      actions: [
        if (_hasActiveFilters)
          IconButton(
            icon: const Icon(Icons.filter_alt_off_rounded, size: 20),
            color: _kForestAccent,
            tooltip: 'Clear filters',
            onPressed: _clearFilters,
          ),
        Stack(
          alignment: Alignment.center,
          children: [
            IconButton(
              icon: const Icon(Icons.tune_rounded, size: 22),
              color: Colors.white,
              tooltip: 'Filter',
              onPressed: _showFilterSheet,
            ),
            if (_hasActiveFilters)
              Positioned(
                top: 8,
                right: 8,
                child: Container(
                  width: 16,
                  height: 16,
                  decoration: const BoxDecoration(
                    color: _kForestAccent,
                    shape: BoxShape.circle,
                  ),
                  child: Center(
                    child: Text(
                      '$_activeFilterCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
        IconButton(
          icon: const Icon(Icons.refresh_rounded, size: 22),
          color: Colors.white.withOpacity(0.7),
          tooltip: 'Refresh',
          onPressed: () {
            HapticFeedback.lightImpact();
            _loadTrails(forceRefresh: true);
          },
        ),
        const SizedBox(width: 4),
      ],
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        height: 50,
        decoration: BoxDecoration(
          color: _kCard,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: _isSearchFocused
                ? _kForestAccent.withOpacity(0.6)
                : _kDivider,
            width: _isSearchFocused ? 1.5 : 1.0,
          ),
          boxShadow: [
            BoxShadow(
              color: _isSearchFocused
                  ? _kForestAccent.withOpacity(0.1)
                  : Colors.black.withOpacity(0.04),
              blurRadius: _isSearchFocused ? 12 : 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: TextField(
          controller: _searchController,
          focusNode: _searchFocus,
          onChanged: (val) {
            _searchQuery = val;
            _applyFilters();
          },
          style: const TextStyle(
            color: _kTextPrimary,
            fontSize: 14,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: 'Search trails or regions…',
            hintStyle: TextStyle(
              color: _kTextSecondary.withOpacity(0.6),
              fontSize: 14,
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Padding(
              padding: const EdgeInsets.only(left: 14, right: 10),
              child: Icon(
                Icons.search_rounded,
                color: _isSearchFocused ? _kForestAccent : _kTextSecondary,
                size: 20,
              ),
            ),
            prefixIconConstraints: const BoxConstraints(minWidth: 44),
            suffixIcon: _searchQuery.isNotEmpty
                ? GestureDetector(
              onTap: () {
                _searchController.clear();
                _searchQuery = '';
                _applyFilters();
              },
              child: Padding(
                padding: const EdgeInsets.only(right: 12),
                child: Icon(Icons.cancel_rounded, color: _kTextSecondary.withOpacity(0.5), size: 18),
              ),
            )
                : null,
            suffixIconConstraints: const BoxConstraints(minWidth: 40),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(vertical: 15),
          ),
        ),
      ),
    );
  }

  Widget _buildActiveFiltersBanner() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: _kForestDeep.withOpacity(0.06),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: _kForestDeep.withOpacity(0.1)),
        ),
        child: Row(
          children: [
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: _kForestAccent,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 8),
            Text(
              '$_activeFilterCount ${_activeFilterCount == 1 ? 'filter' : 'filters'} active',
              style: const TextStyle(
                color: _kForestMid,
                fontSize: 12,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            Text(
              '· ${_filteredTrails.length} ${_filteredTrails.length == 1 ? 'result' : 'results'}',
              style: TextStyle(
                color: _kTextSecondary,
                fontSize: 12,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            GestureDetector(
              onTap: _clearFilters,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _kDivider),
                ),
                child: const Text(
                  'Clear',
                  style: TextStyle(
                    color: _kTextPrimary,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTrailList(Size size) {
    if (_isLoading) {
      return SliverFillRemaining(
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                width: 32,
                height: 32,
                child: CircularProgressIndicator(
                  strokeWidth: 2.5,
                  color: _kForestAccent,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                'Finding trails…',
                style: TextStyle(
                  color: _kTextSecondary,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      );
    }

    if (_error != null) {
      return SliverFillRemaining(
        child: _EmptyState(
          icon: Icons.cloud_off_rounded,
          title: 'No connection',
          subtitle: _error!,
          action: 'Try again',
          onAction: () => _loadTrails(),
        ),
      );
    }

    if (_filteredTrails.isEmpty) {
      return SliverFillRemaining(
        child: _EmptyState(
          icon: Icons.terrain_rounded,
          title: 'No trails found',
          subtitle: 'Try adjusting your search or filters.',
          action: 'Reset all',
          onAction: _clearFilters,
        ),
      );
    }

    return SliverPadding(
      padding: const EdgeInsets.fromLTRB(16, 4, 16, 32),
      sliver: SliverList(
        delegate: SliverChildBuilderDelegate(
              (context, index) => _TrailCard(
            trail: _filteredTrails[index],
            screenWidth: size.width,
            onTap: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => TrailDetailScreen(trail: _filteredTrails[index])),
            ),
          ),
          childCount: _filteredTrails.length,
        ),
      ),
    );
  }
}

class _TrailCard extends StatelessWidget {
  final TrailModel trail;
  final double screenWidth;
  final VoidCallback onTap;

  static const _kForestDeep = Color(0xFF1A3C2E);
  static const _kForestAccent = Color(0xFF52B788);
  static const _kTextPrimary = Color(0xFF0D1F17);
  static const _kTextSecondary = Color(0xFF6B7F74);

  const _TrailCard({
    required this.trail,
    required this.screenWidth,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        HapticFeedback.selectionClick();
        onTap();
      },
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 4),
            ),
            BoxShadow(
              color: Colors.black.withOpacity(0.02),
              blurRadius: 4,
              offset: const Offset(0, 1),
            ),
          ],
        ),
        child: Row(
          children: [
            _buildImage(),
            Expanded(child: _buildContent()),
          ],
        ),
      ),
    );
  }

  Widget _buildImage() {
    final imgWidth = screenWidth * 0.30;
    final imgHeight = screenWidth * 0.30;

    Widget placeholder = Container(
      width: imgWidth,
      height: imgHeight,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFD8EDE1), Color(0xFFC1DDD0)],
        ),
        borderRadius: BorderRadius.horizontal(left: Radius.circular(20)),
      ),
      child: Center(
        child: Icon(Icons.landscape_rounded, color: Color(0xFF52B788), size: 32),
      ),
    );

    return ClipRRect(
      borderRadius: const BorderRadius.horizontal(left: Radius.circular(20)),
      child: trail.imageUrl.isNotEmpty
          ? CachedNetworkImage(
        imageUrl: trail.imageUrl,
        width: imgWidth,
        height: imgHeight,
        fit: BoxFit.cover,
        placeholder: (_, __) => placeholder,
        errorWidget: (_, __, ___) => placeholder,
      )
          : placeholder,
    );
  }

  Widget _buildContent() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 14, 14, 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Text(
                  trail.name,
                  style: const TextStyle(
                    color: _kTextPrimary,
                    fontWeight: FontWeight.w700,
                    fontSize: 14,
                    height: 1.2,
                    letterSpacing: -0.1,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: 8),
              _DifficultyBadge(difficulty: trail.difficulty, color: trail.difficultyColor),
            ],
          ),
          const SizedBox(height: 5),
          Row(
            children: [
              Icon(Icons.location_on_rounded, size: 11, color: _kTextSecondary.withOpacity(0.7)),
              const SizedBox(width: 3),
              Text(
                trail.region,
                style: TextStyle(
                  color: _kTextSecondary,
                  fontSize: 11.5,
                  fontWeight: FontWeight.w400,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              _StatPill(icon: Icons.schedule_rounded, value: '${trail.duration}d'),
              const SizedBox(width: 8),
              _StatPill(icon: Icons.terrain_rounded, value: '${trail.elevation}m'),
              const SizedBox(width: 8),
              _StatPill(icon: Icons.straighten_rounded, value: '${trail.distance}km'),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Container(
                width: 3,
                height: 3,
                decoration: const BoxDecoration(
                  color: _kForestAccent,
                  shape: BoxShape.circle,
                ),
              ),
              const SizedBox(width: 5),
              Expanded(
                child: Text(
                  trail.bestSeason,
                  style: const TextStyle(
                    color: _kForestAccent,
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.1,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _DifficultyBadge extends StatelessWidget {
  final String difficulty;
  final Color color;

  const _DifficultyBadge({required this.difficulty, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        difficulty.toUpperCase(),
        style: TextStyle(
          color: color,
          fontSize: 9,
          fontWeight: FontWeight.w800,
          letterSpacing: 0.8,
        ),
      ),
    );
  }
}

class _StatPill extends StatelessWidget {
  final IconData icon;
  final String value;

  static const _kTextSecondary = Color(0xFF6B7F74);

  const _StatPill({required this.icon, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 11, color: _kTextSecondary),
        const SizedBox(width: 3),
        Text(
          value,
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 11.5,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _EmptyState extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final String action;
  final VoidCallback onAction;

  static const _kForestMid = Color(0xFF2D6A4F);
  static const _kTextSecondary = Color(0xFF6B7F74);

  const _EmptyState({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.action,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 40),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 72,
              height: 72,
              decoration: BoxDecoration(
                color: const Color(0xFFE8F4ED),
                borderRadius: BorderRadius.circular(24),
              ),
              child: Icon(icon, color: const Color(0xFF52B788), size: 32),
            ),
            const SizedBox(height: 20),
            Text(
              title,
              style: const TextStyle(
                color: Color(0xFF0D1F17),
                fontSize: 17,
                fontWeight: FontWeight.w700,
                letterSpacing: -0.2,
              ),
            ),
            const SizedBox(height: 6),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: _kTextSecondary,
                fontSize: 13.5,
                height: 1.5,
                fontWeight: FontWeight.w400,
              ),
            ),
            const SizedBox(height: 24),
            TextButton(
              onPressed: onAction,
              style: TextButton.styleFrom(
                backgroundColor: _kForestMid,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 12),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                action,
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FilterSheet extends StatefulWidget {
  final List<String> difficulties;
  final List<String> regions;
  final String? selectedDifficulty;
  final String? selectedRegion;
  final int? maxDuration;
  final int? maxElevation;
  final void Function(String?, String?, int?, int?) onApply;

  const _FilterSheet({
    required this.difficulties,
    required this.regions,
    required this.selectedDifficulty,
    required this.selectedRegion,
    required this.maxDuration,
    required this.maxElevation,
    required this.onApply,
  });

  @override
  State<_FilterSheet> createState() => _FilterSheetState();
}

class _FilterSheetState extends State<_FilterSheet> {
  String? _difficulty;
  String? _region;
  int? _duration;
  int? _elevation;

  static const _kForestDeep = Color(0xFF1A3C2E);
  static const _kForestMid = Color(0xFF2D6A4F);
  static const _kForestAccent = Color(0xFF52B788);
  static const _kTextPrimary = Color(0xFF0D1F17);
  static const _kTextSecondary = Color(0xFF6B7F74);
  static const _kDivider = Color(0xFFE8EDEA);

  @override
  void initState() {
    super.initState();
    _difficulty = widget.selectedDifficulty;
    _region = widget.selectedRegion;
    _duration = widget.maxDuration;
    _elevation = widget.maxElevation;
  }

  bool get _hasSelections =>
      _difficulty != null || _region != null || _duration != null || _elevation != null;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
      ),
      padding: EdgeInsets.only(
        bottom: MediaQuery.of(context).viewInsets.bottom + 24,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: 12),
          Center(
            child: Container(
              width: 36,
              height: 4,
              decoration: BoxDecoration(
                color: const Color(0xFFDDE3DF),
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  'Filter trails',
                  style: TextStyle(
                    color: _kTextPrimary,
                    fontSize: 18,
                    fontWeight: FontWeight.w700,
                    letterSpacing: -0.3,
                  ),
                ),
                if (_hasSelections)
                  GestureDetector(
                    onTap: () => setState(() {
                      _difficulty = null;
                      _region = null;
                      _duration = null;
                      _elevation = null;
                    }),
                    child: const Text(
                      'Clear all',
                      style: TextStyle(
                        color: _kForestAccent,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(height: 24),
          Flexible(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 24),
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildSection(
                    label: 'Difficulty',
                    chips: widget.difficulties,
                    selected: _difficulty,
                    onSelect: (v) => setState(() => _difficulty = v),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: _kDivider, height: 1),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Region',
                    chips: widget.regions,
                    selected: _region,
                    onSelect: (v) => setState(() => _region = v),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: _kDivider, height: 1),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Max duration',
                    chips: ['7 days', '14 days', '21 days', '30 days'],
                    values: [7, 14, 21, 30],
                    selectedValue: _duration,
                    onSelectValue: (v) => setState(() => _duration = v),
                  ),
                  const SizedBox(height: 20),
                  Divider(color: _kDivider, height: 1),
                  const SizedBox(height: 20),
                  _buildSection(
                    label: 'Max elevation',
                    chips: ['3,000 m', '4,000 m', '5,000 m', '6,000 m'],
                    values: [3000, 4000, 5000, 6000],
                    selectedValue: _elevation,
                    onSelectValue: (v) => setState(() => _elevation = v),
                  ),
                  const SizedBox(height: 28),
                ],
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.fromLTRB(24, 4, 24, 0),
            child: SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: _kForestDeep,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                ),
                onPressed: () {
                  Navigator.pop(context);
                  widget.onApply(_difficulty, _region, _duration, _elevation);
                },
                child: const Text(
                  'Apply filters',
                  style: TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 0.1,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSection({
    required String label,
    required List<String> chips,
    List<int>? values,
    String? selected,
    int? selectedValue,
    void Function(String?)? onSelect,
    void Function(int?)? onSelectValue,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label.toUpperCase(),
          style: const TextStyle(
            color: _kTextSecondary,
            fontSize: 10.5,
            fontWeight: FontWeight.w700,
            letterSpacing: 1.2,
          ),
        ),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: List.generate(chips.length, (i) {
            final isSelected = values != null
                ? selectedValue == values[i]
                : selected == chips[i];
            return GestureDetector(
              onTap: () {
                HapticFeedback.selectionClick();
                if (values != null && onSelectValue != null) {
                  onSelectValue(isSelected ? null : values[i]);
                } else if (onSelect != null) {
                  onSelect(isSelected ? null : chips[i]);
                }
              },
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 160),
                padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                decoration: BoxDecoration(
                  color: isSelected ? _kForestDeep : const Color(0xFFF4F7F5),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                    color: isSelected ? _kForestDeep : const Color(0xFFE2EAE5),
                  ),
                ),
                child: Text(
                  chips[i],
                  style: TextStyle(
                    color: isSelected ? Colors.white : _kTextPrimary,
                    fontSize: 13,
                    fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                  ),
                ),
              ),
            );
          }),
        ),
      ],
    );
  }
}