import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:geolocator/geolocator.dart';

class EmergencyScreen extends StatefulWidget {
  const EmergencyScreen({super.key});

  @override
  State<EmergencyScreen> createState() => _EmergencyScreenState();
}

class _EmergencyScreenState extends State<EmergencyScreen> {
  bool _isGettingLocation = false;
  String? _locationText;

  final List<Map<String, dynamic>> _emergencyContacts = [
    {
      'category': 'Nepal Police',
      'icon': Icons.local_police,
      'color': Color(0xFF1565C0),
      'contacts': [
        {'name': 'Nepal Police', 'number': '100'},
        {'name': 'Tourist Police', 'number': '1144'},
      ],
    },
    {
      'category': 'Medical',
      'icon': Icons.local_hospital,
      'color': Color(0xFFC62828),
      'contacts': [
        {'name': 'Ambulance', 'number': '102'},
        {'name': 'TUTH Hospital', 'number': '+977-1-4412303'},
      ],
    },
    {
      'category': 'Mountain Rescue',
      'icon': Icons.hiking,
      'color': Color(0xFF2E7D32),
      'contacts': [
        {'name': 'Nepal Mountain Rescue', 'number': '+977-1-4111111'},
        {'name': 'Himalayan Rescue Assoc.', 'number': '+977-1-4440292'},
      ],
    },
    {
      'category': 'Helicopter Rescue',
      'icon': Icons.air,
      'color': Color(0xFFE65100),
      'contacts': [
        {'name': 'Fishtail Air Rescue', 'number': '+977-1-4111599'},
        {'name': 'Simrik Air Rescue', 'number': '+977-1-4467388'},
      ],
    },
  ];

  Future<void> _makeCall(String number) async {
    final uri = Uri.parse('tel:$number');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackbar('Could not launch call');
    }
  }

  Future<void> _sendSMS(String number, {String message = ''}) async {
    final uri = Uri.parse('sms:$number?body=${Uri.encodeComponent(message)}');
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    } else {
      _showSnackbar('Could not open SMS');
    }
  }

  Future<String?> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      _showSnackbar('Location services are disabled');
      return null;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        _showSnackbar('Location permission denied');
        return null;
      }
    }

    if (permission == LocationPermission.deniedForever) {
      _showSnackbar('Location permission permanently denied');
      return null;
    }

    final position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.high,
    );

    return 'https://maps.google.com/?q=${position.latitude},${position.longitude}';
  }

  Future<void> _sosAction() async {
    setState(() => _isGettingLocation = true);

    final locationUrl = await _getCurrentLocation();

    setState(() {
      _isGettingLocation = false;
      _locationText = locationUrl;
    });

    final message = locationUrl != null
        ? 'SOS! I need emergency help. My location: $locationUrl'
        : 'SOS! I need emergency help. Please contact me immediately.';

    await _sendSMS('100', message: message);
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red[700]),
    );
  }

  void _showContactOptions(
      BuildContext context, String name, String number) {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey[300],
                borderRadius: BorderRadius.circular(2),
              ),
            ),
            const SizedBox(height: 16),
            Text(
              name,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            Text(
              number,
              style: TextStyle(color: Colors.grey[600], fontSize: 14),
            ),
            const SizedBox(height: 20),
            _bottomSheetButton(
              icon: Icons.call,
              label: 'Call',
              color: Colors.green[700]!,
              onTap: () {
                Navigator.pop(context);
                _makeCall(number);
              },
            ),
            const SizedBox(height: 10),
            _bottomSheetButton(
              icon: Icons.sms,
              label: 'Send SMS',
              color: Colors.blue[700]!,
              onTap: () {
                Navigator.pop(context);
                _sendSMS(number);
              },
            ),
            const SizedBox(height: 10),
            _bottomSheetButton(
              icon: Icons.location_on,
              label: 'Share Location via SMS',
              color: Colors.orange[700]!,
              onTap: () async {
                Navigator.pop(context);
                final loc = await _getCurrentLocation();
                final msg = loc != null
                    ? 'My current location: $loc'
                    : 'I need help. Please contact me.';
                _sendSMS(number, message: msg);
              },
            ),
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }

  Widget _bottomSheetButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: Colors.white, size: 20),
            const SizedBox(width: 8),
            Text(
              label,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      backgroundColor: const Color(0xFFF2F4F3),
      appBar: AppBar(
        backgroundColor: Colors.red[700],
        foregroundColor: Colors.white,
        title: const Text(
          'Emergency',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(screenWidth * 0.04),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: screenHeight * 0.02),

            GestureDetector(
              onTap: _isGettingLocation ? null : _sosAction,
              child: Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: screenHeight * 0.03),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFFB71C1C), Color(0xFFE53935)],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.red.withOpacity(0.4),
                      blurRadius: 15,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _isGettingLocation
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Icon(
                      Icons.sos,
                      color: Colors.white,
                      size: screenWidth * 0.18,
                    ),
                    SizedBox(height: screenHeight * 0.01),
                    Text(
                      _isGettingLocation
                          ? 'Getting your location...'
                          : 'TAP FOR SOS',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: screenWidth * 0.055,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 2,
                      ),
                    ),
                    SizedBox(height: screenHeight * 0.005),
                    Text(
                      'Sends SMS with your location to Nepal Police',
                      style: TextStyle(
                        color: Colors.white.withOpacity(0.8),
                        fontSize: screenWidth * 0.030,
                      ),
                    ),
                  ],
                ),
              ),
            ),

            if (_locationText != null) ...[
              SizedBox(height: screenHeight * 0.015),
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.green[50],
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.green[300]!),
                ),
                child: Row(
                  children: [
                    Icon(Icons.check_circle, color: Colors.green[700], size: 20),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(
                        'Location captured & SMS sent!',
                        style: TextStyle(
                          color: Colors.green[700],
                          fontWeight: FontWeight.w600,
                          fontSize: screenWidth * 0.032,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            SizedBox(height: screenHeight * 0.03),

            Text(
              'Emergency Contacts',
              style: TextStyle(
                fontSize: screenWidth * 0.05,
                fontWeight: FontWeight.bold,
              ),
            ),

            SizedBox(height: screenHeight * 0.015),

            ..._emergencyContacts.map((category) {
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(
                        category['icon'] as IconData,
                        color: category['color'] as Color,
                        size: screenWidth * 0.05,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        category['category'] as String,
                        style: TextStyle(
                          fontSize: screenWidth * 0.04,
                          fontWeight: FontWeight.bold,
                          color: category['color'] as Color,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: screenHeight * 0.01),
                  ...(category['contacts'] as List<Map<String, String>>)
                      .map((contact) => _contactCard(
                    context,
                    contact['name']!,
                    contact['number']!,
                    category['color'] as Color,
                    screenWidth,
                    screenHeight,
                  )),
                  SizedBox(height: screenHeight * 0.02),
                ],
              );
            }),

            SizedBox(height: screenHeight * 0.02),

            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.amber[50],
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: Colors.amber[300]!),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.info_outline, color: Colors.amber[700], size: 20),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'In high altitude areas, cell coverage may be limited. Always carry a whistle and inform someone of your trekking plans before heading out.',
                      style: TextStyle(
                        color: Colors.amber[900],
                        fontSize: screenWidth * 0.030,
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(height: screenHeight * 0.03),
          ],
        ),
      ),
    );
  }

  Widget _contactCard(
      BuildContext context,
      String name,
      String number,
      Color color,
      double screenWidth,
      double screenHeight,
      ) {
    return GestureDetector(
      onTap: () => _showContactOptions(context, name, number),
      child: Container(
        margin: EdgeInsets.only(bottom: screenHeight * 0.01),
        padding: EdgeInsets.symmetric(
          horizontal: screenWidth * 0.04,
          vertical: screenHeight * 0.015,
        ),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(14),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.06),
              blurRadius: 8,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Row(
          children: [
            Container(
              width: screenWidth * 0.1,
              height: screenWidth * 0.1,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(Icons.phone, color: color, size: screenWidth * 0.05),
            ),
            SizedBox(width: screenWidth * 0.03),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: screenWidth * 0.036,
                    ),
                  ),
                  Text(
                    number,
                    style: TextStyle(
                      color: Colors.grey[600],
                      fontSize: screenWidth * 0.030,
                    ),
                  ),
                ],
              ),
            ),
            Row(
              children: [
                _actionIcon(Icons.call, Colors.green[700]!, () => _makeCall(number), screenWidth),
                SizedBox(width: screenWidth * 0.02),
                _actionIcon(Icons.chat, Colors.blue[700]!, () => _sendSMS(number), screenWidth),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _actionIcon(
      IconData icon,
      Color color,
      VoidCallback onTap,
      double screenWidth,
      ) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(screenWidth * 0.02),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Icon(icon, color: color, size: screenWidth * 0.045),
      ),
    );
  }
}