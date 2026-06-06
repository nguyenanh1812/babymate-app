// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pumping_session_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class PumpingSessionModelAdapter extends TypeAdapter<PumpingSessionModel> {
  @override
  final int typeId = 3;

  @override
  PumpingSessionModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return PumpingSessionModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      time: fields[2] as DateTime,
      totalMl: fields[4] as int?,
      note: fields[5] as String?,
      leftMl: fields[6] as int?,
      rightMl: fields[7] as int?,
    );
  }

  @override
  void write(BinaryWriter writer, PumpingSessionModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.totalMl)
      ..writeByte(5)
      ..write(obj.note)
      ..writeByte(6)
      ..write(obj.leftMl)
      ..writeByte(7)
      ..write(obj.rightMl);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is PumpingSessionModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
