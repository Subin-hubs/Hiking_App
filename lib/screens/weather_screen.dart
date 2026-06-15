import 'package:flutter/material.dart';

import '../models/weather_model.dart';
import '../services/weather_service.dart';
import '../widgets/weather_card.dart';

class WeatherScreen extends StatelessWidget {

  final double latitude;
  final double longitude;
  final String trailName;

  const WeatherScreen({
    super.key,
    required this.latitude,
    required this.longitude,
    required this.trailName,
  });

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      appBar: AppBar(
        title: Text(
          '$trailName Weather',
        ),
      ),

      body: FutureBuilder<WeatherModel>(
        future: WeatherService().getWeather(
          latitude,
          longitude,
        ),

        builder: (context, snapshot) {

          if (snapshot.connectionState ==
              ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {
            return Center(
              child: Text(
                snapshot.error.toString(),
              ),
            );
          }

          final weather = snapshot.data!;

          return ListView.builder(
            itemCount:
            weather.dates.length,

            itemBuilder: (
                context,
                index,
                ) {

              return WeatherCard(
                date:
                weather.dates[index],

                maxTemp:
                weather.maxTemps[index],

                minTemp:
                weather.minTemps[index],
              );
            },
          );
        },
      ),
    );
  }
}