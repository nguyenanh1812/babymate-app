// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moment_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class MomentModelAdapter extends TypeAdapter<MomentModel> {
  @override
  final int typeId = 7;

  @override
  MomentModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return MomentModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      imagePath: fields[2] as String,
      time: fields[3] as DateTime,
      caption: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, MomentModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.imagePath)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.caption);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is MomentModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
