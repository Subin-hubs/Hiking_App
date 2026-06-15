class WeatherModel {
  final List<String> dates;
  final List<double> maxTemps;
  final List<double> minTemps;

  WeatherModel({
    required this.dates,
    required this.maxTemps,
    required this.minTemps,
  });

  factory WeatherModel.fromJson(Map<String, dynamic> json) {
    return WeatherModel(
      dates: List<String>.from(
        json['daily']['time'],
      ),
      maxTemps: List<double>.from(
        json['daily']['temperature_2m_max'],
      ),
      minTemps: List<double>.from(
        json['daily']['temperature_2m_min'],
      ),
    );
  }
}