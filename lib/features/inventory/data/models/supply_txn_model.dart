import 'package:hive/hive.dart';

import '../../domain/entities/supply_txn.dart';

part 'supply_txn_model.g.dart';

/// Bản ghi Hive cho một giao dịch kho. Enum lưu dưới dạng index.
@HiveType(typeId: 5)
class SupplyTxnModel extends HiveObject {
  SupplyTxnModel({
    required this.id,
    required this.babyId,
    required this.typeIndex,
    required this.delta,
    required this.time,
    this.note,
  });

  factory SupplyTxnModel.fromEntity(SupplyTxn t) => SupplyTxnModel(
        id: t.id,
        babyId: t.babyId,
        typeIndex: t.type.index,
        delta: t.delta,
        time: t.time,
        note: t.note,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  @HiveField(2)
  final int typeIndex;

  @HiveField(3)
  final int delta;

  @HiveField(4)
  final DateTime time;

  @HiveField(5)
  final String? note;

  SupplyTxn toEntity() => SupplyTxn(
        id: id,
        babyId: babyId,
        type: SupplyType.values[typeIndex],
        delta: delta,
        time: time,
        note: note,
      );
}
