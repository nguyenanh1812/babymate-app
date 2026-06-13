// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'baby_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class BabyModelAdapter extends TypeAdapter<BabyModel> {
  @override
  final int typeId = 0;

  @override
  BabyModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return BabyModel(
      id: fields[0] as String,
      name: fields[1] as String,
      birthDate: fields[2] as DateTime,
      genderIndex: fields[3] as int,
      avatarPath: fields[4] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, BabyModel obj) {
    writer
      ..writeByte(5)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.name)
      ..writeByte(2)
      ..write(obj.birthDate)
      ..writeByte(3)
      ..write(obj.genderIndex)
      ..writeByte(4)
      ..write(obj.avatarPath);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is BabyModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
