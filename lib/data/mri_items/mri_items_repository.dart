import 'package:hive_flutter/adapters.dart';
import 'package:mri/data/mri_items/mri_items_details.dart';

class MriItemsRepository {
  static const String _boxName = 'mriItemBox';
  final String baseURL = 'http://192.168.1.19:5000';
  static const Duration timeoutDuration = Duration(seconds: 10);

  // Future<Box> init() async {
  //   return await Hive.openBox<MriItemsDetails>(_boxName);
  // }

  Future<bool> addItem(int itemId, double onHandQty, int glAccountId,
      double qty, String itemRemark, int faItemId, int dimensionId) async {
    await Hive.close();
    final mriItemDetailsBox = await Hive.openBox(_boxName);
    final mriItemDetails = MriItemsDetails(
      itemId: itemId,
      onHandQty: onHandQty,
      glAccountId: glAccountId,
      qty: qty,
      itemRemark: itemRemark,
      faItemId: faItemId,
      dimensionId: dimensionId,
    );
    await mriItemDetailsBox.put(itemId, mriItemDetails);
    await mriItemDetailsBox.close();
    await Hive.close();
    return true;
  }

  dynamic getItem(itemId) {
    final mriItemDetailsBox = Hive.box(_boxName);
    return mriItemDetailsBox.get(itemId);
  }

  Future<bool> updateItem(itemId, onHandQty, glAccountId, qty, itemRemark,
      faItemId, dimensionId) async {
    await Hive.close();
    final mriItemDetailsBox = await Hive.openBox(_boxName);
    final mriItemDetails = MriItemsDetails(
      itemId: itemId,
      onHandQty: onHandQty,
      glAccountId: glAccountId,
      qty: qty,
      itemRemark: itemRemark,
      faItemId: faItemId,
      dimensionId: dimensionId,
    );
    mriItemDetailsBox.put(itemId, mriItemDetails);
    await Hive.close();
    return true;
  }

  Future<bool> deleteItem(itemId) async {
    await Hive.close();
    final mriItemDetailsBox = await Hive.openBox(_boxName);
    mriItemDetailsBox.delete(itemId);
    await Hive.close();
    return true;
  }

  Future<List<MriItemsDetails>> getAllItems() async {
    List<MriItemsDetails> mriItemsList = [];
    await Hive.close();
    final mriItemDetailsBox = await Hive.openBox(_boxName);
    for (var i = 0; i < mriItemDetailsBox.length; i++) {
      mriItemsList.add(mriItemDetailsBox.getAt(i));
    }
    await Hive.close();
    return mriItemsList;
  }

  Future<void> clearAllItems() async {
    final mriItemDetailsBox = await Hive.openBox(_boxName);
    mriItemDetailsBox.clear();
  }

  void closeBox() {
    Hive.close();
  }
}
