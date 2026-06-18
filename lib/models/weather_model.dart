class WeatherModel {
  final String cityName;
  final String country;
  final double temperature;
  final String description;
  final String iconUrl;
  final double humidity;
  final double windKph;
  final double feelsLike;
  final String condition;

  WeatherModel({
    required this.cityName,
    required this.country,
    required this.temperature,
    required this.description,
    required this.iconUrl,
    required this.humidity,
    required this.windKph,
    required this.feelsLike,
    required this.condition,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    final location = json['location'];
    final current = json['current'];
    final conditionData = current['condition'];

    return WeatherModel(
      cityName: location['name'] ?? '',
      country: location['country'] ?? '',
      temperature: (current['temp_c'] as num).toDouble(),
      description: conditionData['text'] ?? '',
      iconUrl: 'https:${conditionData['icon']}',
      humidity: (current['humidity'] as num).toDouble(),
      windKph: (current['wind_kph'] as num).toDouble(),
      feelsLike: (current['feelslike_c'] as num).toDouble(),
      condition: conditionData['text'] ?? '',
    );
  }

  String get temperatureString => '${temperature.toStringAsFixed(1)}°C';

  String get capitalizedDescription =>
      description.isNotEmpty
          ? description[0].toUpperCase() + description.substring(1)
          : '';
}