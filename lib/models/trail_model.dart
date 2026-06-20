import 'package:flutter/material.dart';
import 'package:hive/hive.dart';

part 'trail_model.g.dart';

@HiveType(typeId: 0)
class TrailModel extends HiveObject {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String region;

  @HiveField(3)
  final String difficulty;

  @HiveField(4)
  final int duration;

  @HiveField(5)
  final int elevation;

  @HiveField(6)
  final double distance;

  @HiveField(7)
  final String description;

  @HiveField(8)
  final String imageUrl;

  @HiveField(9)
  final List<String> highlights;

  @HiveField(10)
  final String startPoint;

  @HiveField(11)
  final String bestSeason;

  TrailModel({
    required this.id,
    required this.name,
    required this.region,
    required this.difficulty,
    required this.duration,
    required this.elevation,
    required this.distance,
    required this.description,
    required this.imageUrl,
    required this.highlights,
    required this.startPoint,
    required this.bestSeason,
  });

  factory TrailModel.fromFirestore(Map<String, dynamic> json, String id) {
    return TrailModel(
      id: id,
      name: json['name'] ?? '',
      region: json['region'] ?? '',
      difficulty: json['difficulty'] ?? '',
      duration: (json['duration'] as num?)?.toInt() ?? 0,
      elevation: (json['elevation'] as num?)?.toInt() ?? 0,
      distance: (json['distance'] as num?)?.toDouble() ?? 0.0,
      description: json['description'] ?? '',
      imageUrl: json['imageUrl'] ?? '',
      highlights: List<String>.from(json['highlights'] ?? []),
      startPoint: json['startPoint'] ?? '',
      bestSeason: json['bestSeason'] ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'name': name,
    'region': region,
    'difficulty': difficulty,
    'duration': duration,
    'elevation': elevation,
    'distance': distance,
    'description': description,
    'imageUrl': imageUrl,
    'highlights': highlights,
    'startPoint': startPoint,
    'bestSeason': bestSeason,
  };

  Color get difficultyColor {
    switch (difficulty.toLowerCase()) {
      case 'easy':
        return const Color(0xFF2E7D32);
      case 'moderate':
        return const Color(0xFFF57F17);
      case 'hard':
        return const Color(0xFFE65100);
      case 'expert':
        return const Color(0xFFB71C1C);
      default:
        return const Color(0xFF2E7D32);
    }
  }
}