// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'trail_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class TrailModelAdapter extends TypeAdapter<TrailModel> {
  @override
  final int typeId = 0;

  @override
  TrailModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return TrailModel(
      id: fields[0] as String,
      name: fields[1] as String,
      region: fields[2] as String,
      difficulty: fields[3] as String,
      duration: fields[4] as int,
      elevation: fields[5] as int,
      distance: fields[6] as double,
      description: fields[7] as String,
      imageUrl: fields[8] as String,
      highlights: (fields[9] as List).cast<String>(),
      startPoint: fields[10] as String,
      bestSeason: fields[11] as String,
    );
  }

  @override
  void write(BinaryWriter writer, TrailModel obj) {
    writer
      ..writeByte(12)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.region)
      ..writeByte(3)
      ..write(obj.difficulty)
      ..writeByte(4)
      ..write(obj.duration)
      ..writeByte(5)
      ..write(obj.elevation)
      ..writeByte(6)
      ..write(obj.distance)
      ..writeByte(7)
      ..write(obj.description)
      ..writeByte(8)
      ..write(obj.imageUrl)
      ..writeByte(9)
      ..write(obj.highlights)
      ..writeByte(10)
      ..write(obj.startPoint)
      ..writeByte(11)
      ..write(obj.bestSeason);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
          other is TrailModelAdapter &&
              runtimeType == other.runtimeType &&
              typeId == other.typeId;
}