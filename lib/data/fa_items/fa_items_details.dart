import 'package:hive/hive.dart';

part 'fa_items_details.g.dart';

@HiveType(typeId: 1)
class FaItemsDetails {
  @HiveField(0)
  final int itemId;

  @HiveField(1)
  final String itemDesc;

  FaItemsDetails({required this.itemId, required this.itemDesc});

  factory FaItemsDetails.fromJson(Map<String, dynamic> json) {
    return FaItemsDetails(
      itemId: json['itemId'],
      itemDesc: json['itemDesc'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'itemId': itemId,
      'itemDesc': itemDesc,
    };
  }
}
