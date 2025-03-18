import 'package:hive/hive.dart';

part 'mri_items_details.g.dart';

@HiveType(typeId: 2)
class MriItemsDetails {
  @HiveField(0)
  final int itemId;

  @HiveField(1)
  final double onHandQty;

  @HiveField(2)
  final int glAccountId;

  @HiveField(3)
  final double qty;

  @HiveField(4)
  final String itemRemark;

  @HiveField(5)
  final int faItemId;

  @HiveField(6)
  final int dimensionId;

  MriItemsDetails(
      {required this.itemId,
      required this.onHandQty,
      required this.glAccountId,
      required this.qty,
      required this.itemRemark,
      required this.faItemId,
      required this.dimensionId});

  factory MriItemsDetails.fromJson(Map<String, dynamic> json) {
    return MriItemsDetails(
      itemId: json['itemId'],
      onHandQty: json['onHandQty'],
      glAccountId: json['glAccountId'],
      qty: json['qty'],
      itemRemark: json['itemRemark'],
      faItemId: json['faItemId'],
      dimensionId: json['dimensionId'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'onHandQty': onHandQty,
      'glAccountId': glAccountId,
      'qty': qty,
      'itemRemark': itemRemark,
      'faItemId': faItemId,
      'dimensionId': dimensionId,
    };
  }
}
