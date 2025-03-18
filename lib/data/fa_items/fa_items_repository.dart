import 'dart:convert';

import 'package:hive_flutter/adapters.dart';
import 'package:http/http.dart' as http;
import 'package:mri/data/fa_items/fa_items_details.dart';

class FaItemsRepository {
  static const String _boxName = 'faItemBox';
  final String baseURL = 'http://192.168.1.19:5000';
  static const Duration timeoutDuration = Duration(seconds: 10);

  Future<Box> init() async {
    return await Hive.openBox<FaItemsDetails>(_boxName);
  }

  Future<bool> downloadFAItems() async {
    await Hive.close();
    final faItemDetailsBox = await Hive.openBox(_boxName);

    final response = await http
        .get(
          Uri.parse('$baseURL/mobile/faitems'),
        )
        .timeout(timeoutDuration);
    if (response.statusCode == 200 && response.body.isNotEmpty) {
      await faItemDetailsBox.clear();
      final List<dynamic> faItems = jsonDecode(response.body);
      for (var faItem in faItems) {
        final faItemDetails = FaItemsDetails.fromJson(
          {
            'itemId': int.tryParse(faItem['itemId']),
            'itemDesc': faItem['itemDesc'],
          },
        );
        await faItemDetailsBox.put(faItemDetails.itemId, faItemDetails);
      }
      return faItemDetailsBox.isNotEmpty;
    } else if (response.statusCode == 500) {
      return Future.error('Internal Server Error');
    } else {
      return Future.error('Error downloading FA Items');
    }
  }

  Future<Map<int, String>> getFAItems() async {
    await Hive.close();
    final faItemDetailsBox = await Hive.openBox<FaItemsDetails>(_boxName);
    final Map<int, String> faItems = {};
    for (var i = 0; i < faItemDetailsBox.length; i++) {
      final faItemDetails = faItemDetailsBox.getAt(i);
      if (faItemDetails != null) {
        faItems[faItemDetails.itemId] = faItemDetails.itemDesc;
      }
    }
    return faItems;
  }
}
