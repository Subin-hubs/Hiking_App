import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:hiking/utils/app_theme.dart';
import 'package:latlong2/latlong.dart';
import 'package:url_launcher/url_launcher.dart';

enum PinType { start, viewpoint, campsite, temple, hospital }

class MapPin {
  final String name;
  final String description;
  final String region;
  final LatLng position;
  final PinType type;
  final String? elevation;

  const MapPin({
    required this.name,
    required this.description,
    required this.region,
    required this.position,
    required this.type,
    this.elevation,
  });
}

class MapScreen extends StatefulWidget {
  const MapScreen({super.key});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  final MapController _mapController = MapController();
  MapPin? _selectedPin;
  Set<PinType> _activeFilters = PinType.values.toSet();

  final List<MapPin> _pins = [
    // ── Starting Points ──
    MapPin(name: 'Lukla Airport', description: 'Main gateway to Everest region treks. Fly from Kathmandu.', region: 'Everest', position: LatLng(27.6869, 86.7314), type: PinType.start, elevation: '2,860m'),
    MapPin(name: 'Syabrubesi', description: 'Starting point for Langtang Valley trek.', region: 'Langtang', position: LatLng(28.1591, 85.3456), type: PinType.start, elevation: '1,550m'),
    MapPin(name: 'Nayapul', description: 'Start of Annapurna Base Camp and Poon Hill treks.', region: 'Annapurna', position: LatLng(28.3667, 83.8833), type: PinType.start, elevation: '1,070m'),
    MapPin(name: 'Besisahar', description: 'Starting point of Annapurna Circuit trek.', region: 'Annapurna', position: LatLng(28.2333, 84.3833), type: PinType.start, elevation: '760m'),
    MapPin(name: 'Soti Khola', description: 'Gateway to Manaslu Circuit trek.', region: 'Manaslu', position: LatLng(28.3833, 84.8667), type: PinType.start, elevation: '730m'),
    MapPin(name: 'Jomsom', description: 'Start of Upper Mustang trek. Fly from Pokhara.', region: 'Mustang', position: LatLng(28.7797, 83.7269), type: PinType.start, elevation: '2,720m'),

    // ── Viewpoints ──
    MapPin(name: 'Kala Patthar', description: 'Best viewpoint of Mount Everest at 5,645m. Iconic sunrise spot.', region: 'Everest', position: LatLng(27.9947, 86.8311), type: PinType.viewpoint, elevation: '5,645m'),
    MapPin(name: 'Poon Hill', description: 'Famous sunrise viewpoint with panoramic Annapurna views.', region: 'Annapurna', position: LatLng(28.4000, 83.6900), type: PinType.viewpoint, elevation: '3,210m'),
    MapPin(name: 'Gokyo Ri', description: '360° panorama of Everest, Lhotse, Makalu and Cho Oyu.', region: 'Everest', position: LatLng(27.9617, 86.6833), type: PinType.viewpoint, elevation: '5,357m'),
    MapPin(name: 'Tserko Ri', description: 'Best viewpoint in Langtang with views of Gangchempo.', region: 'Langtang', position: LatLng(28.2138, 85.5517), type: PinType.viewpoint, elevation: '4,984m'),
    MapPin(name: 'Thorong La Pass', description: 'Highest point of Annapurna Circuit at 5,416m.', region: 'Annapurna', position: LatLng(28.7900, 83.9300), type: PinType.viewpoint, elevation: '5,416m'),

    // ── Campsites ──
    MapPin(name: 'Gorak Shep', description: 'Last settlement before Everest Base Camp. Basic teahouses.', region: 'Everest', position: LatLng(27.9783, 86.8297), type: PinType.campsite, elevation: '5,164m'),
    MapPin(name: 'Kyanjin Gompa', description: 'Main camping and teahouse area in Langtang Valley.', region: 'Langtang', position: LatLng(28.2114, 85.5639), type: PinType.campsite, elevation: '3,817m'),
    MapPin(name: 'Manang', description: 'Acclimatization stop on Annapurna Circuit with good facilities.', region: 'Annapurna', position: LatLng(28.6667, 84.0167), type: PinType.campsite, elevation: '3,519m'),
    MapPin(name: 'Namche Bazaar', description: 'Main hub of Everest region with shops, cafes and lodges.', region: 'Everest', position: LatLng(27.8069, 86.7139), type: PinType.campsite, elevation: '3,440m'),

    // ── Temples ──
    MapPin(name: 'Tengboche Monastery', description: 'Famous Buddhist monastery with stunning Ama Dablam views.', region: 'Everest', position: LatLng(27.8361, 86.7642), type: PinType.temple, elevation: '3,867m'),
    MapPin(name: 'Muktinath Temple', description: 'Sacred Hindu and Buddhist pilgrimage site on Annapurna Circuit.', region: 'Annapurna', position: LatLng(28.8167, 83.8667), type: PinType.temple, elevation: '3,800m'),
    MapPin(name: 'Pashupatinath Temple', description: 'Nepal\'s most sacred Hindu temple in Kathmandu.', region: 'Kathmandu', position: LatLng(27.7105, 85.3487), type: PinType.temple, elevation: '1,400m'),
    MapPin(name: 'Boudhanath Stupa', description: 'One of the largest stupas in the world. UNESCO heritage site.', region: 'Kathmandu', position: LatLng(27.7215, 85.3620), type: PinType.temple, elevation: '1,400m'),
    MapPin(name: 'Pungyen Gompa', description: 'Ancient monastery on the Manaslu Circuit trail.', region: 'Manaslu', position: LatLng(28.6500, 84.7167), type: PinType.temple, elevation: '4,050m'),

    // ── Hospitals ──
    MapPin(name: 'Himalayan Rescue Assoc. Manang', description: 'Altitude sickness clinic. Open Oct-Nov, Mar-May.', region: 'Annapurna', position: LatLng(28.6700, 84.0200), type: PinType.hospital, elevation: '3,519m'),
    MapPin(name: 'Himalayan Rescue Assoc. Pheriche', description: 'Medical clinic for Everest trekkers. Altitude consultations.', region: 'Everest', position: LatLng(27.8944, 86.8186), type: PinType.hospital, elevation: '4,371m'),
    MapPin(name: 'TUTH Hospital Kathmandu', description: 'Main government hospital. 24/7 emergency services.', region: 'Kathmandu', position: LatLng(27.7172, 85.3155), type: PinType.hospital, elevation: '1,400m'),
    MapPin(name: 'Western Regional Hospital', description: 'Main hospital in Pokhara for western Nepal.', region: 'Annapurna', position: LatLng(28.2096, 83.9856), type: PinType.hospital, elevation: '822m'),
  ];

  List<MapPin> get _filteredPins =>
      _pins.where((p) => _activeFilters.contains(p.type)).toList();

  // ── Pin colours mapped to AppColors ──────────────────────────────────────
  Color _pinColor(PinType type) {
    switch (type) {
      case PinType.start:    return AppColors.mid;       // forest green
      case PinType.viewpoint: return AppColors.accent;   // light green
      case PinType.campsite: return AppColors.warning;   // amber
      case PinType.temple:   return AppColors.deep;      // dark green
      case PinType.hospital: return AppColors.error;     // red
    }
  }

  IconData _pinIcon(PinType type) {
    switch (type) {
      case PinType.start:    return Icons.flag;
      case PinType.viewpoint: return Icons.remove_red_eye;
      case PinType.campsite: return Icons.cabin;
      case PinType.temple:   return Icons.temple_buddhist;
      case PinType.hospital: return Icons.local_hospital;
    }
  }

  String _pinLabel(PinType type) {
    switch (type) {
      case PinType.start:    return 'Start';
      case PinType.viewpoint: return 'View';
      case PinType.campsite: return 'Camp';
      case PinType.temple:   return 'Temple';
      case PinType.hospital: return 'Hospital';
    }
  }

  Future<void> _openInMaps(LatLng position, String name) async {
    final encodedName = Uri.encodeComponent(name);
    final geoUri = Uri.parse('geo:${position.latitude},${position.longitude}?q=${position.latitude},${position.longitude}($encodedName)');
    final webUri = Uri.parse('https://maps.google.com/maps?q=${position.latitude},${position.longitude}');
    if (await canLaunchUrl(geoUri)) {
      await launchUrl(geoUri);
    } else {
      await launchUrl(webUri, mode: LaunchMode.platformDefault);
    }
  }

  Future<void> _openWebSearch(String name) async {
    final encodedName = Uri.encodeComponent('$name Nepal');
    final uri = Uri.parse('https://www.google.com/search?q=$encodedName');
    await launchUrl(uri, mode: LaunchMode.platformDefault);
  }

  @override
  Widget build(BuildContext context) {
    final size   = MediaQuery.of(context).size;
    final w      = size.width;
    final h      = size.height;

    // Responsive breakpoints
    final isTablet  = w >= 600;
    final isDesktop = w >= 900;

    final double chipPadH   = isDesktop ? 16 : (isTablet ? 14 : 12);
    final double chipPadV   = isDesktop ? 10 : (isTablet ? 9  : 8);
    final double chipFontSz = isDesktop ? 14 : (isTablet ? 13 : 12);
    final double chipIconSz = isDesktop ? 16 : (isTablet ? 15 : 14);

    final double cardPadding    = isDesktop ? 24 : (isTablet ? 20 : 16);
    final double cardRadius     = isDesktop ? 24 : (isTablet ? 22 : 20);
    final double cardNameFontSz = isDesktop ? 18 : (isTablet ? 16 : w * 0.04);
    final double cardDescFontSz = isDesktop ? 14 : (isTablet ? 13 : w * 0.033);
    final double cardIconSize   = isDesktop ? 28 : (isTablet ? 25 : 22);

    final double markerSize         = isTablet ? 46 : 38;
    final double markerSizeSelected = isTablet ? 58 : 48;

    // Card bottom offset so legend doesn't overlap
    final double cardBottomOffset    = isTablet ? 24 : 20;
    final double legendBottomNormal  = isTablet ? 24 : 20;
    final double legendBottomWithCard = isDesktop
        ? h * 0.22
        : (isTablet ? h * 0.25 : h * 0.28);

    return Scaffold(
      backgroundColor: AppColors.surface,
      appBar: AppBar(
        // Uses AppBarTheme from AppTheme — deep green bg, white text
        title: const Text('Trail Map'),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () => _mapController.move(LatLng(28.3949, 84.1240), 7),
          ),
        ],
      ),
      body: Stack(
        children: [

          // ── Map ────────────────────────────────────────────────────────────
          FlutterMap(
            mapController: _mapController,
            options: MapOptions(
              initialCenter: LatLng(28.3949, 84.1240),
              initialZoom: 7,
              onTap: (_, __) => setState(() => _selectedPin = null),
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.hiking',
              ),
              MarkerLayer(
                markers: _filteredPins.map((pin) {
                  final isSelected = _selectedPin == pin;
                  final sz = isSelected ? markerSizeSelected : markerSize;
                  return Marker(
                    point: pin.position,
                    width: sz,
                    height: sz,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPin = pin),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _pinColor(pin.type),
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.card,
                            width: isSelected ? 3 : 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: _pinColor(pin.type).withOpacity(0.4),
                              blurRadius: isSelected ? 14 : 6,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _pinIcon(pin.type),
                          color: AppColors.card,
                          size: isSelected ? (isTablet ? 28 : 24) : (isTablet ? 22 : 18),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Filter Chips ───────────────────────────────────────────────────
          Positioned(
            top: 12,
            left: 12,
            right: 12,
            child: SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                children: PinType.values.map((type) {
                  final active = _activeFilters.contains(type);
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        if (active && _activeFilters.length > 1) {
                          _activeFilters.remove(type);
                        } else if (!active) {
                          _activeFilters.add(type);
                        }
                      });
                    },
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 200),
                      margin: const EdgeInsets.only(right: 8),
                      padding: EdgeInsets.symmetric(horizontal: chipPadH, vertical: chipPadV),
                      decoration: BoxDecoration(
                        color: active ? _pinColor(type) : AppColors.card,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                          color: active ? _pinColor(type) : AppColors.border,
                          width: 1,
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.deep.withOpacity(0.10),
                            blurRadius: 6,
                            offset: const Offset(0, 2),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(
                            _pinIcon(type),
                            color: active ? AppColors.card : _pinColor(type),
                            size: chipIconSz,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            _pinLabel(type),
                            style: TextStyle(
                              color: active ? AppColors.card : AppColors.text2,
                              fontWeight: FontWeight.w600,
                              fontSize: chipFontSz,
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),

          // ── Info Card ──────────────────────────────────────────────────────
          if (_selectedPin != null)
            Positioned(
              bottom: cardBottomOffset,
              left: isDesktop ? w * 0.25 : 16,
              right: isDesktop ? w * 0.25 : 16,
              child: AnimatedSlide(
                offset: Offset.zero,
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: EdgeInsets.all(cardPadding),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(cardRadius),
                    border: Border.all(color: AppColors.border),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.deep.withOpacity(0.15),
                        blurRadius: 20,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: EdgeInsets.all(isTablet ? 10 : 8),
                            decoration: BoxDecoration(
                              color: _pinColor(_selectedPin!.type).withOpacity(0.12),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(
                              _pinIcon(_selectedPin!.type),
                              color: _pinColor(_selectedPin!.type),
                              size: cardIconSize,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPin!.name,
                                  style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: cardNameFontSz,
                                    color: AppColors.text1,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 12, color: AppColors.text2),
                                    const SizedBox(width: 2),
                                    Text(
                                      _selectedPin!.region,
                                      style: TextStyle(color: AppColors.text2, fontSize: 12),
                                    ),
                                    if (_selectedPin!.elevation != null) ...[
                                      const SizedBox(width: 8),
                                      Text(
                                        '⛰ ${_selectedPin!.elevation}',
                                        style: TextStyle(color: AppColors.text2, fontSize: 12),
                                      ),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _selectedPin = null),
                            child: Icon(Icons.close, color: AppColors.text2, size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedPin!.description,
                        style: TextStyle(
                          color: AppColors.text2,
                          fontSize: cardDescFontSz,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          // Directions button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openInMaps(_selectedPin!.position, _selectedPin!.name),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: AppColors.surface,
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions, color: AppColors.mid, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'Directions',
                                      style: TextStyle(
                                        color: AppColors.mid,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 14 : 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          // View More button
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openWebSearch(_selectedPin!.name),
                              child: Container(
                                padding: EdgeInsets.symmetric(vertical: isTablet ? 12 : 10),
                                decoration: BoxDecoration(
                                  color: AppColors.mid,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.open_in_browser, color: AppColors.card, size: 16),
                                    const SizedBox(width: 6),
                                    Text(
                                      'View More',
                                      style: TextStyle(
                                        color: AppColors.card,
                                        fontWeight: FontWeight.w600,
                                        fontSize: isTablet ? 14 : 13,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // ── Legend ─────────────────────────────────────────────────────────
          Positioned(
            bottom: _selectedPin != null ? legendBottomWithCard : legendBottomNormal,
            right: 16,
            child: Container(
              padding: EdgeInsets.all(isTablet ? 12 : 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.border),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.deep.withOpacity(0.10),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: PinType.values.map((type) => Padding(
                  padding: const EdgeInsets.symmetric(vertical: 3),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Container(
                        width: isTablet ? 12 : 10,
                        height: isTablet ? 12 : 10,
                        decoration: BoxDecoration(
                          color: _pinColor(type),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 6),
                      Text(
                        _pinLabel(type),
                        style: TextStyle(
                          fontSize: isTablet ? 13 : 11,
                          fontWeight: FontWeight.w500,
                          color: AppColors.text1,
                        ),
                      ),
                    ],
                  ),
                )).toList(),
              ),
            ),
          ),

        ],
      ),
    );
  }
}