import 'package:flutter/material.dart';

class WeatherCard extends StatelessWidget {
  final String date;
  final double maxTemp;
  final double minTemp;

  const WeatherCard({
    super.key,
    required this.date,
    required this.maxTemp,
    required this.minTemp,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 3,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Row(
          children: [

            const Icon(
              Icons.cloud,
              size: 40,
            ),

            const SizedBox(width: 16),

            Expanded(
              child: Text(
                date,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),

            Column(
              crossAxisAlignment:
              CrossAxisAlignment.end,
              children: [
                Text(
                  "Max ${maxTemp.toStringAsFixed(1)}°C",
                ),
                Text(
                  "Min ${minTemp.toStringAsFixed(1)}°C",
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}