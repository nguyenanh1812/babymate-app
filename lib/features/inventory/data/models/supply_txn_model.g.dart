// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'supply_txn_model.dart';

// **************************************************************************
// TypeAdapterGenerator
// **************************************************************************

class SupplyTxnModelAdapter extends TypeAdapter<SupplyTxnModel> {
  @override
  final int typeId = 5;

  @override
  SupplyTxnModel read(BinaryReader reader) {
    final numOfFields = reader.readByte();
    final fields = <int, dynamic>{
      for (int i = 0; i < numOfFields; i++) reader.readByte(): reader.read(),
    };
    return SupplyTxnModel(
      id: fields[0] as String,
      babyId: fields[1] as String,
      typeIndex: fields[2] as int,
      delta: fields[3] as int,
      time: fields[4] as DateTime,
      note: fields[5] as String?,
    );
  }

  @override
  void write(BinaryWriter writer, SupplyTxnModel obj) {
    writer
      ..writeByte(6)
      ..writeByte(0)
      ..write(obj.id)
      ..writeByte(1)
      ..write(obj.babyId)
      ..writeByte(2)
      ..write(obj.typeIndex)
      ..writeByte(3)
      ..write(obj.delta)
      ..writeByte(4)
      ..write(obj.time)
      ..writeByte(5)
      ..write(obj.note);
  }

  @override
  int get hashCode => typeId.hashCode;

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is SupplyTxnModelAdapter &&
          runtimeType == other.runtimeType &&
          typeId == other.typeId;
}
