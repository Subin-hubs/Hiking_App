import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
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

  Color _pinColor(PinType type) {
    switch (type) {
      case PinType.start: return Colors.green[700]!;
      case PinType.viewpoint: return Colors.blue[700]!;
      case PinType.campsite: return Colors.orange[700]!;
      case PinType.temple: return Colors.purple[700]!;
      case PinType.hospital: return Colors.red[700]!;
    }
  }

  IconData _pinIcon(PinType type) {
    switch (type) {
      case PinType.start: return Icons.flag;
      case PinType.viewpoint: return Icons.remove_red_eye;
      case PinType.campsite: return Icons.cabin;
      case PinType.temple: return Icons.temple_buddhist;
      case PinType.hospital: return Icons.local_hospital;
    }
  }

  String _pinLabel(PinType type) {
    switch (type) {
      case PinType.start: return 'Start';
      case PinType.viewpoint: return 'View';
      case PinType.campsite: return 'Camp';
      case PinType.temple: return 'Temple';
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
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.green[700],
        foregroundColor: Colors.white,
        title: const Text('Trail Map', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          IconButton(
            icon: const Icon(Icons.my_location),
            onPressed: () {
              _mapController.move(LatLng(28.3949, 84.1240), 7);
            },
          ),
        ],
      ),
      body: Stack(
        children: [
          // ── Map ──
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
                  return Marker(
                    point: pin.position,
                    width: isSelected ? 48 : 38,
                    height: isSelected ? 48 : 38,
                    child: GestureDetector(
                      onTap: () => setState(() => _selectedPin = pin),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: _pinColor(pin.type),
                          shape: BoxShape.circle,
                          border: Border.all(color: Colors.white, width: isSelected ? 3 : 2),
                          boxShadow: [
                            BoxShadow(
                              color: _pinColor(pin.type).withOpacity(0.4),
                              blurRadius: isSelected ? 12 : 6,
                              spreadRadius: isSelected ? 2 : 0,
                            ),
                          ],
                        ),
                        child: Icon(
                          _pinIcon(pin.type),
                          color: Colors.white,
                          size: isSelected ? 24 : 18,
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
            ],
          ),

          // ── Filter Chips ──
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
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      decoration: BoxDecoration(
                        color: active ? _pinColor(type) : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        boxShadow: [
                          BoxShadow(color: Colors.black.withOpacity(0.12), blurRadius: 6, offset: const Offset(0, 2)),
                        ],
                      ),
                      child: Row(
                        children: [
                          Icon(_pinIcon(type), color: active ? Colors.white : _pinColor(type), size: 14),
                          const SizedBox(width: 5),
                          Text(
                            _pinLabel(type),
                            style: TextStyle(
                              color: active ? Colors.white : Colors.grey[700],
                              fontWeight: FontWeight.w600,
                              fontSize: 12,
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

          // ── Info Card ──
          if (_selectedPin != null)
            Positioned(
              bottom: 20,
              left: 16,
              right: 16,
              child: AnimatedSlide(
                offset: _selectedPin != null ? Offset.zero : const Offset(0, 1),
                duration: const Duration(milliseconds: 300),
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(color: Colors.black.withOpacity(0.15), blurRadius: 20, offset: const Offset(0, 5)),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _pinColor(_selectedPin!.type).withOpacity(0.1),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Icon(_pinIcon(_selectedPin!.type), color: _pinColor(_selectedPin!.type), size: 22),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  _selectedPin!.name,
                                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: screenWidth * 0.04),
                                ),
                                Row(
                                  children: [
                                    Icon(Icons.location_on, size: 12, color: Colors.grey[500]),
                                    const SizedBox(width: 2),
                                    Text(
                                      _selectedPin!.region,
                                      style: TextStyle(color: Colors.grey[500], fontSize: 12),
                                    ),
                                    if (_selectedPin!.elevation != null) ...[
                                      const SizedBox(width: 8),
                                      Text('⛰ ${_selectedPin!.elevation}', style: TextStyle(color: Colors.grey[500], fontSize: 12)),
                                    ],
                                  ],
                                ),
                              ],
                            ),
                          ),
                          GestureDetector(
                            onTap: () => setState(() => _selectedPin = null),
                            child: Icon(Icons.close, color: Colors.grey[400], size: 20),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Text(
                        _selectedPin!.description,
                        style: TextStyle(color: Colors.grey[600], fontSize: screenWidth * 0.033, height: 1.4),
                      ),
                      const SizedBox(height: 14),
                      Row(
                        children: [
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openInMaps(_selectedPin!.position, _selectedPin!.name),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.directions, color: Colors.grey[700], size: 16),
                                    const SizedBox(width: 6),
                                    Text('Directions', style: TextStyle(color: Colors.grey[700], fontWeight: FontWeight.w600, fontSize: 13)),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: GestureDetector(
                              onTap: () => _openWebSearch(_selectedPin!.name),
                              child: Container(
                                padding: const EdgeInsets.symmetric(vertical: 10),
                                decoration: BoxDecoration(
                                  color: Colors.green[700],
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: const Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Icon(Icons.open_in_browser, color: Colors.white, size: 16),
                                    SizedBox(width: 6),
                                    Text('View More', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600, fontSize: 13)),
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

          // ── Legend ──
          Positioned(
            bottom: _selectedPin != null ? screenHeight * 0.28 : 20,
            right: 16,
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8, offset: const Offset(0, 2)),
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
                        width: 10,
                        height: 10,
                        decoration: BoxDecoration(color: _pinColor(type), shape: BoxShape.circle),
                      ),
                      const SizedBox(width: 6),
                      Text(_pinLabel(type), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w500)),
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