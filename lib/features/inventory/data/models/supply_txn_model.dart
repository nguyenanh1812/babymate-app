import 'package:hive/hive.dart';

import '../../domain/entities/product.dart';
import '../../domain/entities/supply_txn.dart';

part 'supply_txn_model.g.dart';

/// Bản ghi Hive cho một giao dịch kho.
@HiveType(typeId: 5)
class SupplyTxnModel extends HiveObject {
  SupplyTxnModel({
    required this.id,
    required this.babyId,
    required this.delta,
    required this.time,
    this.typeIndex,
    this.note,
    this.category,
    this.productId,
  });

  factory SupplyTxnModel.fromEntity(SupplyTxn t) => SupplyTxnModel(
        id: t.id,
        babyId: t.babyId,
        delta: t.delta,
        time: t.time,
        note: t.note,
        category: t.category,
        productId: t.productId,
      );

  @HiveField(0)
  final String id;

  @HiveField(1)
  final String babyId;

  // Field 2 (typeIndex) là cách lưu cũ (0=bỉm, 1=sữa) — giữ để đọc dữ liệu cũ.
  @HiveField(2)
  final int? typeIndex;

  @HiveField(3)
  final int delta;

  @HiveField(4)
  final DateTime time;

  @HiveField(5)
  final String? note;

  @HiveField(6)
  final String? category;

  @HiveField(7)
  final String? productId;

  SupplyTxn toEntity() => SupplyTxn(
        id: id,
        babyId: babyId,
        productId:
            productId ?? (typeIndex == 1 ? kMilkProductId : kDiaperProductId),
        delta: delta,
        time: time,
        category: category,
        note: note,
      );
}
