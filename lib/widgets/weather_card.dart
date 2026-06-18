import 'package:flutter/material.dart';
import '../models/weather_model.dart';

class WeatherCard extends StatelessWidget {
  final WeatherModel weather;
  final String elevation;
  final String locationDescription;

  const WeatherCard({
    super.key,
    required this.weather,
    this.elevation = '',
    this.locationDescription = '',
  });

  Color _getTempColor(double temp) {
    if (temp <= 0) return Colors.blue[200]!;
    if (temp <= 10) return Colors.blue[400]!;
    if (temp <= 20) return Colors.green[400]!;
    if (temp <= 30) return Colors.orange[400]!;
    return Colors.red[400]!;
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    final iconSize = screenWidth * 0.12;
    final titleFontSize = screenWidth * 0.048;
    final subFontSize = screenWidth * 0.030;
    final tempFontSize = screenWidth * 0.044;
    final statValueFontSize = screenWidth * 0.032;
    final statLabelFontSize = screenWidth * 0.027;
    final descFontSize = screenWidth * 0.034;
    final cardPadding = screenWidth * 0.04;
    final verticalSpacing = screenHeight * 0.015;

    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: screenWidth * 0.04,
        vertical: screenHeight * 0.008,
      ),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [Colors.green[800]!, Colors.green[600]!],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(screenWidth * 0.05),
        boxShadow: [
          BoxShadow(
            color: Colors.green.withOpacity(0.3),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Padding(
        padding: EdgeInsets.all(cardPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        weather.cityName,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: titleFontSize,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      if (locationDescription.isNotEmpty)
                        Text(
                          locationDescription,
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.8),
                            fontSize: subFontSize,
                          ),
                        ),
                      if (elevation.isNotEmpty)
                        Text(
                          '⛰ $elevation',
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.7),
                            fontSize: subFontSize,
                          ),
                        ),
                    ],
                  ),
                ),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Image.network(
                      weather.iconUrl,
                      width: iconSize,
                      height: iconSize,
                      errorBuilder: (_, __, ___) => Icon(
                        Icons.cloud,
                        color: Colors.white,
                        size: iconSize,
                      ),
                    ),
                    Container(
                      padding: EdgeInsets.symmetric(
                        horizontal: screenWidth * 0.025,
                        vertical: screenHeight * 0.004,
                      ),
                      decoration: BoxDecoration(
                        color: _getTempColor(weather.temperature),
                        borderRadius: BorderRadius.circular(screenWidth * 0.05),
                      ),
                      child: Text(
                        weather.temperatureString,
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: tempFontSize,
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),

            SizedBox(height: verticalSpacing),

            Text(
              weather.capitalizedDescription,
              style: TextStyle(
                color: Colors.white.withOpacity(0.9),
                fontSize: descFontSize,
              ),
            ),

            SizedBox(height: verticalSpacing),

            Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                _statItem(
                  Icons.water_drop,
                  '${weather.humidity.toInt()}%',
                  'Humidity',
                  statValueFontSize,
                  statLabelFontSize,
                ),
                _statItem(
                  Icons.air,
                  '${weather.windKph.toStringAsFixed(1)} km/h',
                  'Wind',
                  statValueFontSize,
                  statLabelFontSize,
                ),
                _statItem(
                  Icons.thermostat,
                  '${weather.feelsLike.toStringAsFixed(1)}°C',
                  'Feels Like',
                  statValueFontSize,
                  statLabelFontSize,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(
      IconData icon,
      String value,
      String label,
      double valueFontSize,
      double labelFontSize,
      ) {
    return Column(
      children: [
        Icon(icon, color: Colors.white70, size: valueFontSize + 4),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
            fontSize: valueFontSize,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.white.withOpacity(0.7),
            fontSize: labelFontSize,
          ),
        ),
      ],
    );
  }
}