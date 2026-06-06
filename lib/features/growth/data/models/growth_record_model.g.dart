// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'growth_record_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class GrowthRecordModelAdapter extends TypeAdapter<GrowthRecordModel> {
  @override
  final int typeId = 2;

  @override
  GrowthRecordModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return GrowthRecordModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      date: fields[2] as DateTime,
      weightKg: fields[3] as double?,
      heightCm: fields[4] as double?,
      headCircumferenceCm: fields[5] as double?,
      note: fields[6] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, GrowthRecordModel obj) {
    writer
      ..writeByte(7)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.date)
      ..writeByte(3)
      ..write(obj.weightKg)
      ..writeByte(4)
      ..write(obj.heightCm)
      ..writeByte(5)
      ..write(obj.headCircumferenceCm)
      ..writeByte(6)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is GrowthRecordModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
