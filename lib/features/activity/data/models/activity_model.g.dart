// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'activity_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class ActivityModelAdapter extends TypeAdapter<ActivityModel> {
  @override
  final int typeId = 1;

  @override
  ActivityModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return ActivityModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      typeIndex: fields[2] as int,
      time: fields[3] as DateTime,
      endTime: fields[4] as DateTime?,
      amountMl: fields[5] as int?,
      feedingTypeIndex: fields[6] as int?,
      diaperTypeIndex: fields[7] as int?,
      note: fields[8] as String?,
      diaperCategory: fields[9] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, ActivityModel obj) {
    writer
      ..writeByte(10)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.time)
      ..writeByte(4)
      ..write(obj.endTime)
      ..writeByte(5)
      ..write(obj.amountMl)
      ..writeByte(6)
      ..write(obj.feedingTypeIndex)
      ..writeByte(7)
      ..write(obj.diaperTypeIndex)
      ..writeByte(8)
      ..write(obj.note)
      ..writeByte(9)
      ..write(obj.diaperCategory);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ActivityModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
